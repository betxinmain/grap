//
//  OpportunityViewModel.swift
//  RideAssistPro
//

import Foundation
import CoreLocation

final class OpportunityViewModel: ObservableObject {
    @Published var areaSummaries: [AreaPerformanceSummary] = []
    @Published var timeSlotSummaries: [TimeSlotPerformanceSummary] = []
    @Published var nextAreaRecommendations: [NextAreaRecommendation] = []
    
    private let demandService = DemandAnalysisService.shared
    
    func refreshAnalysis(
        history: [RideHistoryRecord],
        slots: [TimeSlotConfig],
        savedLocations: [SavedDriverLocation],
        currentLocation: CLLocation?,
        remainingRevenueGoal: Double
    ) {
        areaSummaries = demandService.analyzeAreaPerformance(from: history)
        timeSlotSummaries = demandService.analyzeTimeSlots(from: history, slots: slots)
        nextAreaRecommendations = demandService.recommendNextAreas(
            currentLocation: currentLocation,
            savedLocations: savedLocations,
            history: history,
            remainingRevenueGoal: remainingRevenueGoal
        )
    }
    
    var bestPerformingArea: AreaPerformanceSummary? {
        areaSummaries.first
    }
    
    var highestRevenueArea: AreaPerformanceSummary? {
        areaSummaries.max(by: { $0.averageFareVND < $1.averageFareVND })
    }
    
    var lowestWaitArea: AreaPerformanceSummary? {
        areaSummaries.min(by: { $0.averageWaitingMinutes < $1.averageWaitingMinutes })
    }
    
    var lowestEfficiencyArea: AreaPerformanceSummary? {
        guard areaSummaries.count > 1 else { return nil }
        return areaSummaries.last
    }
    
    var bestTimeSlot: TimeSlotPerformanceSummary? {
        timeSlotSummaries
            .filter { $0.completedRidesCount > 0 }
            .max(by: { $0.averageRevenuePerHourVND < $1.averageRevenuePerHourVND })
    }
}
