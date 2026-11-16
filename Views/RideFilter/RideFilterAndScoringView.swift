//
//  RideFilterAndScoringView.swift
//  RideAssistPro
//

import SwiftUI

struct RideFilterAndScoringView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RideFilterViewModel()
    
    @State private var showWeightEditor = false
    @State private var savedToastMessage: String?
    
    private let quickFareOptions: [Double] = [15_000, 20_000, 25_000, 30_000, 40_000]
    private let quickPickupKmOptions: [Double?] = [1.0, 2.0, 3.0, 5.0, nil]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    activeProfileHeader
                    filterQuickSettingsCard
                    candidateInputCard
                    evaluateButton
                    
                    if let errorMsg = viewModel.scoringErrorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(AppTheme.dangerRed)
                            Text(errorMsg)
                                .font(.caption.bold())
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.dangerRed.opacity(0.12))
                        .cornerRadius(12)
                    }
                    
                    if let evaluation = viewModel.latestEvaluation {
                        evaluationResultDetailCard(evaluation)
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Lọc & Chấm điểm cuốc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Trọng số (%)") {
                        showWeightEditor = true
                    }
                    .font(.caption.bold())
                }
            }
            .sheet(isPresented: $showWeightEditor) {
                ScoringWeightEditorSheet()
            }
        }
    }
    
    private var activeProfileHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Cấu hình đang dùng:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Menu {
                    ForEach(appState.configurations) { cfg in
                        Button {
                            appState.activeConfigurationId = cfg.id
                            appState.persistConfigurations()
                        } label: {
                            HStack {
                                Text(cfg.profileName)
                                if cfg.id == appState.activeConfigurationId {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(appState.activeConfiguration.profileName)
                            .font(.subheadline.bold())
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(AppTheme.primaryGreen)
                }
            }
            
            Text("Bộ lọc này chỉ dùng để đánh giá thông tin chuyến do bạn cung cấp hoặc ghi nhận sau chuyến. Ứng dụng không kết nối vào màn hình Grab và không tự động từ chối cuốc.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var filterQuickSettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("1. Tiêu chí Bộ lọc nhanh (Smart Ride Filter)")
                .font(.subheadline.bold())
            
            // 7.1 Giá trị chuyến tối thiểu
            VStack(alignment: .leading, spacing: 6) {
                Text("Giá trị chuyến tối thiểu: \(Formatters.formatVND(appState.activeConfiguration.minimumFareVND))")
                    .font(.caption.weight(.semibold))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickFareOptions, id: \.self) { amount in
                            let isSelected = appState.activeConfiguration.minimumFareVND == amount
                            Button {
                                var cfg = appState.activeConfiguration
                                cfg.minimumFareVND = amount
                                appState.activeConfiguration = cfg
                            } label: {
                                Text(Formatters.formatShortVND(amount))
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? AppTheme.primaryGreen : Color(.tertiarySystemGroupedBackground))
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            // 7.2 Khoảng cách đón tối đa
            VStack(alignment: .leading, spacing: 6) {
                let currentPickupLabel = appState.activeConfiguration.maxPickupDistanceKm.map { Formatters.formatDistanceKm($0) } ?? "Không giới hạn"
                Text("Khoảng cách đón tối đa: \(currentPickupLabel)")
                    .font(.caption.weight(.semibold))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(quickPickupKmOptions.enumerated()), id: \.offset) { _, option in
                            let isSelected = appState.activeConfiguration.maxPickupDistanceKm == option
                            let label = option.map { "\(Int($0)) km" } ?? "Không giới hạn"
                            Button {
                                var cfg = appState.activeConfiguration
                                cfg.maxPickupDistanceKm = option
                                appState.activeConfiguration = cfg
                            } label: {
                                Text(label)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? AppTheme.primaryGreen : Color(.tertiarySystemGroupedBackground))
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            // 7.5 Chế độ lọc STRICT / BALANCED / FLEXIBLE
            VStack(alignment: .leading, spacing: 6) {
                Text("Chế độ lọc: \(appState.activeConfiguration.filterMode.displayName)")
                    .font(.caption.weight(.semibold))
                Picker("Chế độ lọc", selection: Binding(
                    get: { appState.activeConfiguration.filterMode },
                    set: { newMode in
                        var cfg = appState.activeConfiguration
                        cfg.filterMode = newMode
                        appState.activeConfiguration = cfg
                    }
                )) {
                    ForEach(FilterMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                Text(appState.activeConfiguration.filterMode.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var candidateInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2. Thông tin chuyến xe cần đánh giá / ghi nhận")
                .font(.subheadline.bold())
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cước thực nhận (VNĐ)")
                        .font(.caption)
                    TextField("25000", value: $viewModel.candidate.netFareVND, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tip / Thưởng thêm (VNĐ)")
                        .font(.caption)
                    TextField("0", value: $viewModel.candidate.extraFeeOrTipVND, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Khoảng cách đón (km)")
                        .font(.caption)
                    TextField("1.0", value: $viewModel.candidate.pickupDistanceKm, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quãng đường chở khách (km)")
                        .font(.caption)
                    TextField("3.5", value: $viewModel.candidate.tripDistanceKm, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thời gian chạy dự kiến (phút)")
                        .font(.caption)
                    TextField("15", value: $viewModel.candidate.estimatedDurationMinutes, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thời gian chờ trước cuốc (phút)")
                        .font(.caption)
                    TextField("5", value: $viewModel.waitingMinutesBeforeRide, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Khu vực đón khách")
                        .font(.caption)
                    TextField("Ví dụ: Quận 1", text: $viewModel.candidate.pickupArea)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Khu vực trả khách")
                        .font(.caption)
                    TextField("Ví dụ: Quận 3", text: $viewModel.candidate.dropoffArea)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Đánh giá điểm đến")
                    .font(.caption)
                Picker("Điểm đến", selection: $viewModel.candidate.destinationType) {
                    ForEach(DestinationPreferenceType.allCases) { dtype in
                        Text(dtype.rawValue).tag(dtype)
                    }
                }
                .pickerStyle(.menu)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Khả năng có chuyến chiều về")
                    .font(.caption)
                Picker("Chiều về", selection: $viewModel.candidate.returnTripLikelihood) {
                    ForEach(ReturnTripLikelihood.allCases) { rtype in
                        Text(rtype.rawValue).tag(rtype)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            TextField("Ghi chú chuyến (tuỳ chọn)", text: $viewModel.candidate.notes)
                .textFieldStyle(.roundedBorder)
                .font(.caption)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var evaluateButton: some View {
        Button {
            viewModel.evaluateCurrentCandidate(
                criteria: appState.activeConfiguration,
                fuelSettings: appState.fuelSettings
            )
        } label: {
            Label("CHẤM ĐIỂM HIỆU QUẢ CUỐC XE (0 – 100)", systemImage: "gauge.with.dots.needle.67percent")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(AppTheme.primaryGreen)
                .cornerRadius(AppTheme.buttonCornerRadius)
        }
    }
    
    private func evaluationResultDetailCard(_ eval: RideEvaluation) -> some View {
        let tierColor: Color = {
            switch eval.tier {
            case .highlySuitable: return AppTheme.primaryGreen
            case .suitable: return AppTheme.accentTeal
            case .consider: return AppTheme.warningAmber
            case .lowEfficiency: return AppTheme.dangerRed
            }
        }()
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("KẾT QUẢ CHẤM ĐIỂM CUỐC XE")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Text(eval.tier.rawValue.uppercased())
                        .font(.title3.bold())
                        .foregroundColor(tierColor)
                    Text("\(eval.rideLengthClassification) • Chế độ \(eval.filterMode.rawValue): \(eval.passesFilterCriteria ? "ĐẠT TIÊU CHÍ" : "CHƯA ĐẠT")")
                        .font(.caption.bold())
                        .foregroundColor(eval.passesFilterCriteria ? AppTheme.primaryGreen : AppTheme.warningAmber)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(tierColor.opacity(0.25), lineWidth: 8)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: CGFloat(eval.totalScore) / 100.0)
                        .stroke(tierColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 72, height: 72)
                    VStack(spacing: 0) {
                        Text("\(eval.totalScore)")
                            .font(.title2.bold())
                            .foregroundColor(tierColor)
                        Text("/100")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                metricRow(title: "Doanh thu / km", value: "\(Formatters.formatVND(eval.revenuePerKmVND))/km")
                metricRow(title: "Doanh thu / giờ", value: "\(Formatters.formatVND(eval.revenuePerHourVND))/h")
                metricRow(title: "Xăng ước tính", value: Formatters.formatVND(eval.estimatedFuelCostVND))
                metricRow(title: "Lợi nhuận ròng ước tính", value: Formatters.formatVND(eval.estimatedNetProfitVND))
            }
            
            if !eval.positiveReasons.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Điểm cộng của chuyến này:")
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                    ForEach(eval.positiveReasons, id: \.self) { reason in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.primaryGreen)
                            Text(reason)
                                .font(.caption)
                        }
                    }
                }
            }
            
            if !eval.warningReasons.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Điểm cần lưu ý / Hạn chế:")
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.warningAmber)
                    ForEach(eval.warningReasons, id: \.self) { reason in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(AppTheme.warningAmber)
                            Text(reason)
                                .font(.caption)
                        }
                    }
                }
            }
            
            Text(eval.personalAssessmentNote)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 10) {
                Button {
                    saveRide(status: .completed)
                } label: {
                    Label("Lưu thành cuốc hoàn thành", systemImage: "checkmark.seal.fill")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(AppTheme.primaryGreen)
                        .cornerRadius(10)
                }
                
                Button {
                    saveRide(status: .evaluatedOnly)
                } label: {
                    Label("Chỉ lưu kết quả chấm", systemImage: "bookmark.fill")
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.accentTeal)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(AppTheme.accentTeal.opacity(0.15))
                        .cornerRadius(10)
                }
            }
            
            if let toast = savedToastMessage {
                Text(toast)
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.primaryGreen)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func saveRide(status: RideCompletionStatus) {
        let record = viewModel.buildHistoryRecord(
            status: status,
            shiftId: appState.currentShift?.id,
            latitude: locationService.currentLocation?.coordinate.latitude,
            longitude: locationService.currentLocation?.coordinate.longitude,
            fuelSettings: appState.fuelSettings
        )
        appState.addRideRecord(record)
        savedToastMessage = "Đã lưu vào Lịch sử & Cập nhật thống kê ca chạy!"
    }
    
    private func metricRow(title: String, value: String) -> some View {
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

struct ScoringWeightEditorSheet: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    @State private var weights: ScoringWeights = .standard
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Chỉnh sửa trọng số chấm điểm cuốc") {
                    weightSlider(title: "Giá cuốc", value: $weights.fareWeight)
                    weightSlider(title: "Khoảng cách đón", value: $weights.pickupDistanceWeight)
                    weightSlider(title: "Hiệu quả / km", value: $weights.efficiencyPerKmWeight)
                    weightSlider(title: "Hiệu quả / giờ", value: $weights.efficiencyPerHourWeight)
                    weightSlider(title: "Điểm đến & chiều về", value: $weights.destinationWeight)
                    weightSlider(title: "Chi phí vận hành", value: $weights.operatingCostWeight)
                }
                
                Section {
                    HStack {
                        Text("Tổng trọng số hiện tại")
                        Spacer()
                        Text("\(Int(weights.totalWeight))%")
                            .font(.headline)
                            .foregroundColor(weights.totalWeight == 100 ? AppTheme.primaryGreen : AppTheme.warningAmber)
                    }
                    Button("Khôi phục chuẩn (25/15/20/20/10/10)") {
                        weights = .standard
                    }
                }
            }
            .navigationTitle("Trọng số chấm điểm")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                weights = appState.activeConfiguration.weights
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        var cfg = appState.activeConfiguration
                        cfg.weights = weights
                        appState.activeConfiguration = cfg
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func weightSlider(title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value.wrappedValue))%")
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.primaryGreen)
            }
            Slider(value: value, in: 0...60, step: 5)
        }
    }
}
