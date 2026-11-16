//
//  ShiftViewModel.swift
//  RideAssistPro
//

import Foundation

final class ShiftViewModel: ObservableObject {
    @Published var workingAreaInput: String = "Quận 1, Quận 3"
    @Published var revenueGoalInput: Double = 600_000
    @Published var ridesGoalInput: Int = 18
    @Published var plannedHoursInput: Double = 8.0
    @Published var plannedBreakMinutesInput: Int = 45
    @Published var fuelBudgetInput: Double = 70_000
    
    func syncDefaults(from profile: DriverProfile, activeConfig: RideCriteria) {
        workingAreaInput = activeConfig.priorityAreas.joined(separator: ", ")
        revenueGoalInput = profile.defaultDailyRevenueGoal
        ridesGoalInput = profile.defaultDailyRidesGoal
    }
}
