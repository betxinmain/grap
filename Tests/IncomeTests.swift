//
//  IncomeTests.swift
//  RideAssistProTests
//

import XCTest
@testable import RideAssistPro

final class IncomeTests: XCTestCase {
    func testFinancialFormulasMatchSpecification() {
        let settings = FuelAndExpenseSettings(
            fuelPricePerLiterVND: 20_000,
            fuelConsumptionLitersPer100Km: 2.0,
            dailyParkingCostVND: 10_000,
            dailyMaintenanceReserveVND: 10_000,
            dailyOtherCostVND: 10_000,
            lastUpdated: Date()
        )
        
        let summary = IncomeService.shared.calculateFinancialSummary(
            revenueVND: 500_000,
            totalDistanceKm: 100.0,
            totalActiveHours: 8.0,
            fuelSettings: settings,
            loggedExpenses: []
        )
        
        // Doanh thu TB/km = 500.000 / 100 = 5.000
        XCTAssertEqual(summary.averageRevenuePerKmVND, 5_000, accuracy: 0.01)
        // Doanh thu TB/giờ = 500.000 / 8 = 62.500
        XCTAssertEqual(summary.averageRevenuePerHourVND, 62_500, accuracy: 0.01)
        // Chi phí nhiên liệu = (100 / 100) * 2.0 * 20.000 = 40.000
        XCTAssertEqual(summary.estimatedFuelCostVND, 40_000, accuracy: 0.01)
        // Chi phí vận hành cố định = 30.000
        XCTAssertEqual(summary.totalOperatingCostUsedVND, 30_000, accuracy: 0.01)
        // Lợi nhuận ước tính = 500.000 - 40.000 - 30.000 = 430.000
        XCTAssertEqual(summary.estimatedNetProfitVND, 430_000, accuracy: 0.01)
    }
}
