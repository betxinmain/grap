//
//  OpportunityEngineView.swift
//  RideAssistPro
//

import SwiftUI

struct OpportunityEngineView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel = OpportunityViewModel()
    
    @State private var selectedSection: Int = 0
    @State private var showEditTimeSlotsSheet: Bool = false
    @State private var showRideScoringSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    disclaimerCard
                    
                    Picker("Chế độ xem", selection: $selectedSection) {
                        Text("Gợi ý tiếp theo").tag(0)
                        Text("Theo khu vực").tag(1)
                        Text("Theo khung giờ").tag(2)
                    }
                    .pickerStyle(.segmented)
                    
                    if appState.rideHistory.filter({ $0.status == .completed }).isEmpty {
                        insufficientDataCard
                    } else {
                        switch selectedSection {
                        case 0:
                            nextAreaRecommendationsSection
                        case 1:
                            areaAnalysisSection
                        default:
                            timeSlotAnalysisSection
                        }
                    }
                    
                    confidenceLegendCard
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Cơ hội cuốc cá nhân")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showRideScoringSheet = true
                    } label: {
                        Label("Chấm điểm cuốc", systemImage: "Slider.horizontal.3")
                    }
                }
            }
            .onAppear {
                refreshData()
            }
            .onChange(of: appState.rideHistory) { _ in
                refreshData()
            }
            .sheet(isPresented: $showEditTimeSlotsSheet) {
                TimeSlotEditorSheet()
            }
            .sheet(isPresented: $showRideScoringSheet) {
                RideFilterAndScoringView()
            }
        }
    }
    
    private func refreshData() {
        let remainingGoal = appState.currentShift?.remainingRevenueGoalVND ?? appState.driverProfile.defaultDailyRevenueGoal
        viewModel.refreshAnalysis(
            history: appState.rideHistory,
            slots: appState.timeSlotConfigs,
            savedLocations: appState.savedLocations,
            currentLocation: locationService.currentLocation,
            remainingRevenueGoal: remainingGoal
        )
    }
    
    private var disclaimerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .foregroundColor(AppTheme.primaryGreen)
                Text("SMART OPPORTUNITY ENGINE")
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.primaryGreen)
                Spacer()
            }
            Text("Phân tích khu vực và khung giờ dựa 100% trên dữ liệu chuyến xe thực tế do bạn ghi nhận. Ứng dụng không kiểm soát hệ thống điều phối của Grab và không tạo bản đồ nhiệt giả.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var insufficientDataCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 46))
                .foregroundColor(AppTheme.warningAmber)
            
            Text("CHƯA ĐỦ DỮ LIỆU PHÂN TÍCH")
                .font(.headline.bold())
            
            Text("Hiện chưa có chuyến xe hoàn thành nào được ghi nhận trên thiết bị. Ride Assist Pro tuyệt đối không tự bịa số liệu hay tạo bản đồ nhu cầu giả.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button {
                    showRideScoringSheet = true
                } label: {
                    Label("Ghi nhận chuyến thực tế", systemImage: "plus.circle.fill")
                        .font(.caption.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppTheme.primaryGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if !appState.isDemoMode {
                    Button {
                        appState.toggleDemoMode(true)
                    } label: {
                        Label("Bật chế độ Demo", systemImage: "sparkles")
                            .font(.caption.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(AppTheme.warningAmber.opacity(0.18))
                            .foregroundColor(AppTheme.warningAmber)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var nextAreaRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.shield.fill")
                    .foregroundColor(AppTheme.warningAmber)
                Text("Chỉ xem gợi ý và di chuyển khi bạn đã dừng xe an toàn.")
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
            }
            
            ForEach(viewModel.nextAreaRecommendations) { rec in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(rec.priorityAreaName)
                            .font(.headline)
                        Spacer()
                        confidenceBadge(rec.confidence)
                    }
                    
                    Text(rec.reason)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        Label("\(Formatters.formatVND(rec.historicalRevenuePerHourVND))/h", systemImage: "banknote")
                            .font(.caption.bold())
                            .foregroundColor(AppTheme.primaryGreen)
                        Label("Chờ TB: \(Int(round(rec.historicalAvgWaitMinutes)))p", systemImage: "hourglass")
                            .font(.caption)
                        if let dist = rec.distanceKmFromCurrent {
                            Label("Cách ~\(Formatters.formatDistanceKm(dist))", systemImage: "location")
                                .font(.caption)
                        }
                    }
                    
                    Text(rec.dataSourceExplanation)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(AppTheme.cardCornerRadius)
            }
        }
    }
    
    private var areaAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let best = viewModel.bestPerformingArea {
                highlightSummaryCard(
                    title: "Khu vực hoạt động hiệu quả nhất",
                    areaName: best.areaName,
                    detail: "Đạt \(Formatters.formatVND(best.averageRevenuePerHourVND))/giờ • Chờ TB \(Int(round(best.averageWaitingMinutes))) phút (\(best.completedRidesCount) cuốc)",
                    confidence: best.confidence
                )
            }
            if let highestFare = viewModel.highestRevenueArea {
                highlightSummaryCard(
                    title: "Khu vực có giá trị cuốc TB cao nhất",
                    areaName: highestFare.areaName,
                    detail: "Trung bình \(Formatters.formatVND(highestFare.averageFareVND))/cuốc • Tổng \(Formatters.formatVND(highestFare.totalRevenueVND))",
                    confidence: highestFare.confidence
                )
            }
            if let lowestWait = viewModel.lowestWaitArea {
                highlightSummaryCard(
                    title: "Khu vực có thời gian chờ thấp nhất",
                    areaName: lowestWait.areaName,
                    detail: "Thời gian chờ TB \(String(format: "%.1f", lowestWait.averageWaitingMinutes)) phút/cuốc",
                    confidence: lowestWait.confidence
                )
            }
            if let lowestEff = viewModel.lowestEfficiencyArea {
                highlightSummaryCard(
                    title: "Khu vực hiệu quả thấp hơn trong lịch sử",
                    areaName: lowestEff.areaName,
                    detail: "Đạt \(Formatters.formatVND(lowestEff.averageRevenuePerHourVND))/giờ • Chờ TB \(Int(round(lowestEff.averageWaitingMinutes))) phút",
                    confidence: lowestEff.confidence
                )
            }
            
            Text("Bảng xếp hạng chi tiết theo khu vực đã chạy")
                .font(.subheadline.bold())
                .padding(.top, 6)
            
            ForEach(viewModel.areaSummaries) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.areaName)
                            .font(.subheadline.bold())
                        Spacer()
                        confidenceBadge(item.confidence)
                    }
                    HStack {
                        Text("Số cuốc: \(item.completedRidesCount)")
                        Spacer()
                        Text("Doanh thu: \(Formatters.formatVND(item.totalRevenueVND))")
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("TB/giờ: \(Formatters.formatVND(item.averageRevenuePerHourVND))")
                        Spacer()
                        Text("TB/km: \(Formatters.formatVND(item.averageRevenuePerKmVND))")
                        Spacer()
                        Text("Chờ: \(String(format: "%.0f", item.averageWaitingMinutes))p")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private var timeSlotAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Thống kê 8 khung giờ cá nhân")
                    .font(.subheadline.bold())
                Spacer()
                Button("Chỉnh sửa khung giờ") {
                    showEditTimeSlotsSheet = true
                }
                .font(.caption.bold())
            }
            
            if let bestSlot = viewModel.bestTimeSlot {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Khung giờ hiệu quả nhất trong lịch sử của bạn")
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                    Text("\(bestSlot.slot.name) (\(bestSlot.slot.timeRangeLabel))")
                        .font(.headline)
                    Text("Hiệu suất cá nhân: ~\(Formatters.formatVND(bestSlot.averageRevenuePerHourVND))/giờ • Giá trị cuốc TB: \(Formatters.formatVND(bestSlot.averageFareVND))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Lưu ý: Đây là thống kê lịch sử cá nhân của bạn, không phải tuyên bố giờ cao điểm toàn hệ thống của Grab.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(AppTheme.cardCornerRadius)
            }
            
            ForEach(viewModel.timeSlotSummaries) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(item.slot.name) (\(item.slot.timeRangeLabel))")
                            .font(.subheadline.bold())
                        Spacer()
                        confidenceBadge(item.confidence)
                    }
                    if item.completedRidesCount == 0 {
                        Text("CHƯA ĐỦ DỮ LIỆU PHÂN TÍCH")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        HStack {
                            Text("Số cuốc: \(item.completedRidesCount) (TB \(String(format: "%.1f", item.averageRidesPerActiveDay))/ngày)")
                            Spacer()
                            Text("Giá cuốc TB: \(Formatters.formatVND(item.averageFareVND))")
                        }
                        .font(.caption)
                        
                        HStack {
                            Text("Hiệu quả/giờ: \(Formatters.formatVND(item.averageRevenuePerHourVND))")
                                .foregroundColor(AppTheme.primaryGreen)
                            Spacer()
                            Text("Thời gian chờ TB: \(String(format: "%.0f", item.averageWaitingMinutes)) phút")
                                .foregroundColor(.secondary)
                        }
                        .font(.caption)
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private var confidenceLegendCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Giải thích cấp độ tin cậy dữ liệu (Data Confidence)")
                .font(.caption.bold())
            ForEach(DataConfidenceLevel.allCases, id: \.rawValue) { level in
                HStack(alignment: .top, spacing: 6) {
                    confidenceBadge(level)
                    Text(level.explanation)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func highlightSummaryCard(title: String, areaName: String, detail: String, confidence: DataConfidenceLevel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Spacer()
                confidenceBadge(confidence)
            }
            Text(areaName)
                .font(.headline)
                .foregroundColor(AppTheme.primaryGreen)
            Text(detail)
                .font(.caption)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func confidenceBadge(_ level: DataConfidenceLevel) -> some View {
        let color: Color = {
            switch level {
            case .high: return AppTheme.primaryGreen
            case .medium: return AppTheme.accentTeal
            case .low: return AppTheme.warningAmber
            case .noData: return .secondary
            }
        }()
        return Text(level.rawValue)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.16))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct TimeSlotEditorSheet: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Chỉnh sửa giờ bắt đầu và kết thúc cho 8 khung giờ") {
                    ForEach($appState.timeSlotConfigs) { $slot in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Tên khung giờ", text: $slot.name)
                                .font(.subheadline.bold())
                            HStack {
                                Stepper("Từ \(slot.startHour):00", value: $slot.startHour, in: 0...23)
                                    .font(.caption)
                                Stepper("Đến \(slot.endHour):00", value: $slot.endHour, in: 0...23)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section {
                    Button("Khôi phục 8 khung giờ mặc định") {
                        appState.timeSlotConfigs = TimeSlotConfig.defaultSlots
                        appState.persistTimeSlots()
                    }
                    .foregroundColor(AppTheme.warningAmber)
                }
            }
            .navigationTitle("Cấu hình khung giờ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        appState.persistTimeSlots()
                        dismiss()
                    }
                }
            }
        }
    }
}
