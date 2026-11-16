//
//  AreaPerformance.swift
//  RideAssistPro
//

import Foundation

enum DataConfidenceLevel: String, Codable, CaseIterable {
    case high = "HIGH CONFIDENCE"
    case medium = "MEDIUM CONFIDENCE"
    case low = "LOW CONFIDENCE"
    case noData = "NO DATA"
    
    var vietnameseLabel: String {
        switch self {
        case .high: return "Độ tin cậy cao (Đủ dữ liệu cá nhân)"
        case .medium: return "Độ tin cậy trung bình (Dữ liệu hạn chế)"
        case .low: return "Độ tin cậy thấp (Thiếu dữ liệu)"
        case .noData: return "Chưa có dữ liệu"
        }
    }
    
    var explanation: String {
        switch self {
        case .high:
            return "Thống kê từ >= 10 chuyến xe hoàn thành do chính bạn ghi nhận trên thiết bị."
        case .medium:
            return "Thống kê từ 4 - 9 chuyến xe cá nhân. Nên kết hợp quan sát thực tế."
        case .low:
            return "Chỉ mới có 1 - 3 chuyến xe ghi nhận tại khu vực/khung giờ này."
        case .noData:
            return "CHƯA ĐỦ DỮ LIỆU PHÂN TÍCH. Ứng dụng không tạo nhu cầu giả."
        }
    }
    
    static func from(rideCount: Int) -> DataConfidenceLevel {
        switch rideCount {
        case 10...: return .high
        case 4...9: return .medium
        case 1...3: return .low
        default: return .noData
        }
    }
}

struct TimeSlotConfig: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var startHour: Int
    var endHour: Int
    
    var timeRangeLabel: String {
        String(format: "%02d:00 - %02d:00", startHour, endHour)
    }
    
    func contains(hour: Int) -> Bool {
        if startHour <= endHour {
            return hour >= startHour && hour < endHour
        } else {
            // Qua đêm (ví dụ 22:00 - 05:00)
            return hour >= startHour || hour < endHour
        }
    }
    
    static let defaultSlots: [TimeSlotConfig] = [
        TimeSlotConfig(id: "early_morning", name: "Sáng sớm", startHour: 5, endHour: 6),
        TimeSlotConfig(id: "morning_rush", name: "Giờ cao điểm sáng", startHour: 6, endHour: 9),
        TimeSlotConfig(id: "mid_morning", name: "Giữa buổi sáng", startHour: 9, endHour: 11),
        TimeSlotConfig(id: "noon", name: "Buổi trưa", startHour: 11, endHour: 14),
        TimeSlotConfig(id: "afternoon", name: "Buổi chiều", startHour: 14, endHour: 16),
        TimeSlotConfig(id: "evening_rush", name: "Giờ cao điểm chiều", startHour: 16, endHour: 19),
        TimeSlotConfig(id: "evening", name: "Buổi tối", startHour: 19, endHour: 22),
        TimeSlotConfig(id: "night", name: "Đêm", startHour: 22, endHour: 5)
    ]
}

struct AreaPerformanceSummary: Identifiable, Equatable {
    var id: String { areaName }
    var areaName: String
    var completedRidesCount: Int
    var totalRevenueVND: Double
    var averageFareVND: Double
    var averageWaitingMinutes: Double
    var averageRevenuePerKmVND: Double
    var averageRevenuePerHourVND: Double
    var compositeEfficiencyScore: Double // Điểm tổng hợp thực tế từ dữ liệu cá nhân
    var confidence: DataConfidenceLevel
}

struct TimeSlotPerformanceSummary: Identifiable, Equatable {
    var id: String { slot.id }
    var slot: TimeSlotConfig
    var completedRidesCount: Int
    var averageRidesPerActiveDay: Double
    var totalRevenueVND: Double
    var averageFareVND: Double
    var averageWaitingMinutes: Double
    var averageRevenuePerHourVND: Double
    var confidence: DataConfidenceLevel
}

struct NextAreaRecommendation: Identifiable, Equatable {
    var id: UUID = UUID()
    var priorityAreaName: String
    var reason: String
    var distanceKmFromCurrent: Double?
    var historicalRevenuePerHourVND: Double
    var historicalAvgWaitMinutes: Double
    var historicalCompletedRides: Int
    var confidence: DataConfidenceLevel
    var dataSourceExplanation: String
}

enum OfficialFeatureVerificationState: String, Codable, CaseIterable {
    case verified = "Đã kiểm chứng"
    case needsReview = "Cần kiểm tra lại"
    case unverified = "Chưa xác minh"
    case expired = "Hết hiệu lực"
}

struct OfficialGrabFeatureGuideItem: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var category: String
    var summary: String
    var conditionsToUse: [String]
    var applicableAreas: String
    var activationSteps: [String]
    var importantNotesAndRateImpacts: [String]
    var officialURL: String
    var verificationState: OfficialFeatureVerificationState
    var lastVerifiedDate: String
}

struct WidgetDataSnapshot: Codable, Equatable {
    var isShiftActive: Bool
    var shiftStatusText: String
    var revenueGoalVND: Double
    var currentRevenueVND: Double
    var recordedRidesCount: Int
    var activeHoursText: String
    var priorityArea: String
    var targetMinimumFareVND: Double
    var maxPickupDistanceText: String
    var activeConfigName: String
    var updatedAt: Date
    
    static let placeholder = WidgetDataSnapshot(
        isShiftActive: false,
        shiftStatusText: "Chưa bắt đầu ca",
        revenueGoalVND: 600_000,
        currentRevenueVND: 0,
        recordedRidesCount: 0,
        activeHoursText: "0g 0p",
        priorityArea: "Quận 1, Quận 3",
        targetMinimumFareVND: 20_000,
        maxPickupDistanceText: "2.0 km",
        activeConfigName: "Chạy sáng (Cao điểm)",
        updatedAt: Date()
    )
}
