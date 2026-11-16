//
//  IncomeService.swift
//  RideAssistPro
//

import Foundation

final class IncomeService {
    static let shared = IncomeService()
    
    /// Tính toán các chỉ số tài chính theo đúng công thức tại Mục 14.2:
    /// - Doanh thu trung bình/km = Doanh thu / Tổng quãng đường
    /// - Doanh thu trung bình/giờ = Doanh thu / Tổng thời gian hoạt động
    /// - Chi phí nhiên liệu = (Tổng quãng đường / 100) × Mức tiêu hao lít/100 km × Giá xăng/lít
    /// - Lợi nhuận ước tính = Doanh thu - Chi phí nhiên liệu - Chi phí vận hành
    func calculateFinancialSummary(
        revenueVND: Double,
        totalDistanceKm: Double,
        totalActiveHours: Double,
        fuelSettings: FuelAndExpenseSettings,
        loggedExpenses: [ExpenseItem],
        includeConfiguredFixedCostWhenNoLogs: Bool = true
    ) -> FinancialCalculationSummary {
        let safeRevenue = max(0, revenueVND)
        let safeDistance = max(0, totalDistanceKm)
        let safeHours = max(0, totalActiveHours)
        
        let avgRevenuePerKm = safeDistance > 0 ? (safeRevenue / safeDistance) : 0
        let avgRevenuePerHour = safeHours > 0 ? (safeRevenue / safeHours) : 0
        
        let estimatedFuelCost = (safeDistance / 100.0) * max(0, fuelSettings.fuelConsumptionLitersPer100Km) * max(0, fuelSettings.fuelPricePerLiterVND)
        
        // Các chi phí vận hành ngoài xăng
        let nonFuelExpensesLogged = loggedExpenses
            .filter { $0.category != .fuel }
            .reduce(0.0) { $0 + max(0, $1.amountVND) }
        
        let configuredFixed = max(0, fuelSettings.totalFixedDailyOperatingCostVND)
        let operatingCostToUse: Double
        if nonFuelExpensesLogged > 0 {
            operatingCostToUse = nonFuelExpensesLogged
        } else if includeConfiguredFixedCostWhenNoLogs && (safeRevenue > 0 || safeDistance > 0) {
            operatingCostToUse = configuredFixed
        } else {
            operatingCostToUse = 0
        }
        
        let estimatedNetProfit = safeRevenue - estimatedFuelCost - operatingCostToUse
        
        return FinancialCalculationSummary(
            actualGrossRevenueVND: safeRevenue,
            actualDistanceKm: safeDistance,
            actualActiveHours: safeHours,
            averageRevenuePerKmVND: avgRevenuePerKm,
            averageRevenuePerHourVND: avgRevenuePerHour,
            estimatedFuelCostVND: estimatedFuelCost,
            actualLoggedExpensesVND: nonFuelExpensesLogged,
            configuredFixedOperatingCostVND: configuredFixed,
            totalOperatingCostUsedVND: operatingCostToUse,
            estimatedNetProfitVND: estimatedNetProfit
        )
    }
}
