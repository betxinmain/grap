//
//  ShiftAndIncomeViews.swift
//  RideAssistPro
//

import SwiftUI

struct ShiftOptimizerView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ShiftViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    safetyHealthBanner
                    
                    if let activeShift = appState.currentShift {
                        activeShiftManagementCard(activeShift)
                    } else {
                        newShiftSetupCard
                    }
                    
                    pastShiftsHistorySection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Quản lý Ca chạy (Shift Optimizer)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
            .onAppear {
                viewModel.syncDefaults(
                    from: appState.driverProfile,
                    activeConfig: appState.activeConfiguration
                )
            }
        }
    }
    
    private var safetyHealthBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "heart.text.square.fill")
                .font(.title3)
                .foregroundColor(AppTheme.primaryGreen)
            Text("Nguyên tắc an toàn: Không khuyến khích lái xe quá thời gian an toàn chỉ để đạt mục tiêu doanh thu. Hãy nghỉ ngơi định kỳ sau mỗi 2,5 – 4 giờ chạy xe.")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func activeShiftManagementCard(_ shift: ShiftRecord) -> some View {
        let fin = IncomeService.shared.calculateFinancialSummary(
            revenueVND: shift.totalRevenueVND,
            totalDistanceKm: shift.totalDistanceKm,
            totalActiveHours: max(0.1, shift.activeWorkingHours()),
            fuelSettings: appState.fuelSettings,
            loggedExpenses: []
        )
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trạng thái: \(shift.status.rawValue)")
                    .font(.headline)
                    .foregroundColor(shift.status == .active ? AppTheme.primaryGreen : AppTheme.warningAmber)
                Spacer()
                Text("Bắt đầu: \(Formatters.timeFormatter.string(from: shift.startTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                shiftMetric(title: "Doanh thu hiện tại (Thực tế)", value: Formatters.formatVND(shift.totalRevenueVND))
                shiftMetric(title: "Mục tiêu còn thiếu", value: Formatters.formatVND(shift.remainingRevenueGoalVND))
                shiftMetric(title: "Số cuốc hoàn thành", value: "\(shift.completedRidesCount) / \(shift.ridesGoalCount)")
                shiftMetric(title: "Số cuốc còn thiếu", value: "\(shift.remainingRidesGoalCount) cuốc")
                shiftMetric(title: "Số giờ hoạt động", value: Formatters.formatDuration(seconds: shift.activeWorkingDurationSeconds()))
                shiftMetric(title: "Doanh thu TB/giờ", value: Formatters.formatVND(shift.revenuePerHourVND()))
                shiftMetric(title: "Chi phí xăng (Ước tính)", value: Formatters.formatVND(fin.estimatedFuelCostVND))
                shiftMetric(title: "Lợi nhuận ròng (Ước tính)", value: Formatters.formatVND(fin.estimatedNetProfitVND))
            }
            
            HStack(spacing: 10) {
                if shift.status == .active {
                    Button {
                        appState.currentShift = ShiftService.shared.pauseShift(shift)
                        appState.persistHistoryAndShifts()
                    } label: {
                        Label("Tạm nghỉ giải lao", systemImage: "pause.circle.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(AppTheme.warningAmber.opacity(0.18))
                            .foregroundColor(AppTheme.warningAmber)
                            .cornerRadius(12)
                    }
                } else if shift.status == .paused {
                    Button {
                        appState.currentShift = ShiftService.shared.resumeShift(shift)
                        appState.persistHistoryAndShifts()
                    } label: {
                        Label("Tiếp tục ca chạy", systemImage: "play.circle.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(AppTheme.primaryGreen)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                
                Button(role: .destructive) {
                    let ended = ShiftService.shared.endShift(shift)
                    appState.shiftRecords.insert(ended, at: 0)
                    appState.currentShift = nil
                    appState.persistHistoryAndShifts()
                } label: {
                    Label("Kết thúc ca", systemImage: "stop.circle.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(AppTheme.dangerRed)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var newShiftSetupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thiết lập ca làm việc mới")
                .font(.subheadline.bold())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Khu vực làm việc dự kiến")
                    .font(.caption)
                TextField("Quận 1, Quận 3", text: $viewModel.workingAreaInput)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mục tiêu doanh thu (VNĐ)")
                        .font(.caption)
                    TextField("600000", value: $viewModel.revenueGoalInput, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mục tiêu số chuyến")
                        .font(.caption)
                    TextField("18", value: $viewModel.ridesGoalInput, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Số giờ dự kiến chạy")
                        .font(.caption)
                    TextField("8", value: $viewModel.plannedHoursInput, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thời gian nghỉ (phút)")
                        .font(.caption)
                    TextField("45", value: $viewModel.plannedBreakMinutesInput, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ngân sách xăng (VNĐ)")
                        .font(.caption)
                    TextField("70000", value: $viewModel.fuelBudgetInput, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            Button {
                let shift = ShiftService.shared.startNewShift(
                    workingArea: viewModel.workingAreaInput,
                    revenueGoalVND: viewModel.revenueGoalInput,
                    ridesGoalCount: viewModel.ridesGoalInput,
                    plannedDurationHours: viewModel.plannedHoursInput,
                    plannedBreakMinutes: viewModel.plannedBreakMinutesInput,
                    fuelBudgetVND: viewModel.fuelBudgetInput
                )
                appState.currentShift = shift
                appState.persistHistoryAndShifts()
            } label: {
                Label("BẮT ĐẦU CA LÀM VIỆC", systemImage: "play.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(AppTheme.primaryGreen)
                    .cornerRadius(AppTheme.buttonCornerRadius)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var pastShiftsHistorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lịch sử các ca chạy đã kết thúc (\(appState.shiftRecords.count))")
                .font(.subheadline.bold())
            
            if appState.shiftRecords.isEmpty {
                Text("Chưa có ca chạy nào kết thúc.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(appState.shiftRecords) { record in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(Formatters.dateTimeFormatter.string(from: record.startTime))
                                .font(.caption.bold())
                            Spacer()
                            Text(Formatters.formatVND(record.totalRevenueVND))
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.primaryGreen)
                        }
                        Text("Hoàn thành: \(record.completedRidesCount) cuốc • Quãng đường: \(Formatters.formatDistanceKm(record.totalDistanceKm)) • Khu vực: \(record.workingArea)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private func shiftMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct IncomeAndFuelManagerView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var newExpenseCategory: ExpenseCategory = .fuel
    @State private var newExpenseAmount: Double = 50_000
    @State private var newExpenseNote: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    financialSummaryCard
                    fuelConfigurationCard
                    logNewExpenseCard
                    expenseHistorySection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tài chính & Nhiên liệu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        appState.persistFuelAndExpenses()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var financialSummaryCard: some View {
        let completedRides = appState.todayCompletedRides
        let revenue = completedRides.reduce(0.0) { $0 + $1.totalIncomeVND }
        let distance = completedRides.reduce(0.0) { $0 + $1.totalDistanceKm }
        let hours = completedRides.reduce(0.0) { $0 + ($1.durationMinutes + $1.waitingMinutesBeforeRide) } / 60.0
        let todayExpenses = appState.expenseRecords.filter { Calendar.current.isDateInToday($0.date) }
        
        let summary = IncomeService.shared.calculateFinancialSummary(
            revenueVND: revenue,
            totalDistanceKm: distance,
            totalActiveHours: hours,
            fuelSettings: appState.fuelSettings,
            loggedExpenses: todayExpenses
        )
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("Báo cáo tài chính hôm nay (Phân biệt Thực tế vs. Ước tính)")
                .font(.subheadline.bold())
            
            Group {
                finRow(label: "Tổng doanh thu ghi nhận", value: Formatters.formatVND(summary.actualGrossRevenueVND), badge: "THỰC TẾ")
                finRow(label: "Tổng quãng đường đã chạy", value: Formatters.formatDistanceKm(summary.actualDistanceKm), badge: "THỰC TẾ")
                finRow(label: "Doanh thu trung bình / km", value: "\(Formatters.formatVND(summary.averageRevenuePerKmVND)) / km", badge: "THỰC TẾ")
                finRow(label: "Doanh thu trung bình / giờ", value: "\(Formatters.formatVND(summary.averageRevenuePerHourVND)) / giờ", badge: "THỰC TẾ")
                Divider()
                finRow(label: "Chi phí nhiên liệu theo công thức", value: Formatters.formatVND(summary.estimatedFuelCostVND), badge: "ƯỚC TÍNH")
                finRow(label: "Chi phí vận hành (Gửi xe, bảo dưỡng, khác)", value: Formatters.formatVND(summary.totalOperatingCostUsedVND), badge: summary.actualLoggedExpensesVND > 0 ? "THỰC TẾ" : "ƯỚC TÍNH")
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LỢI NHUẬN RÒNG ƯỚC TÍNH")
                            .font(.subheadline.bold())
                        Text("= Doanh thu - Chi phí nhiên liệu - Chi phí vận hành")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(Formatters.formatVND(summary.estimatedNetProfitVND))
                        .font(.title3.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var fuelConfigurationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Thiết lập định mức xăng & chi phí cố định hàng ngày")
                .font(.subheadline.bold())
            
            HStack {
                Text("Giá xăng (VNĐ/lít)")
                    .font(.caption)
                Spacer()
                TextField("21500", value: $appState.fuelSettings.fuelPricePerLiterVND, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }
            
            HStack {
                Text("Mức tiêu hao (Lít / 100 km)")
                    .font(.caption)
                Spacer()
                TextField("1.8", value: $appState.fuelSettings.fuelConsumptionLitersPer100Km, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }
            
            HStack {
                Text("Chi phí gửi xe / ngày (VNĐ)")
                    .font(.caption)
                Spacer()
                TextField("10000", value: $appState.fuelSettings.dailyParkingCostVND, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }
            
            HStack {
                Text("Trích khấu hao bảo dưỡng / ngày (VNĐ)")
                    .font(.caption)
                Spacer()
                TextField("15000", value: $appState.fuelSettings.dailyMaintenanceReserveVND, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }
            
            HStack {
                Text("Chi phí khác / ngày (Nước, 4G...)")
                    .font(.caption)
                Spacer()
                TextField("15000", value: $appState.fuelSettings.dailyOtherCostVND, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }
            
            Text("Chi phí xăng ước tính mỗi km hiện tại: \(Formatters.formatVND(appState.fuelSettings.fuelCostPerKmVND))/km")
                .font(.caption2)
                .foregroundColor(AppTheme.primaryGreen)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var logNewExpenseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ghi nhận khoản chi thực tế phát sinh")
                .font(.subheadline.bold())
            
            Picker("Loại chi phí", selection: $newExpenseCategory) {
                ForEach(ExpenseCategory.allCases) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(.menu)
            
            HStack {
                TextField("Số tiền VNĐ", value: $newExpenseAmount, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                TextField("Ghi chú", text: $newExpenseNote)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button {
                let item = ExpenseItem(
                    category: newExpenseCategory,
                    amountVND: newExpenseAmount,
                    note: newExpenseNote
                )
                appState.expenseRecords.insert(item, at: 0)
                appState.persistFuelAndExpenses()
                newExpenseNote = ""
            } label: {
                Label("Thêm khoản chi thực tế", systemImage: "plus.circle.fill")
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(AppTheme.primaryGreen)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var expenseHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Danh sách khoản chi đã ghi (\(appState.expenseRecords.count))")
                .font(.subheadline.bold())
            
            ForEach(appState.expenseRecords) { exp in
                HStack {
                    VStack(alignment: .leading) {
                        Text(exp.category.rawValue)
                            .font(.caption.bold())
                        Text("\(Formatters.dateTimeFormatter.string(from: exp.date)) \(exp.note.isEmpty ? "" : "• \(exp.note)")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(Formatters.formatVND(exp.amountVND))
                        .font(.caption.bold())
                }
                .padding(10)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(8)
            }
        }
    }
    
    private func finRow(label: String, value: String, badge: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
            Text(badge)
                .font(.system(size: 9, weight: .bold))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(badge == "THỰC TẾ" ? AppTheme.primaryGreen.opacity(0.15) : AppTheme.warningAmber.opacity(0.15))
                .foregroundColor(badge == "THỰC TẾ" ? AppTheme.primaryGreen : AppTheme.warningAmber)
                .cornerRadius(4)
            Spacer()
            Text(value)
                .font(.caption.bold())
        }
    }
}
