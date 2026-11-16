//
//  PersonalDemandAnalyticsView.swift
//  RideAssistPro
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct PersonalDemandAnalyticsView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var showIncomeFuelSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    personalDataNoticeCard
                    
                    Picker("Khoảng thời gian", selection: $viewModel.selectedPeriod) {
                        ForEach(AnalyticsPeriodFilter.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    let rides = viewModel.filteredCompletedRides(from: appState.rideHistory)
                    if rides.isEmpty {
                        emptyAnalyticsState
                    } else {
                        overviewKPIsCard(rides: rides)
                        revenueChartCard(rides: rides)
                        hourlyChartCard(rides: rides)
                        areaEfficiencyComparisonCard(rides: rides)
                        personalInsightsCard(rides: rides)
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Phân tích cá nhân")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showIncomeFuelSheet = true
                    } label: {
                        Label("Tài chính & Xăng", systemImage: "fuelpump.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showIncomeFuelSheet) {
                IncomeAndFuelManagerView()
            }
        }
    }
    
    private var personalDataNoticeCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.badge.shield.checkmark.fill")
                .foregroundColor(AppTheme.primaryGreen)
            Text("Dữ liệu thống kê cá nhân qua các ca chạy do bạn tự ghi nhận. Không phải số liệu thống kê toàn hệ thống Grab.")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var emptyAnalyticsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("CHƯA ĐỦ DỮ LIỆU PHÂN TÍCH TRONG KỲ NÀY")
                .font(.subheadline.bold())
            Text("Hãy ghi nhận các chuyến xe hoàn thành hoặc chọn khoảng thời gian rộng hơn để xem biểu đồ doanh thu, khung giờ và lợi nhuận ròng.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func overviewKPIsCard(rides: [RideHistoryRecord]) -> some View {
        let totalRev = rides.reduce(0.0) { $0 + $1.totalIncomeVND }
        let totalKm = rides.reduce(0.0) { $0 + $1.totalDistanceKm }
        let totalHours = rides.reduce(0.0) { $0 + ($1.durationMinutes + $1.waitingMinutesBeforeRide) } / 60.0
        let avgFare = totalRev / Double(max(1, rides.count))
        let avgWait = rides.reduce(0.0) { $0 + $1.waitingMinutesBeforeRide } / Double(max(1, rides.count))
        
        let fin = IncomeService.shared.calculateFinancialSummary(
            revenueVND: totalRev,
            totalDistanceKm: totalKm,
            totalActiveHours: totalHours,
            fuelSettings: appState.fuelSettings,
            loggedExpenses: appState.expenseRecords
        )
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Tổng hợp hiệu suất kỳ đã chọn (\(rides.count) cuốc)")
                .font(.subheadline.bold())
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                kpiCell(label: "Doanh thu (Thực tế)", value: Formatters.formatVND(totalRev))
                kpiCell(label: "Lợi nhuận (Ước tính)", value: Formatters.formatVND(fin.estimatedNetProfitVND))
                kpiCell(label: "Giá trị cuốc TB", value: Formatters.formatVND(avgFare))
                kpiCell(label: "Doanh thu TB/giờ", value: Formatters.formatVND(fin.averageRevenuePerHourVND))
                kpiCell(label: "Doanh thu TB/km", value: Formatters.formatVND(fin.averageRevenuePerKmVND))
                kpiCell(label: "Thời gian chờ TB", value: String(format: "%.1f phút", avgWait))
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func revenueChartCard(rides: [RideHistoryRecord]) -> some View {
        let dailySeries = viewModel.dailyRevenueSeries(from: rides)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Biểu đồ Doanh thu cá nhân theo ngày")
                .font(.subheadline.bold())
            
            #if canImport(Charts)
            Chart(dailySeries) { point in
                BarMark(
                    x: .value("Ngày", point.dateLabel),
                    y: .value("Doanh thu", point.revenueVND)
                )
                .foregroundStyle(AppTheme.primaryGreen.gradient)
                .cornerRadius(6)
            }
            .frame(height: 190)
            #else
            ForEach(dailySeries) { point in
                HStack {
                    Text(point.dateLabel)
                    Spacer()
                    Text(Formatters.formatVND(point.revenueVND))
                        .bold()
                }
                .font(.caption)
            }
            #endif
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func hourlyChartCard(rides: [RideHistoryRecord]) -> some View {
        let hourly = viewModel.hourlyDistribution(from: rides)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Phân bố số cuốc cá nhân theo giờ trong ngày")
                .font(.subheadline.bold())
            
            #if canImport(Charts)
            Chart(hourly) { item in
                BarMark(
                    x: .value("Giờ", item.hourLabel),
                    y: .value("Số cuốc", item.rideCount)
                )
                .foregroundStyle(AppTheme.accentTeal.gradient)
            }
            .frame(height: 170)
            #endif
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func areaEfficiencyComparisonCard(rides: [RideHistoryRecord]) -> some View {
        let areas = DemandAnalysisService.shared.analyzeAreaPerformance(from: rides)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Hiệu quả theo khu vực (Doanh thu/giờ & Thời gian chờ)")
                .font(.subheadline.bold())
            
            ForEach(areas.prefix(5)) { area in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(area.areaName)
                            .font(.caption.bold())
                        Text("\(area.completedRidesCount) cuốc • Chờ TB \(Int(round(area.averageWaitingMinutes)))p")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(Formatters.formatVND(area.averageRevenuePerHourVND))/h")
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func personalInsightsCard(rides: [RideHistoryRecord]) -> some View {
        let areas = DemandAnalysisService.shared.analyzeAreaPerformance(from: rides)
        let slots = DemandAnalysisService.shared.analyzeTimeSlots(from: rides, slots: appState.timeSlotConfigs)
            .filter { $0.completedRidesCount > 0 }
        let bestSlot = slots.max(by: { $0.averageRevenuePerHourVND < $1.averageRevenuePerHourVND })
        let worstSlot = slots.min(by: { $0.averageRevenuePerHourVND < $1.averageRevenuePerHourVND })
        let dailySeries = viewModel.dailyRevenueSeries(from: rides)
        let bestDay = dailySeries.max(by: { $0.revenueVND < $1.revenueVND })
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Nhận định từ dữ liệu cá nhân của bạn")
                .font(.subheadline.bold())
            
            if let bestArea = areas.first {
                insightBullet("Khu vực hiệu quả nhất: \(bestArea.areaName) (~\(Formatters.formatVND(bestArea.averageRevenuePerHourVND))/giờ).")
            }
            if let bestSlot = bestSlot {
                insightBullet("Khung giờ tốt nhất: \(bestSlot.slot.name) (\(bestSlot.slot.timeRangeLabel)) với TB \(Formatters.formatVND(bestSlot.averageFareVND))/cuốc.")
            }
            if let worstSlot = worstSlot, slots.count > 1 {
                insightBullet("Khung giờ hoạt động kém hơn: \(worstSlot.slot.name) (Chờ TB \(Int(round(worstSlot.averageWaitingMinutes))) phút).")
            }
            if let bestDay = bestDay {
                insightBullet("Ngày hoạt động hiệu quả nhất: \(bestDay.dateLabel) (\(Formatters.formatVND(bestDay.revenueVND)) - \(bestDay.rideCount) cuốc).")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func kpiCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private func insightBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "sparkle")
                .foregroundColor(AppTheme.primaryGreen)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
    }
}
