//
//  ShiftRecord.swift
//  RideAssistPro
//

import Foundation

enum ShiftStatus: String, Codable, Equatable {
    case idle = "Chưa bắt đầu ca"
    case active = "Đang trong ca chạy"
    case paused = "Đang tạm nghỉ"
    case completed = "Đã kết thúc ca"
}

struct ShiftRecord: Codable, Identifiable, Equatable {
    var id: UUID
    var startTime: Date
    var plannedEndTime: Date
    var actualEndTime: Date?
    var status: ShiftStatus
    var workingArea: String
    var revenueGoalVND: Double
    var ridesGoalCount: Int
    var plannedBreakMinutes: Int
    var accumulatedBreakSeconds: TimeInterval
    var lastPauseStartTime: Date?
    var fuelBudgetVND: Double
    var recordedRidesCount: Int
    var completedRidesCount: Int
    var totalRevenueVND: Double
    var totalDistanceKm: Double
    var totalWaitingMinutes: Double
    var otherOperatingCostVND: Double
    var notes: String
    
    func activeWorkingDurationSeconds(at referenceDate: Date = Date()) -> TimeInterval {
        let end = actualEndTime ?? referenceDate
        let rawDuration = max(0, end.timeIntervalSince(startTime))
        var ongoingPause: TimeInterval = 0
        if status == .paused, let pauseStart = lastPauseStartTime {
            ongoingPause = max(0, end.timeIntervalSince(pauseStart))
        }
        return max(0, rawDuration - accumulatedBreakSeconds - ongoingPause)
    }
    
    func activeWorkingHours(at referenceDate: Date = Date()) -> Double {
        activeWorkingDurationSeconds(at: referenceDate) / 3600.0
    }
    
    var remainingRevenueGoalVND: Double {
        max(0, revenueGoalVND - totalRevenueVND)
    }
    
    var remainingRidesGoalCount: Int {
        max(0, ridesGoalCount - completedRidesCount)
    }
    
    var averageWaitMinutes: Double {
        guard completedRidesCount > 0 else { return 0 }
        return totalWaitingMinutes / Double(completedRidesCount)
    }
    
    var revenuePerKmVND: Double {
        guard totalDistanceKm > 0 else { return 0 }
        return totalRevenueVND / totalDistanceKm
    }
    
    func revenuePerHourVND(at referenceDate: Date = Date()) -> Double {
        let hours = activeWorkingHours(at: referenceDate)
        guard hours > 0.05 else { return 0 }
        return totalRevenueVND / hours
    }
}
