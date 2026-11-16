//
//  DemandAnalysisService.swift
//  RideAssistPro
//

import Foundation
import CoreLocation

final class DemandAnalysisService {
    static let shared = DemandAnalysisService()
    
    /// Phân tích hiệu quả theo Khu vực từ lịch sử cuốc xe hoàn thành do tài xế tự ghi nhận.
    /// Nếu chưa có dữ liệu, trả về mảng rỗng để UI hiển thị rõ "CHƯA ĐỦ DỮ LIỆU PHÂN TÍCH".
    func analyzeAreaPerformance(from history: [RideHistoryRecord]) -> [AreaPerformanceSummary] {
        let completedRides = history.filter { $0.status == .completed }
        guard !completedRides.isEmpty else { return [] }
        
        let grouped = Dictionary(grouping: completedRides) { record in
            record.pickupArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Chưa rõ khu vực"
                : record.pickupArea.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        var summaries: [AreaPerformanceSummary] = []
        for (areaName, rides) in grouped {
            let count = rides.count
            let totalRev = rides.reduce(0.0) { $0 + $1.totalIncomeVND }
            let avgFare = totalRev / Double(count)
            let totalWait = rides.reduce(0.0) { $0 + max(0, $1.waitingMinutesBeforeRide) }
            let avgWait = totalWait / Double(count)
            let totalKm = rides.reduce(0.0) { $0 + max(0.1, $1.totalDistanceKm) }
            let avgRevPerKm = totalRev / max(0.1, totalKm)
            
            let totalActiveMinutes = rides.reduce(0.0) { $0 + max(1.0, $1.durationMinutes + $1.waitingMinutesBeforeRide) }
            let avgRevPerHour = totalRev / (totalActiveMinutes / 60.0)
            
            // Điểm tổng hợp: ưu tiên doanh thu/giờ cao và thời gian chờ thấp
            let revHourNormalized = min(100.0, (avgRevPerHour / 80_000.0) * 100.0)
            let waitPenaltyNormalized = max(0.0, 100.0 - avgWait * 4.0)
            let composite = revHourNormalized * 0.65 + waitPenaltyNormalized * 0.35
            
            summaries.append(
                AreaPerformanceSummary(
                    areaName: areaName,
                    completedRidesCount: count,
                    totalRevenueVND: totalRev,
                    averageFareVND: avgFare,
                    averageWaitingMinutes: avgWait,
                    averageRevenuePerKmVND: avgRevPerKm,
                    averageRevenuePerHourVND: avgRevPerHour,
                    compositeEfficiencyScore: composite,
                    confidence: DataConfidenceLevel.from(rideCount: count)
                )
            )
        }
        
        return summaries.sorted { $0.compositeEfficiencyScore > $1.compositeEfficiencyScore }
    }
    
    /// Phân tích hiệu quả theo 8 khung giờ cá nhân
    func analyzeTimeSlots(from history: [RideHistoryRecord], slots: [TimeSlotConfig]) -> [TimeSlotPerformanceSummary] {
        let completedRides = history.filter { $0.status == .completed }
        let calendar = Calendar.current
        
        // Tính số ngày khác nhau có dữ liệu
        let uniqueDays = Set(completedRides.map { calendar.startOfDay(for: $0.timestamp) })
        let activeDaysCount = max(1, uniqueDays.count)
        
        return slots.map { slot in
            let matchingRides = completedRides.filter { record in
                let hour = calendar.component(.hour, from: record.timestamp)
                return slot.contains(hour: hour)
            }
            let count = matchingRides.count
            guard count > 0 else {
                return TimeSlotPerformanceSummary(
                    slot: slot,
                    completedRidesCount: 0,
                    averageRidesPerActiveDay: 0,
                    totalRevenueVND: 0,
                    averageFareVND: 0,
                    averageWaitingMinutes: 0,
                    averageRevenuePerHourVND: 0,
                    confidence: .noData
                )
            }
            
            let totalRev = matchingRides.reduce(0.0) { $0 + $1.totalIncomeVND }
            let avgFare = totalRev / Double(count)
            let avgWait = matchingRides.reduce(0.0) { $0 + $1.waitingMinutesBeforeRide } / Double(count)
            let totalDurationHours = matchingRides.reduce(0.0) { $0 + max(1.0, $1.durationMinutes + $1.waitingMinutesBeforeRide) } / 60.0
            let avgRevPerHour = totalRev / max(0.1, totalDurationHours)
            
            return TimeSlotPerformanceSummary(
                slot: slot,
                completedRidesCount: count,
                averageRidesPerActiveDay: Double(count) / Double(activeDaysCount),
                totalRevenueVND: totalRev,
                averageFareVND: avgFare,
                averageWaitingMinutes: avgWait,
                averageRevenuePerHourVND: avgRevPerHour,
                confidence: DataConfidenceLevel.from(rideCount: count)
            )
        }
    }
    
    /// Thuật toán gợi ý khu vực tiếp theo dựa trên dữ liệu cá nhân thực tế, khoảng cách và mục tiêu.
    func recommendNextAreas(
        currentLocation: CLLocation?,
        savedLocations: [SavedDriverLocation],
        history: [RideHistoryRecord],
        remainingRevenueGoal: Double
    ) -> [NextAreaRecommendation] {
        let areaSummaries = analyzeAreaPerformance(from: history)
        guard !areaSummaries.isEmpty else {
            return []
        }
        
        return areaSummaries.prefix(5).map { area in
            // Tìm tọa độ đã lưu gần nhất của khu vực này để tính khoảng cách
            let matchedSaved = savedLocations.first {
                $0.areaDistrict.localizedCaseInsensitiveContains(area.areaName) ||
                area.areaName.localizedCaseInsensitiveContains($0.areaDistrict)
            }
            
            var distanceKm: Double? = nil
            if let userLoc = currentLocation, let saved = matchedSaved {
                distanceKm = saved.distanceKm(from: userLoc)
            }
            
            var reasons: [String] = []
            reasons.append("Doanh thu lịch sử cá nhân đạt ~\(Formatters.formatVND(area.averageRevenuePerHourVND))/giờ (\(area.completedRidesCount) cuốc đã ghi nhận).")
            reasons.append("Thời gian chờ trung bình cá nhân: \(String(format: "%.0f", area.averageWaitingMinutes)) phút.")
            if let dist = distanceKm {
                reasons.append("Cách vị trí hiện tại khoảng \(Formatters.formatDistanceKm(dist)).")
            }
            if remainingRevenueGoal > 0 && area.averageFareVND > 0 {
                let estimatedRidesNeeded = Int(ceil(remainingRevenueGoal / area.averageFareVND))
                reasons.append("Ước tính cần khoảng \(estimatedRidesNeeded) chuyến trung bình tại đây để hoàn thành mục tiêu ca.")
            }
            
            return NextAreaRecommendation(
                priorityAreaName: area.areaName,
                reason: reasons.joined(separator: " "),
                distanceKmFromCurrent: distanceKm,
                historicalRevenuePerHourVND: area.averageRevenuePerHourVND,
                historicalAvgWaitMinutes: area.averageWaitingMinutes,
                historicalCompletedRides: area.completedRidesCount,
                confidence: area.confidence,
                dataSourceExplanation: "Nguồn dữ liệu: Tính toán 100% từ \(area.completedRidesCount) chuyến xe do bạn ghi nhận trên iPhone. Không sử dụng dữ liệu nội bộ của Grab."
            )
        }
    }
}
