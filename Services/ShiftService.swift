//
//  ShiftService.swift
//  RideAssistPro
//

import Foundation

final class ShiftService {
    static let shared = ShiftService()
    
    func startNewShift(
        workingArea: String,
        revenueGoalVND: Double,
        ridesGoalCount: Int,
        plannedDurationHours: Double,
        plannedBreakMinutes: Int,
        fuelBudgetVND: Double
    ) -> ShiftRecord {
        let now = Date()
        let plannedEnd = now.addingTimeInterval(max(1, plannedDurationHours) * 3600)
        return ShiftRecord(
            id: UUID(),
            startTime: now,
            plannedEndTime: plannedEnd,
            actualEndTime: nil,
            status: .active,
            workingArea: workingArea,
            revenueGoalVND: revenueGoalVND,
            ridesGoalCount: ridesGoalCount,
            plannedBreakMinutes: plannedBreakMinutes,
            accumulatedBreakSeconds: 0,
            lastPauseStartTime: nil,
            fuelBudgetVND: fuelBudgetVND,
            recordedRidesCount: 0,
            completedRidesCount: 0,
            totalRevenueVND: 0,
            totalDistanceKm: 0,
            totalWaitingMinutes: 0,
            otherOperatingCostVND: 0,
            notes: ""
        )
    }
    
    func pauseShift(_ shift: ShiftRecord, at date: Date = Date()) -> ShiftRecord {
        guard shift.status == .active else { return shift }
        var updated = shift
        updated.status = .paused
        updated.lastPauseStartTime = date
        return updated
    }
    
    func resumeShift(_ shift: ShiftRecord, at date: Date = Date()) -> ShiftRecord {
        guard shift.status == .paused else { return shift }
        var updated = shift
        if let pauseStart = updated.lastPauseStartTime {
            updated.accumulatedBreakSeconds += max(0, date.timeIntervalSince(pauseStart))
        }
        updated.lastPauseStartTime = nil
        updated.status = .active
        return updated
    }
    
    func endShift(_ shift: ShiftRecord, at date: Date = Date()) -> ShiftRecord {
        var updated = shift
        if updated.status == .paused, let pauseStart = updated.lastPauseStartTime {
            updated.accumulatedBreakSeconds += max(0, date.timeIntervalSince(pauseStart))
            updated.lastPauseStartTime = nil
        }
        updated.actualEndTime = date
        updated.status = .completed
        return updated
    }
    
    func applyRide(_ ride: RideHistoryRecord, to shift: ShiftRecord) -> ShiftRecord {
        var updated = shift
        updated.recordedRidesCount += 1
        if ride.status == .completed {
            updated.completedRidesCount += 1
            updated.totalRevenueVND += ride.totalIncomeVND
            updated.totalDistanceKm += ride.totalDistanceKm
            updated.totalWaitingMinutes += ride.waitingMinutesBeforeRide
        }
        return updated
    }
    
    /// Cảnh báo nghỉ ngơi định kỳ để đảm bảo an toàn, không khuyến khích chạy quá sức
    func safetyRestRecommendation(for shift: ShiftRecord, maxContinuousHours: Double = 4.0) -> String? {
        let activeHours = shift.activeWorkingHours()
        if activeHours >= maxContinuousHours {
            return "Bạn đã hoạt động liên tục \(Formatters.formatHours(activeHours)). Hãy tìm điểm dừng xe an toàn và nghỉ ngơi 15–20 phút để đảm bảo sức khỏe và sự tỉnh táo."
        } else if activeHours >= 2.5 && shift.accumulatedBreakSeconds < 600 {
            return "Gợi ý an toàn: Sau hơn 2,5 giờ chạy xe, bạn nên uống nước và thư giãn ngắn 10 phút."
        }
        return nil
    }
}
