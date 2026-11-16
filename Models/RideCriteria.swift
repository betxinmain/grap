//
//  RideCriteria.swift
//  RideAssistPro
//

import Foundation

enum FilterMode: String, Codable, CaseIterable, Identifiable {
    case strict = "STRICT"
    case balanced = "BALANCED"
    case flexible = "FLEXIBLE"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .strict: return "STRICT (Nghiêm ngặt)"
        case .balanced: return "BALANCED (Cân bằng)"
        case .flexible: return "FLEXIBLE (Linh hoạt)"
        }
    }
    
    var description: String {
        switch self {
        case .strict:
            return "Chỉ khuyến nghị các cuốc đạt đầy đủ mọi ngưỡng giá trị, khoảng cách đón và điểm đến."
        case .balanced:
            return "Cân đối giữa giá cuốc, hiệu quả/km và khoảng cách đón hợp lý."
        case .flexible:
            return "Linh hoạt chấp nhận cuốc có điểm số khá trở lên khi khu vực đang ít chuyến."
        }
    }
    
    var minimumPassingScore: Int {
        switch self {
        case .strict: return 80
        case .balanced: return 68
        case .flexible: return 52
        }
    }
}

enum DestinationPreferenceType: String, Codable, CaseIterable, Identifiable {
    case priorityArea = "Khu vực ưu tiên"
    case favorableNextRide = "Thuận lợi cuốc tiếp theo"
    case nearHome = "Khu vực gần nhà"
    case nearShiftEnd = "Gần điểm kết thúc ca"
    case neutral = "Bình thường"
    case nonPriority = "Khu vực không ưu tiên / Vắng khách"
    
    var id: String { rawValue }
    
    var destinationScorePoints: Double {
        switch self {
        case .priorityArea: return 100
        case .favorableNextRide: return 90
        case .nearHome: return 85
        case .nearShiftEnd: return 85
        case .neutral: return 65
        case .nonPriority: return 25
        }
    }
}

struct ScoringWeights: Codable, Equatable {
    var fareWeight: Double          // Default 25%
    var pickupDistanceWeight: Double // Default 15%
    var efficiencyPerKmWeight: Double // Default 20%
    var efficiencyPerHourWeight: Double // Default 20%
    var destinationWeight: Double   // Default 10%
    var operatingCostWeight: Double // Default 10%
    
    var totalWeight: Double {
        fareWeight + pickupDistanceWeight + efficiencyPerKmWeight + efficiencyPerHourWeight + destinationWeight + operatingCostWeight
    }
    
    static let standard = ScoringWeights(
        fareWeight: 25,
        pickupDistanceWeight: 15,
        efficiencyPerKmWeight: 20,
        efficiencyPerHourWeight: 20,
        destinationWeight: 10,
        operatingCostWeight: 10
    )
}

struct RideCriteria: Codable, Identifiable, Equatable {
    var id: UUID
    var profileName: String
    var minimumFareVND: Double               // 15k, 20k, 25k, 30k, 40k, custom
    var maxPickupDistanceKm: Double?         // 1, 2, 3, 5, nil (Không giới hạn), custom
    var shortRideThresholdKm: Double         // Ngưỡng cuốc ngắn (ví dụ <= 3.5 km)
    var mediumRideThresholdKm: Double        // Ngưỡng cuốc trung bình (ví dụ <= 8.0 km, trên đó là cuốc dài)
    var preferredRideLengthCategory: String  // "Tất cả", "Cuốc ngắn", "Cuốc trung bình", "Cuốc dài"
    var priorityAreas: [String]
    var nonPriorityAreas: [String]
    var homeArea: String
    var shiftEndArea: String
    var targetTimeSlotName: String
    var targetRevenueGoalVND: Double
    var targetEfficiencyPerKmVND: Double     // Ví dụ 7.000đ/km
    var targetEfficiencyPerHourVND: Double   // Ví dụ 65.000đ/giờ
    var filterMode: FilterMode
    var weights: ScoringWeights
    
