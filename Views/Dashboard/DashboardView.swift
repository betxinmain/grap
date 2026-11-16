//
//  DashboardView.swift
//  RideAssistPro
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var viewModel = DashboardViewModel()
    
    @State private var showIncomeFuelSheet = false
    @State private var showOfficialGrabSheet = false
    @State private var showAccountSafetySheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerBanner
                    activeShiftCard
                    primaryActionButtons
                    todayStatisticsGrid
                    readyCheckCard
                    quickAccessToolsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Ride Assist Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAccountSafetySheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(AppTheme.primaryGreen)
                            Text("An toàn P0")
                                .font(.caption.bold())
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showQuickRideScoringSheet = true
                    } label: {
                        Label("Chấm điểm cuốc", systemImage: "plus.magnifyingglass")
                            .font(.caption.bold())
                    }
                }
            }
            .onAppear {
                viewModel.refreshDeviceBatteryInfo()
            }
            .sheet(isPresented: $viewModel.showShiftOptimizerSheet) {
                ShiftOptimizerView()
            }
            .sheet(isPresented: $viewModel.showQuickRideScoringSheet) {
                RideFilterAndScoringView()
            }
            .sheet(isPresented: $viewModel.showShortcutGuideSheet) {
                ShortcutAndQuickResponseView()
            }
            .sheet(isPresented: $showIncomeFuelSheet) {
                IncomeAndFuelManagerView()
            }
            .sheet(isPresented: $showOfficialGrabSheet) {
                OfficialGrabFeaturesCenterView()
            }
            .sheet(isPresented: $showAccountSafetySheet) {
                AccountSafetyView()
            }
        }
    }
    
    private var headerBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppConstants.appVietnameseTitle)
                    .font(.caption.weight(.bold))
                    .foregroundColor(AppTheme.primaryGreen)
                Text("Chào \(appState.driverProfile.displayName) • \(appState.activeConfiguration.profileName)")
                    .font(.headline)
                if locationService.isAuthorizedWhenInUse {
                    Label(locationService.currentDistrictOrAreaName, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Label("Vị trí: Chưa bật (Bấm tab Bản đồ nếu cần)", systemImage: "location.slash")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if appState.isDemoMode {
                Text("DEMO")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.warningAmber.opacity(0.2))
                    .foregroundColor(AppTheme.warningAmber)
                    .cornerRadius(8)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var activeShiftCard: some View {
        let shift = appState.currentShift
        let statusText = shift?.status.rawValue ?? ShiftStatus.idle.rawValue
        let startTimeText = shift.map { Formatters.timeFormatter.string(from: $0.startTime) } ?? "--:--"
        let durationText = shift.map { Formatters.formatDuration(seconds: $0.activeWorkingDurationSeconds()) } ?? "0 phút"
        let currentArea = locationService.isAuthorizedWhenInUse
            ? locationService.currentDistrictOrAreaName
            : (shift?.workingArea ?? appState.driverProfile.preferredHomeArea)
        let revGoal = shift?.revenueGoalVND ?? appState.driverProfile.defaultDailyRevenueGoal
        let ridesGoal = shift?.ridesGoalCount ?? appState.driverProfile.defaultDailyRidesGoal
        let currentRev = shift?.totalRevenueVND ?? todayCompletedRevenue
        let progress = revGoal > 0 ? min(1.0, currentRev / revGoal) : 0
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(statusText, systemImage: shift?.status == .active ? "bolt.circle.fill" : "clock.badge.checkmark")
                    .font(.subheadline.bold())
                    .foregroundColor(shift?.status == .active ? AppTheme.primaryGreen : .secondary)
                Spacer()
                Button("Quản lý ca") {
                    viewModel.showShiftOptimizerSheet = true
                }
                .font(.caption.bold())
            }
            
            Divider()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                infoCell(title: "Giờ bắt đầu", value: startTimeText)
                infoCell(title: "Thời gian hoạt động", value: durationText)
                infoCell(title: "Khu vực hiện tại", value: currentArea)
                infoCell(title: "Mục tiêu số cuốc", value: "\(todayCompletedRidesCount)/\(ridesGoal) cuốc")
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Mục tiêu doanh thu: \(Formatters.formatVND(currentRev)) / \(Formatters.formatVND(revGoal))")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Text("\(Int(round(progress * 100)))%")
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                }
                ProgressView(value: progress)
                    .tint(AppTheme.primaryGreen)
            }
            
            if let shift = shift, let restWarning = ShiftService.shared.safetyRestRecommendation(for: shift, maxContinuousHours: appState.driverProfile.maxContinuousDrivingHours) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundColor(AppTheme.warningAmber)
                    Text(restWarning)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding(10)
                .background(AppTheme.warningAmber.opacity(0.15))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var primaryActionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if appState.currentShift == nil || appState.currentShift?.status == .completed {
                    Button {
                        let newShift = ShiftService.shared.startNewShift(
                            workingArea: appState.activeConfiguration.priorityAreas.joined(separator: ", "),
                            revenueGoalVND: appState.driverProfile.defaultDailyRevenueGoal,
                            ridesGoalCount: appState.driverProfile.defaultDailyRidesGoal,
                            plannedDurationHours: 8.0,
                            plannedBreakMinutes: 45,
                            fuelBudgetVND: 70_000
                        )
                        appState.currentShift = newShift
                        appState.persistHistoryAndShifts()
                    } label: {
                        Label("BẮT ĐẦU CA CHẠY", systemImage: "play.fill")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(AppTheme.primaryGreen)
                            .cornerRadius(AppTheme.buttonCornerRadius)
                    }
                } else {
                    Button {
                        if let current = appState.currentShift {
                            let ended = ShiftService.shared.endShift(current)
                            appState.shiftRecords.insert(ended, at: 0)
                            appState.currentShift = nil
                            appState.persistHistoryAndShifts()
                        }
                    } label: {
                        Label("KẾT THÚC CA CHẠY", systemImage: "stop.fill")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(AppTheme.dangerRed)
                            .cornerRadius(AppTheme.buttonCornerRadius)
                    }
                }
                
                Button {
                    viewModel.openAppleShortcutsApp {
                        viewModel.showShortcutGuideSheet = true
                    }
                } label: {
                    Label("MỞ GRAB DRIVER", systemImage: "arrow.up.forward.app.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(AppTheme.deepNavy)
                        .cornerRadius(AppTheme.buttonCornerRadius)
                }
            }
            
            HStack(spacing: 10) {
                Button {
                    appState.selectedTab = .opportunity
                } label: {
                    Label("PHÂN TÍCH HIỆU QUẢ", systemImage: "chart.xyaxis.line")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(AppTheme.primaryGreen.opacity(0.14))
                        .cornerRadius(AppTheme.buttonCornerRadius)
                }
                
                Button {
                    viewModel.showQuickRideScoringSheet = true
                } label: {
                    Label("ĐÁNH GIÁ & LƯU CUỐC", systemImage: "Checkmark.seal.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.accentTeal)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(AppTheme.accentTeal.opacity(0.14))
                        .cornerRadius(AppTheme.buttonCornerRadius)
                }
            }
        }
    }
    
    private var todayStatisticsGrid: some View {
        let completed = appState.todayCompletedRides
        let allRecordedToday = appState.rideHistory.filter { Calendar.current.isDateInToday($0.timestamp) }
        let revenue = completed.reduce(0.0) { $0 + $1.totalIncomeVND }
        let totalKm = completed.reduce(0.0) { $0 + $1.totalDistanceKm }
        let totalWait = completed.reduce(0.0) { $0 + $1.waitingMinutesBeforeRide }
        let avgWait = completed.isEmpty ? 0 : (totalWait / Double(completed.count))
        let activeHours: Double = {
            if let shift = appState.currentShift, shift.activeWorkingHours() > 0.05 {
                return shift.activeWorkingHours()
            }
            let rideHours = completed.reduce(0.0) { $0 + ($1.durationMinutes + $1.waitingMinutesBeforeRide) } / 60.0
            return rideHours
        }()
        let revPerHour = activeHours > 0 ? (revenue / activeHours) : 0
        let revPerKm = totalKm > 0 ? (revenue / totalKm) : 0
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Thống kê hôm nay (Dữ liệu thực tế đã ghi nhận)")
                    .font(.subheadline.bold())
                Spacer()
                Button("Chi phí & Xăng") {
                    showIncomeFuelSheet = true
                }
                .font(.caption.bold())
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statMetricBox(title: "Số cuốc đã ghi nhận", value: "\(allRecordedToday.count) cuốc", icon: "list.Clipboard.fill")
                statMetricBox(title: "Số cuốc hoàn thành", value: "\(completed.count) cuốc", icon: "checkmark.circle.fill")
                statMetricBox(title: "Doanh thu hôm nay", value: Formatters.formatVND(revenue), icon: "banknote.fill")
                statMetricBox(title: "TB mỗi giờ", value: "\(Formatters.formatVND(revPerHour))/h", icon: "speedometer")
                statMetricBox(title: "Quãng đường di chuyển", value: Formatters.formatDistanceKm(totalKm), icon: "road.lanes")
                statMetricBox(title: "Thời gian chờ TB", value: String(format: "%.0f phút", avgWait), icon: "hourglass")
            }
            
            HStack {
                Label("Hiệu quả theo km:", systemImage: "fuelpump.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Formatters.formatVND(revPerKm)) / km")
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.primaryGreen)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var readyCheckCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("BẢNG READY CHECK TRƯỚC CA CHẠY", systemImage: "checklist.checked")
                    .font(.subheadline.bold())
                Spacer()
                Text("Minh bạch API")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(6)
            }
            
            Text("Các mục hệ thống kiểm tra tự động bằng API công khai của iOS được hiển thị trực tiếp. Các mục iOS không cho phép đọc từ ứng dụng khác được đánh dấu 'Tự xác nhận'.")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Divider()
            
            // 1. Kết nối Internet (API hệ thống)
            readyCheckSystemRow(
                title: "1. Kết nối Internet",
                detail: networkMonitor.connectionType,
                isReady: networkMonitor.isConnected
            )
            
            // 2. Dịch vụ định vị & Quyền vị trí (API hệ thống)
            readyCheckSystemRow(
                title: "2. Vị trí & Quyền định vị iPhone",
                detail: locationService.authorizationStatusLabel,
                isReady: locationService.isAuthorizedWhenInUse
            )
            
            // 3. Mức pin iPhone (API hệ thống)
            readyCheckSystemRow(
                title: "3. Mức pin iPhone",
                detail: viewModel.batteryStateDescription,
                isReady: viewModel.batteryLevelPercent >= 25
            )
            
            // 4. Thông báo Grab Driver (Người dùng tự xác nhận - iOS không cho phép đọc trạng thái thông báo của app khác)
            Toggle(isOn: Binding(
                get: { appState.readyCheckState.userConfirmedGrabNotificationsOn },
                set: { newVal in
                    appState.readyCheckState.userConfirmedGrabNotificationsOn = newVal
                    appState.persistReadyCheck()
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("4. Thông báo Grab Driver đã bật")
                        .font(.caption.weight(.semibold))
                    Text("Người dùng tự xác nhận (iOS bảo mật cách ly giữa các ứng dụng)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // 5. Âm thanh iPhone (Người dùng tự xác nhận)
            Toggle(isOn: Binding(
                get: { appState.readyCheckState.userConfirmediPhoneSoundLoud },
                set: { newVal in
                    appState.readyCheckState.userConfirmediPhoneSoundLoud = newVal
                    appState.persistReadyCheck()
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("5. Âm lượng chuông & Tắt chế độ Tập trung")
                        .font(.caption.weight(.semibold))
                    Text("Người dùng tự xác nhận (Đảm bảo nghe rõ khi có cuốc)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // 6. Tính năng chính thức Grab đã kiểm tra (Người dùng tự xác nhận)
            Toggle(isOn: Binding(
                get: { appState.readyCheckState.userConfirmedOfficialGrabFeaturesChecked },
                set: { newVal in
                    appState.readyCheckState.userConfirmedOfficialGrabFeaturesChecked = newVal
                    appState.persistReadyCheck()
                }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("6. Đã kiểm tra Auto Accept / Điểm đến trên Grab Driver")
                        .font(.caption.weight(.semibold))
                    Text("Người dùng tự xác nhận trực tiếp trên ứng dụng Grab Driver")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var quickAccessToolsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trung tâm hỗ trợ hợp lệ")
                .font(.subheadline.bold())
            
            HStack(spacing: 10) {
                Button {
                    showOfficialGrabSheet = true
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "book.closed.fill")
                            .font(.title3)
                            .foregroundColor(AppTheme.primaryGreen)
                        Text("Tính năng Grab chính thức")
                            .font(.caption.bold())
                            .foregroundColor(.primary)
                        Text("GrabNow, Tự động nhận, Điểm đến")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                
                Button {
                    viewModel.showShortcutGuideSheet = true
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "bolt.horizontal.circle.fill")
                            .font(.title3)
                            .foregroundColor(AppTheme.accentTeal)
                        Text("Mở nhanh & Tối ưu chuông")
                            .font(.caption.bold())
                            .foregroundColor(.primary)
                        Text("Hướng dẫn Apple Shortcuts & Back Tap")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var todayCompletedRevenue: Double {
        appState.todayCompletedRides.reduce(0.0) { $0 + $1.totalIncomeVND }
    }
    
    private var todayCompletedRidesCount: Int {
        appState.todayCompletedRides.count
    }
    
    private func infoCell(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
        }
    }
    
    private func statMetricBox(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppTheme.primaryGreen)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline.bold())
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func readyCheckSystemRow(title: String, detail: String, isReady: Bool) -> some View {
        HStack {
            Image(systemName: isReady ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isReady ? AppTheme.primaryGreen : AppTheme.warningAmber)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                Text("Hệ thống iOS: \(detail)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }
}
