//
//  IncomeRecord.swift
//  RideAssistPro
//

import Foundation

struct FuelAndExpenseSettings: Codable, Equatable {
    var fuelPricePerLiterVND: Double          // Ví dụ: 21.500 đ/lít
    var fuelConsumptionLitersPer100Km: Double // Ví dụ: 1.8 lít/100km (Honda Wave/Vision)
    var dailyParkingCostVND: Double           // Chi phí gửi xe
    var dailyMaintenanceReserveVND: Double    // Dự phòng bảo dưỡng/thay nhớt mỗi ngày
    var dailyOtherCostVND: Double             // Nước uống, 4G, chi phí khác
    var lastUpdated: Date
    
    var fuelCostPerKmVND: Double {
        (fuelConsumptionLitersPer100Km / 100.0) * fuelPricePerLiterVND
    }
    
    var totalFixedDailyOperatingCostVND: Double {
        dailyParkingCostVND + dailyMaintenanceReserveVND + dailyOtherCostVND
    }
    
    static let standard = FuelAndExpenseSettings(
        fuelPricePerLiterVND: 21_500,
        fuelConsumptionLitersPer100Km: 1.8,
        dailyParkingCostVND: 10_000,
        dailyMaintenanceReserveVND: 15_000,
        dailyOtherCostVND: 15_000,
        lastUpdated: Date()
    )
}

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case fuel = "Đổ xăng thực tế"
    case parking = "Gửi xe"
    case maintenance = "Bảo dưỡng / Thay nhớt"
    case mobileData = "Sim 4G / Điện thoại"
    case other = "Chi phí khác"
    
    var id: String { rawValue }
}

struct ExpenseItem: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var category: ExpenseCategory
    var amountVND: Double
    var note: String
}

struct FinancialCalculationSummary: Equatable {
    var actualGrossRevenueVND: Double
    var actualDistanceKm: Double
    var actualActiveHours: Double
    var averageRevenuePerKmVND: Double        // Thực tế: Doanh thu / Tổng quãng đường
    var averageRevenuePerHourVND: Double      // Thực tế: Doanh thu / Tổng thời gian hoạt động
    var estimatedFuelCostVND: Double          // Ước tính: (Tổng km / 100) * Lít/100km * Giá xăng/lít
    var actualLoggedExpensesVND: Double       // Thực tế đã ghi nhận
    var configuredFixedOperatingCostVND: Double
    var totalOperatingCostUsedVND: Double
    var estimatedNetProfitVND: Double         // Ước tính: Doanh thu - Chi phí nhiên liệu - Chi phí vận hành
}