    static let defaultPresets: [RideCriteria] = [
        RideCriteria(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111101") ?? UUID(),
            profileName: "Chạy sáng (Cao điểm)",
            minimumFareVND: 20_000,
            maxPickupDistanceKm: 1.5,
            shortRideThresholdKm: 3.5,
            mediumRideThresholdKm: 8.0,
            preferredRideLengthCategory: "Cuốc ngắn",
            priorityAreas: ["Quận 1", "Quận 3", "Bình Thạnh", "Phú Nhuận"],
            nonPriorityAreas: ["Khu ngoại thành xa"],
            homeArea: "Quận Tân Bình",
            shiftEndArea: "Quận 1",
            targetTimeSlotName: "Giờ cao điểm sáng (06:30 - 09:00)",
            targetRevenueGoalVND: 250_000,
            targetEfficiencyPerKmVND: 7_500,
            targetEfficiencyPerHourVND: 75_000,
            filterMode: .strict,
            weights: .standard
        ),
        RideCriteria(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111102") ?? UUID(),
            profileName: "Chạy trưa (Linh hoạt)",
            minimumFareVND: 15_000,
            maxPickupDistanceKm: 2.5,
            shortRideThresholdKm: 3.5,
            mediumRideThresholdKm: 8.0,
            preferredRideLengthCategory: "Tất cả",
            priorityAreas: ["Quận 1", "Quận 3", "Quận 10", "Tân Bình"],
            nonPriorityAreas: [],
            homeArea: "Quận Tân Bình",
            shiftEndArea: "Quận Tân Bình",
            targetTimeSlotName: "Buổi trưa (11:00 - 13:30)",
            targetRevenueGoalVND: 180_000,
            targetEfficiencyPerKmVND: 6_500,
            targetEfficiencyPerHourVND: 55_000,
            filterMode: .flexible,
            weights: .standard
        ),
        RideCriteria(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111103") ?? UUID(),
            profileName: "Chạy tối & Doanh thu cao",
            minimumFareVND: 30_000,
            maxPickupDistanceKm: 2.0,
            shortRideThresholdKm: 4.0,
            mediumRideThresholdKm: 10.0,
            preferredRideLengthCategory: "Cuốc trung bình",
            priorityAreas: ["Quận 1", "Quận 7", "Bình Thạnh", "Thủ Đức"],
            nonPriorityAreas: ["Cần Giờ", "Củ Chi"],
            homeArea: "Quận Tân Bình",
            shiftEndArea: "Quận Tân Bình",
            targetTimeSlotName: "Giờ cao điểm chiều & Tối (16:30 - 21:30)",
            targetRevenueGoalVND: 350_000,
            targetEfficiencyPerKmVND: 7_500,
            targetEfficiencyPerHourVND: 70_000,
            filterMode: .balanced,
            weights: ScoringWeights(
                fareWeight: 30,
                pickupDistanceWeight: 15,
                efficiencyPerKmWeight: 20,
                efficiencyPerHourWeight: 20,
                destinationWeight: 5,
                operatingCostWeight: 10
            )
        ),
        RideCriteria(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111104") ?? UUID(),
            profileName: "Chạy ưu tiên cuốc ngắn",
            minimumFareVND: 15_000,
            maxPickupDistanceKm: 1.0,
            shortRideThresholdKm: 3.0,
            mediumRideThresholdKm: 6.0,
            preferredRideLengthCategory: "Cuốc ngắn",
            priorityAreas: ["Quận 1", "Quận 3", "Quận 5", "Phú Nhuận"],
            nonPriorityAreas: [],
            homeArea: "Quận Tân Bình",
            shiftEndArea: "Quận Phú Nhuận",
            targetTimeSlotName: "Cả ngày",
            targetRevenueGoalVND: 500_000,
            targetEfficiencyPerKmVND: 8_000,
            targetEfficiencyPerHourVND: 65_000,
            filterMode: .strict,
            weights: ScoringWeights(
                fareWeight: 15,
                pickupDistanceWeight: 25,
                efficiencyPerKmWeight: 25,
                efficiencyPerHourWeight: 20,
                destinationWeight: 5,
                operatingCostWeight: 10
            )
        ),
        RideCriteria(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111105") ?? UUID(),
            profileName: "Chạy gần nhà / Cuối ca",
            minimumFareVND: 20_000,
            maxPickupDistanceKm: 2.0,
            shortRideThresholdKm: 3.5,
            mediumRideThresholdKm: 8.0,
            preferredRideLengthCategory: "Tất cả",
            priorityAreas: ["Quận Tân Bình", "Quận Phú Nhuận", "Quận Gò Vấp"],
            nonPriorityAreas: ["Quận 7", "Quận 9"],
            homeArea: "Quận Tân Bình",
            shiftEndArea: "Quận Tân Bình",
            targetTimeSlotName: "Cuối ca làm việc",
            targetRevenueGoalVND: 150_000,
            targetEfficiencyPerKmVND: 6_500,
            targetEfficiencyPerHourVND: 60_000,
            filterMode: .balanced,
            weights: ScoringWeights(
                fareWeight: 20,
                pickupDistanceWeight: 15,
                efficiencyPerKmWeight: 15,
                efficiencyPerHourWeight: 15,
                destinationWeight: 25,
                operatingCostWeight: 10
            )
        )
    ]
}
