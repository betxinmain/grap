//
//  StorageAndShiftTests.swift
//  RideAssistProTests
//

import XCTest
@testable import RideAssistPro

final class StorageAndShiftTests: XCTestCase {
    func testSaveAndReloadConfigurationPersistence() throws {
        let suiteName = "com.rideassistpro.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let storage = StorageService(userDefaults: defaults)
        
        let presets = RideCriteria.defaultPresets
        try storage.save(presets, forKey: AppConstants.StorageKeys.configurations)
        
        let loaded = storage.load([RideCriteria].self, forKey: AppConstants.StorageKeys.configurations)
        XCTAssertEqual(loaded?.count, presets.count)
        XCTAssertEqual(loaded?.first?.profileName, presets.first?.profileName)
        
        storage.clearAllAppData()
        XCTAssertNil(storage.load([RideCriteria].self, forKey: AppConstants.StorageKeys.configurations))
    }
    
    func testShiftLifecycleAndCSVExport() {
        let shiftService = ShiftService.shared
        var shift = shiftService.startNewShift(
            workingArea: "Quận 1",
            revenueGoalVND: 500_000,
            ridesGoalCount: 15,
            plannedDurationHours: 8,
            plannedBreakMinutes: 30,
            fuelBudgetVND: 60_000
        )
        XCTAssertEqual(shift.status, .active)
        
        let ride = RideHistoryRecord(
            id: UUID(),
            timestamp: Date(),
            shiftId: shift.id,
            pickupArea: "Quận 1",
            dropoffArea: "Quận 3",
            netFareVND: 30_000,
            tipOrBonusVND: 5_000,
            pickupDistanceKm: 0.8,
            tripDistanceKm: 3.2,
            durationMinutes: 14,
            waitingMinutesBeforeRide: 4,
            fuelCostEstimatedVND: 1_500,
            evaluationScore: 90,
            evaluationTier: "Rất phù hợp",
            status: .completed,
            notes: "Test CSV"
        )
        
        shift = shiftService.applyRide(ride, to: shift)
        XCTAssertEqual(shift.completedRidesCount, 1)
        XCTAssertEqual(shift.totalRevenueVND, 35_000)
        XCTAssertEqual(shift.remainingRevenueGoalVND, 465_000)
        
        shift = shiftService.endShift(shift)
        XCTAssertEqual(shift.status, .completed)
        XCTAssertNotNil(shift.actualEndTime)
        
        let csv = ExportService.shared.generateRideHistoryCSV(records: [ride])
        XCTAssertTrue(csv.contains("Quận 1"))
        XCTAssertTrue(csv.contains("35000"))
    }
}
