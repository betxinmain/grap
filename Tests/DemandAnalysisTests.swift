//
//  DemandAnalysisTests.swift
//  RideAssistProTests
//

import XCTest
@testable import RideAssistPro

final class DemandAnalysisTests: XCTestCase {
    private var service: DemandAnalysisService!
    
    override func setUp() {
        super.setUp()
        service = DemandAnalysisService()
    }
    
    func testEmptyHistoryReturnsEmptyAreaAnalysisWithoutFakeData() {
        let areas = service.analyzeAreaPerformance(from: [])
        XCTAssertTrue(areas.isEmpty, "Không được tự tạo dữ liệu nhu cầu giả khi lịch sử trống")
    }
    
    func testAreaAnalysisAndConfidenceCalculation() {
        let now = Date()
        var records: [RideHistoryRecord] = []
        for i in 0..<10 {
            records.append(
                RideHistoryRecord(
                    id: UUID(),
                    timestamp: now.addingTimeInterval(Double(-i * 1800)),
                    shiftId: nil,
                    pickupArea: "Quận 1",
                    dropoffArea: "Quận 3",
                    netFareVND: 30_000,
                    tipOrBonusVND: 0,
                    pickupDistanceKm: 0.5,
                    tripDistanceKm: 3.0,
                    durationMinutes: 12,
                    waitingMinutesBeforeRide: 4,
                    fuelCostEstimatedVND: 1_400,
                    evaluationScore: 88,
                    evaluationTier: "Rất phù hợp",
                    status: .completed,
                    notes: ""
                )
            )
        }
        
        let summaries = service.analyzeAreaPerformance(from: records)
        XCTAssertEqual(summaries.count, 1)
        XCTAssertEqual(summaries.first?.areaName, "Quận 1")
        XCTAssertEqual(summaries.first?.completedRidesCount, 10)
        XCTAssertEqual(summaries.first?.confidence, .high)
    }
}
