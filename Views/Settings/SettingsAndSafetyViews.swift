//
//  SettingsAndSafetyViews.swift
//  RideAssistPro
//

import SwiftUI

struct SettingsCenterView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var notificationService: NotificationService
    
    var body: some View {
        NavigationStack {
            List {
                Section("Bảo mật & An toàn tài khoản cấp P0") {
                    NavigationLink {
                        AccountSafetyView()
                    } label: {
                        Label("Bảng Kiểm tra An toàn (ACCOUNT SAFETY)", systemImage: "checkmark.shield.fill")
                            .foregroundColor(AppTheme.primaryGreen)
                            .fontWeight(.semibold)
                    }
                    
                    NavigationLink {
                        DataAndPrivacyManagementView()
                    } label: {
                        Label("Quản lý Dữ liệu & Quyền riêng tư", systemImage: "hand.raised.shield.fill")
                    }
                }
                
                Section("Cấu hình & Trợ lý hoạt động") {
                    NavigationLink {
                        ConfigurationCenterView()
                    } label: {
                        Label("Trung tâm Cấu hình (\(appState.activeConfiguration.profileName))", systemImage: "slider.horizontal.3")
                    }
                    
                    NavigationLink {
                        SmartNotificationSettingsView()
                    } label: {
                        Label("Cài đặt Thông báo thông minh", systemImage: "bell.badge.fill")
                    }
                    
                    NavigationLink {
                        IncomeAndFuelManagerView()
                    } label: {
                        Label("Quản lý Chi phí Xăng & Vận hành", systemImage: "fuelpump.fill")
                    }
                }
                
                Section("Hướng dẫn Chính thức & Thao tác nhanh") {
                    NavigationLink {
                        OfficialGrabFeaturesCenterView()
                    } label: {
                        Label("Trung tâm Tính năng Grab Chính thức", systemImage: "book.closed.fill")
                    }
                    
                    NavigationLink {
                        ShortcutAndQuickResponseView()
                    } label: {
                        Label("Hướng dẫn Apple Shortcuts & Tối ưu chuông", systemImage: "bolt.horizontal.circle.fill")
                    }
                }
                
                Section("Hồ sơ cá nhân & Chế độ Demo") {
                    HStack {
                        Text("Tên hiển thị")
                        Spacer()
                        TextField("Đối tác Tài xế", text: $appState.driverProfile.displayName)
                            .multilineTextAlignment(.trailing)
                            .onSubmit { appState.persistProfile() }
                    }
                    HStack {
                        Text("Khu vực nhà / Cuối ca")
                        Spacer()
                        TextField("Quận Tân Bình", text: $appState.driverProfile.preferredHomeArea)
                            .multilineTextAlignment(.trailing)
                            .onSubmit { appState.persistProfile() }
                    }
                    HStack {
                        Text("Mục tiêu doanh thu/ngày")
                        Spacer()
                        TextField("600000", value: $appState.driverProfile.defaultDailyRevenueGoal, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onSubmit { appState.persistProfile() }
                    }
                    
                    Toggle("Chế độ dữ liệu Demo (Chỉ dùng thử nghiệm)", isOn: Binding(
                        get: { appState.isDemoMode },
                        set: { appState.toggleDemoMode($0) }
                    ))
                }
                
                Section("Thông tin sản phẩm") {
                    NavigationLink {
                        AboutRideAssistProView()
                    } label: {
                        Label("Giới thiệu Ride Assist Pro", systemImage: "info.circle.fill")
                    }
                }
            }
            .navigationTitle("Cài đặt & Bảo mật")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Màn hình 17: ACCOUNT SAFETY (Mục 3.4)
struct AccountSafetyView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let safetyRows: [(title: String, status: String, isEnabledStyle: Bool)] = [
        ("Grab Account Connection", "NOT CONNECTED", false),
        ("Grab Password Storage", "DISABLED", false),
        ("Grab API Access", "DISABLED", false),
        ("Automated Grab Interaction", "DISABLED", false),
        ("Grab Notification Interception", "DISABLED", false),
        ("Background Screen Monitoring", "DISABLED", false),
        ("Local Data Storage", "ENABLED", true)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 52))
                            .foregroundColor(AppTheme.primaryGreen)
                        Text("ACCOUNT SAFETY AUDIT")
                            .font(.title3.bold())
                        Text("Trạng thái cách ly hệ thống cấp P0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(safetyRows.enumerated()), id: \.offset) { idx, item in
                            HStack {
                                Text(item.title)
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text(item.status)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.primaryGreen.opacity(0.15))
                                    .foregroundColor(AppTheme.primaryGreen)
                                    .cornerRadius(8)
                            }
                            .padding(14)
                            if idx < safetyRows.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(AppTheme.cardCornerRadius)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Biện pháp giảm thiểu rủi ro & Tuyên bố minh bạch")
                            .font(.subheadline.bold())
                        Text("• Ride Assist Pro hoạt động hoàn toàn độc lập như một sổ tay tính toán và phân tích dữ liệu cá nhân trên iPhone.")
                            .font(.caption)
                        Text("• Ứng dụng tuyệt đối không yêu cầu đăng nhập Grab, không lấy OTP/token, không đọc màn hình, không giả lập thao tác chạm và không dùng VPN/proxy can thiệp vào Grab Driver.")
                            .font(.caption)
                        Text("• Lưu ý pháp lý: Không một ứng dụng nào được phép quảng cáo bảo đảm tài khoản không bao giờ bị khóa bởi các nguyên nhân vi phạm quy tắc ứng xử của nền tảng. Việc tuân thủ quy định hoạt động của Grab luôn thuộc về Đối tác Tài xế.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(AppTheme.cardCornerRadius)
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Account Safety")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Màn hình 15: Quản lý cấu hình (MODULE 14 – CONFIGURATION CENTER)
struct ConfigurationCenterView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showCreateSheet = false
    @State private var editingConfig: RideCriteria? = nil
    
    var body: some View {
        List {
            Section("Chạm để chuyển cấu hình đang kích hoạt") {
                ForEach(appState.configurations) { cfg in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(cfg.profileName)
                                    .font(.subheadline.bold())
                                if cfg.id == appState.activeConfigurationId {
                                    Text("ĐANG DÙNG")
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppTheme.primaryGreen.opacity(0.18))
                                        .foregroundColor(AppTheme.primaryGreen)
                                        .cornerRadius(4)
                                }
                            }
                            Text("Tối thiểu: \(Formatters.formatVND(cfg.minimumFareVND)) • Đón <= \(cfg.maxPickupDistanceKm.map { Formatters.formatDistanceKm($0) } ?? "Không giới hạn") • Chế độ: \(cfg.filterMode.rawValue)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("Khu vực ưu tiên: \(cfg.priorityAreas.joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            editingConfig = cfg
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundColor(AppTheme.accentTeal)
                        }
                        .buttonStyle(.plain)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appState.activeConfigurationId = cfg.id
                        appState.persistConfigurations()
                    }
                    .swipeActions {
                        if appState.configurations.count > 1 {
                            Button(role: .destructive) {
                                appState.configurations.removeAll { $0.id == cfg.id }
                                if appState.activeConfigurationId == cfg.id, let first = appState.configurations.first {
                                    appState.activeConfigurationId = first.id
                                }
                                appState.persistConfigurations()
                            } label: {
                                Label("Xóa", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            
            Section {
                Button {
                    let newCfg = RideCriteria(
                        id: UUID(),
                        profileName: "Cấu hình mới #\(appState.configurations.count + 1)",
                        minimumFareVND: 20_000,
                        maxPickupDistanceKm: 2.0,
                        shortRideThresholdKm: 3.5,
                        mediumRideThresholdKm: 8.0,
                        preferredRideLengthCategory: "Tất cả",
                        priorityAreas: ["Quận 1", "Quận 3"],
                        nonPriorityAreas: [],
                        homeArea: appState.driverProfile.preferredHomeArea,
                        shiftEndArea: appState.driverProfile.preferredShiftEndArea,
                        targetTimeSlotName: "Cả ngày",
                        targetRevenueGoalVND: 500_000,
                        targetEfficiencyPerKmVND: 7_000,
                        targetEfficiencyPerHourVND: 65_000,
                        filterMode: .balanced,
                        weights: .standard
                    )
                    appState.configurations.append(newCfg)
                    appState.activeConfigurationId = newCfg.id
                    appState.persistConfigurations()
                    editingConfig = newCfg
                } label: {
                    Label("Tạo cấu hình mới", systemImage: "plus.circle.fill")
                        .font(.subheadline.bold())
                }
            } footer: {
                Text("Các cấu hình này chỉ dùng để chấm điểm trong Ride Assist Pro, tuyệt đối không tự chỉnh sửa cài đặt trong ứng dụng Grab Driver.")
            }
        }
        .navigationTitle("Quản lý Cấu hình")
        .sheet(item: $editingConfig) { cfg in
            EditConfigurationSheet(criteria: cfg)
        }
    }
}

struct EditConfigurationSheet: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    @State var criteria: RideCriteria
    @State private var priorityAreasText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tên cấu hình & Khung giờ") {
                    TextField("Tên cấu hình", text: $criteria.profileName)
                    TextField("Khung giờ áp dụng", text: $criteria.targetTimeSlotName)
                    Picker("Chế độ lọc", selection: $criteria.filterMode) {
                        ForEach(FilterMode.allCases) { m in
                            Text(m.displayName).tag(m)
                        }
                    }
                }
                
                Section("Tiêu chí giá cước & Quãng đường") {
                    HStack {
                        Text("Giá cuốc tối thiểu (VNĐ)")
                        Spacer()
                        TextField("20000", value: $criteria.minimumFareVND, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Mục tiêu doanh thu (VNĐ)")
                        Spacer()
                        TextField("500000", value: $criteria.targetRevenueGoalVND, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Mục tiêu hiệu quả/km (VNĐ)")
                        Spacer()
                        TextField("7000", value: $criteria.targetEfficiencyPerKmVND, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Mục tiêu hiệu quả/giờ (VNĐ)")
                        Spacer()
                        TextField("65000", value: $criteria.targetEfficiencyPerHourVND, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Khu vực ưu tiên (Cách nhau bởi dấu phẩy)") {
                    TextField("Quận 1, Quận 3, Phú Nhuận", text: $priorityAreasText)
                }
            }
            .navigationTitle("Chỉnh sửa Cấu hình")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                priorityAreasText = criteria.priorityAreas.joined(separator: ", ")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        criteria.priorityAreas = priorityAreasText
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        appState.activeConfiguration = criteria
                        dismiss()
                    }
                }
            }
        }
    }
}

// Màn hình 16: Cài đặt thông báo (MODULE 13 – SMART NOTIFICATION)
struct SmartNotificationSettingsView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var notificationService: NotificationService
    
    var body: some View {
        Form {
            Section("Trạng thái quyền thông báo iOS") {
                HStack {
                    Text("Trạng thái")
                    Spacer()
                    Text(notificationService.statusDescription)
                        .font(.caption.bold())
                        .foregroundColor(notificationService.isAuthorized ? AppTheme.primaryGreen : AppTheme.warningAmber)
                }
                if !notificationService.isAuthorized {
                    Button("Cấp quyền thông báo cho Ride Assist Pro") {
                        notificationService.requestPermission { _ in
                            appState.persistNotificationSettings()
                        }
                    }
                }
            }
            
            Section("Tuỳ chỉnh bật/tắt từng loại nhắc nhở") {
                Toggle("Nhắc bắt đầu ca chạy", isOn: $appState.notificationSettings.remindShiftStart)
                if appState.notificationSettings.remindShiftStart {
                    Stepper("Giờ nhắc: \(String(format: "%02d:%02d", appState.notificationSettings.shiftStartHour, appState.notificationSettings.shiftStartMinute))", value: $appState.notificationSettings.shiftStartHour, in: 4...22)
                }
                Toggle("Nhắc nghỉ ngơi định kỳ an toàn", isOn: $appState.notificationSettings.remindRestBreak)
                Toggle("Nhắc cập nhật giá xăng", isOn: $appState.notificationSettings.remindUpdateFuelPrice)
                Toggle("Nhắc tổng kết ca chạy buổi tối", isOn: $appState.notificationSettings.remindShiftSummary)
                Toggle("Thông báo khi hoàn thành mục tiêu doanh thu", isOn: $appState.notificationSettings.notifyGoalAchieved)
                Toggle("Nhắc bổ sung dữ liệu thống kê", isOn: $appState.notificationSettings.remindLogStats)
            }
            .onChange(of: appState.notificationSettings) { _ in
                appState.persistNotificationSettings()
            }
            
            Section {
                Text("Cam kết: Ride Assist Pro KHÔNG phát thông báo giả về việc có cuốc Grab và không gửi cảnh báo gây mất tập trung khi bạn đang lái xe.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Cài đặt Thông báo")
    }
}

// Màn hình 18: Quản lý dữ liệu & Quyền riêng tư (Mục 3.3)
struct DataAndPrivacyManagementView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var locationService: LocationService
    @State private var exportedJSONURL: URL? = nil
    @State private var showConfirmDeleteLocation = false
    @State private var showConfirmWipeAll = false
    @State private var statusBanner: String? = nil
    
    var body: some View {
        List {
            Section("Quyền vị trí (CoreLocation)") {
                HStack {
                    Text("Trạng thái hiện tại")
                    Spacer()
                    Text(locationService.authorizationStatusLabel)
                        .font(.caption.bold())
                }
                Button("Cho phép vị trí khi sử dụng ứng dụng") {
                    locationService.requestWhenInUsePermission()
                }
                Button("Xóa toàn bộ dữ liệu vị trí đã lưu", role: .destructive) {
                    showConfirmDeleteLocation = true
                }
            }
            
            Section("Xuất & Sao lưu dữ liệu cá nhân") {
                Button {
                    if let data = try? StorageService.shared.exportAllDataJSON() {
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent("RideAssistPro_Backup.json")
                        try? data.write(to: url)
                        exportedJSONURL = url
                        statusBanner = "Đã đóng gói toàn bộ dữ liệu cá nhân thành file JSON."
                    }
                } label: {
                    Label("Xuất toàn bộ dữ liệu cá nhân (JSON Backup)", systemImage: "externaldrive.fill.badge.arrow.down")
                }
                
                if let url = exportedJSONURL {
                    ShareLink(item: url) {
                        Label("Tải / Chia sẻ bản sao lưu JSON", systemImage: "square.and.arrow.up")
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.primaryGreen)
                    }
                }
            }
            
            Section("Xóa toàn bộ dữ liệu ứng dụng") {
                Button(role: .destructive) {
                    showConfirmWipeAll = true
                } label: {
                    Label("Xóa toàn bộ dữ liệu ứng dụng (Reset 100%)", systemImage: "trash.slash.fill")
                }
            }
            
            if let msg = statusBanner {
                Section {
                    Text(msg)
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                }
            }
        }
        .navigationTitle("Quản lý Dữ liệu & Riêng tư")
        .alert("Xóa dữ liệu vị trí?", isPresented: $showConfirmDeleteLocation) {
            Button("Hủy", role: .cancel) {}
            Button("Xóa vị trí", role: .destructive) {
                appState.clearLocationData()
                statusBanner = "Đã xóa toàn bộ dữ liệu vị trí khỏi thiết bị."
            }
        } message: {
            Text("Toàn bộ điểm lưu bản đồ và tọa độ gắn với lịch sử cuốc sẽ bị xóa.")
        }
        .alert("Xóa toàn bộ dữ liệu ứng dụng?", isPresented: $showConfirmWipeAll) {
            Button("Hủy", role: .cancel) {}
            Button("Xóa tất cả", role: .destructive) {
                appState.wipeAllUserData()
                statusBanner = "Đã xóa sạch toàn bộ dữ liệu và đưa ứng dụng về trạng thái ban đầu."
            }
        } message: {
            Text("Lịch sử cuốc, ca chạy, chi phí xăng và cấu hình cá nhân sẽ bị xóa vĩnh viễn khỏi iPhone.")
        }
    }
}

// Màn hình 19: Giới thiệu ứng dụng
struct AboutRideAssistProView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 56))
                        .foregroundColor(AppTheme.primaryGreen)
                    Text(AppConstants.appName)
                        .font(.title2.bold())
                    Text(AppConstants.appVietnameseTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppTheme.primaryGreen)
                    Text("Phiên bản \(AppConstants.appVersion) • Hỗ trợ iOS 16, 17, 18+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Định hướng sản phẩm")
                        .font(.headline)
                    Text(AppConstants.SafetyDisclaimer.p0Notice)
                        .font(.caption)
                    Text(AppConstants.SafetyDisclaimer.noGuaranteeNotice)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(AppTheme.cardCornerRadius)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppConstants.slogan)
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                    Text("Bảo vệ tài khoản trước tiên. Tối ưu cơ hội có cuốc. Quản lý hiệu quả từng chuyến. Phát triển thu nhập bền vững.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(AppTheme.cardCornerRadius)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Giới thiệu ứng dụng")
    }
}
