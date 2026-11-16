//
//  RideScoringService.swift
//  RideAssistPro
//

import Foundation

final class RideScoringService: RideScoringServiceProtocol {
    static let shared = RideScoringService()
    
    func evaluateRide(
        candidate: RideCandidate,
        criteria: RideCriteria,
        fuelSettings: FuelAndExpenseSettings
    ) -> Result<RideEvaluation, RideScoringError> {
        // 1. Không chấm điểm khi thiếu dữ liệu quan trọng
        guard candidate.totalIncomeVND > 0 else {
            return .failure(.missingFare)
        }
        guard candidate.tripDistanceKm > 0 else {
            return .failure(.missingDistance)
        }
        guard candidate.estimatedDurationMinutes > 0 else {
            return .failure(.missingDuration)
        }
        let weights = criteria.weights
        guard weights.totalWeight > 0 else {
            return .failure(.invalidWeights)
        }
        
        // 2. Các chỉ số thực tế và ước tính của chuyến
        let totalKm = max(0.1, candidate.totalDistanceKm)
        let totalHours = max(0.02, candidate.estimatedDurationMinutes / 60.0)
        let totalIncome = candidate.totalIncomeVND
        
        let revenuePerKm = totalIncome / totalKm
        let revenuePerHour = totalIncome / totalHours
        let estimatedFuelCost = (totalKm / 100.0) * fuelSettings.fuelConsumptionLitersPer100Km * fuelSettings.fuelPricePerLiterVND
        let estimatedNetProfit = totalIncome - estimatedFuelCost
        
        // Phân loại độ dài cuốc
        let lengthCategory: String
        if candidate.tripDistanceKm <= criteria.shortRideThresholdKm {
            lengthCategory = "Cuốc ngắn"
        } else if candidate.tripDistanceKm <= criteria.mediumRideThresholdKm {
            lengthCategory = "Cuốc trung bình"
        } else {
            lengthCategory = "Cuốc dài"
        }
        
        // 3. Chấm điểm từng thành phần (thang 0..100)
        // 3.1 Giá cuốc
        let minFare = max(10_000, criteria.minimumFareVND)
        let fareRatio = totalIncome / minFare
        let fareSubScore: Double
        if fareRatio >= 1.5 {
            fareSubScore = 100
        } else if fareRatio >= 1.0 {
            fareSubScore = 75 + (fareRatio - 1.0) * 50.0
        } else {
            fareSubScore = max(10, fareRatio * 70.0)
        }
        
        // 3.2 Khoảng cách đón
        let pickupKm = max(0, candidate.pickupDistanceKm)
        let maxPickup = criteria.maxPickupDistanceKm ?? 3.0
        let pickupDistanceSubScore: Double
        if pickupKm <= 0.5 {
            pickupDistanceSubScore = 100
        } else if pickupKm <= maxPickup {
            let ratio = (pickupKm - 0.5) / max(0.5, maxPickup - 0.5)
            pickupDistanceSubScore = max(65, 100 - ratio * 30.0)
        } else {
            let excess = pickupKm - maxPickup
            pickupDistanceSubScore = max(5, 65 - excess * 22.0)
        }
        
        // 3.3 Hiệu quả / km
        let targetPerKm = max(4_000, criteria.targetEfficiencyPerKmVND)
        let kmEffRatio = revenuePerKm / targetPerKm
        let efficiencyPerKmSubScore = min(100, max(10, kmEffRatio * 82.0))
        
        // 3.4 Hiệu quả / giờ
        let targetPerHour = max(35_000, criteria.targetEfficiencyPerHourVND)
        let hourEffRatio = revenuePerHour / targetPerHour
        let efficiencyPerHourSubScore = min(100, max(10, hourEffRatio * 82.0))
        
        // 3.5 Điểm đến + Khả năng có cuốc chiều về
        var baseDestScore = candidate.destinationType.destinationScorePoints
        let dropoffNormalized = candidate.dropoffArea.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !dropoffNormalized.isEmpty {
            if criteria.priorityAreas.contains(where: { dropoffNormalized.contains($0.lowercased()) }) {
                baseDestScore = max(baseDestScore, 95)
            } else if criteria.nonPriorityAreas.contains(where: { dropoffNormalized.contains($0.lowercased()) }) {
                baseDestScore = min(baseDestScore, 30)
            }
        }
        let destinationSubScore = min(100, max(10, baseDestScore * 0.7 + (candidate.returnTripLikelihood.bonusMultiplier * 100.0) * 0.3))
        
        // 3.6 Chi phí vận hành (tỷ lệ nhiên liệu trên thu nhập chuyến)
        let fuelRatio = estimatedFuelCost / totalIncome
        let operatingCostSubScore: Double
        if fuelRatio <= 0.10 {
            operatingCostSubScore = 95
        } else if fuelRatio <= 0.18 {
            operatingCostSubScore = 80
        } else if fuelRatio <= 0.25 {
            operatingCostSubScore = 60
        } else {
            operatingCostSubScore = max(15, 100 - fuelRatio * 250.0)
        }
        
        // 4. Tính tổng điểm theo trọng số người dùng cấu hình
        let weightedSum =
            fareSubScore * weights.fareWeight +
            pickupDistanceSubScore * weights.pickupDistanceWeight +
            efficiencyPerKmSubScore * weights.efficiencyPerKmWeight +
            efficiencyPerHourSubScore * weights.efficiencyPerHourWeight +
            destinationSubScore * weights.destinationWeight +
            operatingCostSubScore * weights.operatingCostWeight
        
        var rawScore = Int(round(weightedSum / weights.totalWeight))
        rawScore = min(100, max(0, rawScore))
        
        // 5. Giải thích chi tiết tại sao điểm cao hoặc thấp
        var positiveReasons: [String] = []
        var warningReasons: [String] = []
        
        if totalIncome >= criteria.minimumFareVND {
            positiveReasons.append("Giá trị chuyến (\(Formatters.formatVND(totalIncome))) đạt/vượt mức tối thiểu (\(Formatters.formatVND(criteria.minimumFareVND))).")
        } else {
            warningReasons.append("Giá trị chuyến (\(Formatters.formatVND(totalIncome))) thấp hơn ngưỡng mục tiêu (\(Formatters.formatVND(criteria.minimumFareVND))).")
        }
        
        if let maxPickupAllowed = criteria.maxPickupDistanceKm {
            if pickupKm <= maxPickupAllowed {
                positiveReasons.append("Khoảng cách đón khách ngắn (\(Formatters.formatDistanceKm(pickupKm)) <= \(Formatters.formatDistanceKm(maxPickupAllowed))).")
            } else {
                warningReasons.append("Điểm đón xa (\(Formatters.formatDistanceKm(pickupKm))), vượt mức tối đa đã đặt (\(Formatters.formatDistanceKm(maxPickupAllowed))).")
            }
        }
        
        if revenuePerKm >= criteria.targetEfficiencyPerKmVND {
            positiveReasons.append("Hiệu quả theo km tốt (\(Formatters.formatVND(revenuePerKm))/km).")
        } else {
            warningReasons.append("Hiệu quả theo km (\(Formatters.formatVND(revenuePerKm))/km) thấp hơn kỳ vọng (\(Formatters.formatVND(criteria.targetEfficiencyPerKmVND))/km).")
        }
        
        if revenuePerHour >= criteria.targetEfficiencyPerHourVND {
            positiveReasons.append("Tốc độ tạo doanh thu ước tính tốt (~\(Formatters.formatVND(revenuePerHour))/giờ).")
        } else {
            warningReasons.append("Thời gian di chuyển dự kiến (\(Int(candidate.estimatedDurationMinutes)) phút) làm giảm hiệu suất theo giờ (~\(Formatters.formatVND(revenuePerHour))/giờ).")
        }
        
        if destinationSubScore >= 80 {
            positiveReasons.append("Điểm trả khách thuận lợi (\(candidate.destinationType.rawValue)) và cơ hội có chuyến tiếp theo \(candidate.returnTripLikelihood.rawValue.lowercased()).")
        } else if destinationSubScore < 50 {
            warningReasons.append("Điểm trả khách thuộc khu vực ít chuyến chiều về (\(candidate.destinationType.rawValue)).")
        }
        
        // Kiểm tra bộ lọc theo chế độ STRICT / BALANCED / FLEXIBLE
        let meetsFare = totalIncome >= criteria.minimumFareVND
        let meetsPickup = criteria.maxPickupDistanceKm == nil || pickupKm <= (criteria.maxPickupDistanceKm ?? 999)
        let meetsScore = rawScore >= criteria.filterMode.minimumPassingScore
        
        let passesFilter: Bool
        switch criteria.filterMode {
        case .strict:
            passesFilter = meetsFare && meetsPickup && meetsScore && destinationSubScore >= 60
        case .balanced:
            passesFilter = meetsScore && (meetsFare || revenuePerKm >= criteria.targetEfficiencyPerKmVND)
        case .flexible:
            passesFilter = rawScore >= criteria.filterMode.minimumPassingScore
        }
        
        let tier = RideScoreTier.from(score: rawScore)
        let breakdown = RideEvaluationBreakdown(
            fareSubScore: fareSubScore,
            pickupDistanceSubScore: pickupDistanceSubScore,
            efficiencyPerKmSubScore: efficiencyPerKmSubScore,
            efficiencyPerHourSubScore: efficiencyPerHourSubScore,
            destinationSubScore: destinationSubScore,
            operatingCostSubScore: operatingCostSubScore
        )
        
        let evaluation = RideEvaluation(
            candidate: candidate,
            criteriaProfileName: criteria.profileName,
            filterMode: criteria.filterMode,
            totalScore: rawScore,
            tier: tier,
            passesFilterCriteria: passesFilter,
            revenuePerKmVND: revenuePerKm,
            revenuePerHourVND: revenuePerHour,
            estimatedFuelCostVND: estimatedFuelCost,
            estimatedNetProfitVND: estimatedNetProfit,
            rideLengthClassification: lengthCategory,
            breakdown: breakdown,
            positiveReasons: positiveReasons,
            warningReasons: warningReasons,
            personalAssessmentNote: "Đây là điểm đánh giá cá nhân theo tiêu chí '\(criteria.profileName)' của bạn, không phải điểm ưu tiên của hệ thống Grab."
        )
        
        return .success(evaluation)
    }
}
