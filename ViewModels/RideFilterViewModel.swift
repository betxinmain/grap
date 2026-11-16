//
//  RideFilterViewModel.swift
//  RideAssistPro
//

import Foundation

final class RideFilterViewModel: ObservableObject {
    @Published var candidate: RideCandidate = .empty
    @Published var waitingMinutesBeforeRide: Double = 5
    @Published var latestEvaluation: RideEvaluation?
    @Published var scoringErrorMessage: String?
    @Published var showSaveConfirmation: Bool = false
    
    private let scoringService: RideScoringServiceProtocol
    
    init(scoringService: RideScoringServiceProtocol = RideScoringService.shared) {
        self.scoringService = scoringService
    }
    
    func evaluateCurrentCandidate(criteria: RideCriteria, fuelSettings: FuelAndExpenseSettings) {
        scoringErrorMessage = nil
        let result = scoringService.evaluateRide(
            candidate: candidate,
            criteria: criteria,
            fuelSettings: fuelSettings
        )
        switch result {
        case .success(let evaluation):
            latestEvaluation = evaluation
        case .failure(let error):
            latestEvaluation = nil
            scoringErrorMessage = error.errorDescription
        }
    }
    
    func buildHistoryRecord(
        status: RideCompletionStatus,
        shiftId: UUID?,
        latitude: Double?,
        longitude: Double?,
        fuelSettings: FuelAndExpenseSettings
    ) -> RideHistoryRecord {
        let totalKm = candidate.totalDistanceKm
        let fuelCost = (totalKm / 100.0) * fuelSettings.fuelConsumptionLitersPer100Km * fuelSettings.fuelPricePerLiterVND
        return RideHistoryRecord(
            id: UUID(),
            timestamp: Date(),
            shiftId: shiftId,
            pickupArea: candidate.pickupArea.isEmpty ? "Chưa ghi khu vực" : candidate.pickupArea,
            dropoffArea: candidate.dropoffArea.isEmpty ? "Chưa ghi điểm trả" : candidate.dropoffArea,
            netFareVND: candidate.netFareVND,
            tipOrBonusVND: candidate.extraFeeOrTipVND,
            pickupDistanceKm: candidate.pickupDistanceKm,
            tripDistanceKm: candidate.tripDistanceKm,
            durationMinutes: candidate.estimatedDurationMinutes,
            waitingMinutesBeforeRide: waitingMinutesBeforeRide,
            fuelCostEstimatedVND: fuelCost,
            evaluationScore: latestEvaluation?.totalScore,
            evaluationTier: latestEvaluation?.tier.rawValue,
            status: status,
            notes: candidate.notes,
            latitude: latitude,
            longitude: longitude
        )
    }
}
