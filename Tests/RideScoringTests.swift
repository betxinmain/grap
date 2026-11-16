//
//  RideScoringTests.swift
//  RideAssistProTests
//

import XCTest
@testable import RideAssistPro

final class RideScoringTests: XCTestCase {
    private var scoringService: RideScoringService!
    private var defaultCriteria: RideCriteria!
    private var fuelSettings: FuelAndExpenseSettings!
    
    override func setUp() {
        super.setUp()
        scoringService = RideScoringService()
        defaultCriteria = RideCriteria.defaultPresets[0] // Chạy sáng (Cao điểm)
        fuelSettings = .standard
    }
    
    func testHighEfficiencyRideScoresAbove85() {
        let candidate = RideCandidate(
            netFareVND: 35_000,
            pickupDistanceKm: 0.4,
            tripDistanceKm: 3.0,
            estimatedDurationMinutes: 11,
            pickupArea: "Quận 1",
            dropoffArea: "Quận 3",
            destinationType: .priorityArea,
            returnTripLikelihood: .high,
            extraFeeOrTipVND: 5_000,
            notes: "Cuốc đẹp"
        )
        
        let result = scoringService.evaluateRide(
            candidate: candidate,
            criteria: defaultCriteria,
            fuelSettings: fuelSettings
        )
        
        switch result {
        case .success(let eval):
            XCTAssertGreaterThanOrEqual(eval.totalScore, 85)
            XCTAssertEqual(eval.tier, .highlySuitable)
            XCTAssertTrue(eval.passesFilterCriteria)
            XCTAssertFalse(eval.positiveReasons.isEmpty)
        case .failure(let error):
            XCTFail("Expected success but got error: \(error)")
        }
    }
    
    func testMissingCriticalFareDataReturnsFailure() {
        var invalidCandidate = RideCandidate.empty
        invalidCandidate.netFareVND = 0
        invalidCandidate.extraFeeOrTipVND = 0
        
        let result = scoringService.evaluateRide(
            candidate: invalidCandidate,
            criteria: defaultCriteria,
            fuelSettings: fuelSettings
        )
        
        XCTAssertEqual(result, .failure(.missingFare))
    }
    
    func testMissingDistanceReturnsFailure() {
        var invalidCandidate = RideCandidate.empty
        invalidCandidate.tripDistanceKm = 0
        
        let result = scoringService.evaluateRide(
            candidate: invalidCandidate,
            criteria: defaultCriteria,
            fuelSettings: fuelSettings
        )
        
        XCTAssertEqual(result, .failure(.missingDistance))
    }
    
    func testLowEfficiencyRideWithLongPickupScoresBelow50() {
        let poorCandidate = RideCandidate(
            netFareVND: 12_000,
            pickupDistanceKm: 4.5,
            tripDistanceKm: 2.0,
            estimatedDurationMinutes: 30,
            pickupArea: "Ngoại thành",
            dropoffArea: "Khu vắng",
            destinationType: .nonPriority,
            returnTripLikelihood: .low,
            extraFeeOrTipVND: 0,
            notes: ""
        )
        
        let result = scoringService.evaluateRide(
            candidate: poorCandidate,
            criteria: defaultCriteria,
            fuelSettings: fuelSettings
        )
        
        if case .success(let eval) = result {
            XCTAssertLessThan(eval.totalScore, 50)
            XCTAssertEqual(eval.tier, .lowEfficiency)
            XCTAssertFalse(eval.passesFilterCriteria)
        } else {
            XCTFail("Expected evaluation result")
        }
    }
}
