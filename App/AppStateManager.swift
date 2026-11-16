//
//  AppStateManager.swift
//  RideAssistPro
//

import Foundation
import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

enum AppTab: Int, CaseIterable, Identifiable {
    case dashboard = 0
    case opportunity = 1
    case map = 2
    case analytics = 3
    case history = 4
    case settings = 5
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .dashboard: return "Trang chủ"
        case .opportunity: return "Cơ hội cuốc"
        case .map: return "Bản đồ"
        case .analytics: return "Phân tích"
        case .history: return "Lịch sử"
        case .settings: return "Cài đặt"
        }
    }
    
    var iconName: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.67percent"
        case .opportunity: return "sparkles.rectangle.stack.fill"
        case .map: return "map.fill"
        case .analytics: return "chart.bar.xaxis"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape.fill"
        }
    }
}

final class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var selectedTab: AppTab = .dashboard
    @Published var showSplash: Bool = true
    @Published var hasCompletedOnboarding: Bool
    @Published var isDemoMode: Bool
    
    @Published var driverProfile: DriverProfile
    @Published var configurations: [RideCriteria]
    @Published var activeConfigurationId: UUID
    @Published var rideHistory: [RideHistoryRecord]
    @Published var shiftRecords: [ShiftRecord]
    @Published var currentShift: ShiftRecord?
    @Published var savedLocations: [SavedDriverLocation]
    @Published var timeSlotConfigs: [TimeSlotConfig]
    @Published var fuelSettings: FuelAndExpenseSettings
    @Published var expenseRecords: [ExpenseItem]
    @Published var readyCheckState: ReadyCheckState
    @Published var notificationSettings: SmartNotificationSettings
    @Published var officialFeatures: [OfficialGrabFeatureGuideItem]
    
    private let storage: StorageService
    
    init(storage: StorageService = .shared) {
        self.storage = storage
        
        self.hasCompletedOnboarding = storage.loadBool(forKey: AppConstants.StorageKeys.hasCompletedOnboarding, defaultValue: false)
        self.isDemoMode = storage.loadBool(forKey: AppConstants.StorageKeys.isDemoMode, defaultValue: false)
        
        let loadedProfile = storage.load(DriverProfile.self, forKey: AppConstants.StorageKeys.driverProfile) ?? .default
        self.driverProfile = loadedProfile
        
        let loadedConfigs = storage.load([RideCriteria].self, forKey: AppConstants.StorageKeys.configurations) ?? RideCriteria.defaultPresets
        self.configurations = loadedConfigs
        
        let savedActiveId = storage.load(UUID.self, forKey: AppConstants.StorageKeys.activeConfigurationId)
        self.activeConfigurationId = savedActiveId ?? (loadedConfigs.first?.id ?? UUID())
        
        self.rideHistory = storage.load([RideHistoryRecord].self, forKey: AppConstants.StorageKeys.rideHistory) ?? []
        self.shiftRecords = storage.load([ShiftRecord].self, forKey: AppConstants.StorageKeys.shiftRecords) ?? []
        self.currentShift = storage.load(ShiftRecord.self, forKey: AppConstants.StorageKeys.currentShift)
        self.savedLocations = storage.load([SavedDriverLocation].self, forKey: AppConstants.StorageKeys.savedAreas) ?? SavedDriverLocation.sampleLocations
        self.timeSlotConfigs = storage.load([TimeSlotConfig].self, forKey: AppConstants.StorageKeys.timeSlotConfigs) ?? TimeSlotConfig.defaultSlots
        self.fuelSettings = storage.load(FuelAndExpenseSettings.self, forKey: AppConstants.StorageKeys.incomeSettings) ?? .standard
        self.expenseRecords = storage.load([ExpenseItem].self, forKey: AppConstants.StorageKeys.expenseRecords) ?? []
        self.readyCheckState = storage.load(ReadyCheckState.self, forKey: AppConstants.StorageKeys.readyCheckState) ?? .initial
        self.notificationSettings = storage.load(SmartNotificationSettings.self, forKey: AppConstants.StorageKeys.notificationSettings) ?? .default
        self.officialFeatures = storage.load([OfficialGrabFeatureGuideItem].self, forKey: AppConstants.StorageKeys.officialFeaturesStatus) ?? Self.defaultOfficialFeatures()
        
        syncWidgetSnapshot()
    }
    
    var activeConfiguration: RideCriteria {
        get {
            configurations.first(where: { $0.id == activeConfigurationId }) ?? configurations.first ?? RideCriteria.defaultPresets[0]
        }
        set {
            if let idx = configurations.firstIndex(where: { $0.id == newValue.id }) {
                configurations[idx] = newValue
            } else {
                configurations.append(newValue)
            }
            activeConfigurationId = newValue.id
            persistConfigurations()
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        storage.saveBool(true, forKey: AppConstants.StorageKeys.hasCompletedOnboarding)
    }
    
    func persistProfile() {
        try? storage.save(driverProfile, forKey: AppConstants.StorageKeys.driverProfile)
        syncWidgetSnapshot()
    }
    
    func persistConfigurations() {
        try? storage.save(configurations, forKey: AppConstants.StorageKeys.configurations)
        try? storage.save(activeConfigurationId, forKey: AppConstants.StorageKeys.activeConfigurationId)
        syncWidgetSnapshot()
    }
    
    func persistHistoryAndShifts() {
        try? storage.save(rideHistory, forKey: AppConstants.StorageKeys.rideHistory)
        try? storage.save(shiftRecords, forKey: AppConstants.StorageKeys.shiftRecords)
        if let currentShift = currentShift {
            try? storage.save(currentShift, forKey: AppConstants.StorageKeys.currentShift)
        } else {
            storage.remove(forKey: AppConstants.StorageKeys.currentShift)
        }
        syncWidgetSnapshot()
    }
    
    func persistSavedLocations() {
        try? storage.save(savedLocations, forKey: AppConstants.StorageKeys.savedAreas)
    }
    
    func persistTimeSlots() {
        try? storage.save(timeSlotConfigs, forKey: AppConstants.StorageKeys.timeSlotConfigs)
    }
    
    func persistFuelAndExpenses() {
        try? storage.save(fuelSettings, forKey: AppConstants.StorageKeys.incomeSettings)
        try? storage.save(expenseRecords, forKey: AppConstants.StorageKeys.expenseRecords)
    }
    
    func persistReadyCheck() {
        readyCheckState.lastCheckedDate = Date()
        try? storage.save(readyCheckState, forKey: AppConstants.StorageKeys.readyCheckState)
    }
    
    func persistNotificationSettings() {
        try? storage.save(notificationSettings, forKey: AppConstants.StorageKeys.notificationSettings)
        NotificationService.shared.applyNotificationSchedules(settings: notificationSettings)
    }
    
    func persistOfficialFeatures() {
        try? storage.save(officialFeatures, forKey: AppConstants.StorageKeys.officialFeaturesStatus)
    }
    
    func addRideRecord(_ record: RideHistoryRecord) {
        rideHistory.insert(record, at: 0)
        if let activeShift = currentShift, activeShift.status == .active || activeShift.status == .paused {
            let previousRev = activeShift.totalRevenueVND
            let updatedShift = ShiftService.shared.applyRide(record, to: activeShift)
            currentShift = updatedShift
            if previousRev < updatedShift.revenueGoalVND && updatedShift.totalRevenueVND >= updatedShift.revenueGoalVND {
                NotificationService.shared.sendGoalAchievedNotificationIfEnabled(
                    settings: notificationSettings,
                    revenue: updatedShift.totalRevenueVND
                )
            }
        }
        // Cập nhật thống kê tại khu vực đã lưu nếu trùng tên
        if record.status == .completed {
            for idx in savedLocations.indices {
                if savedLocations[idx].areaDistrict.localizedCaseInsensitiveContains(record.pickupArea) ||
                    record.pickupArea.localizedCaseInsensitiveContains(savedLocations[idx].areaDistrict) {
                    let oldCount = Double(savedLocations[idx].recordedRidesCount)
                    let newCount = oldCount + 1
                    savedLocations[idx].averageFareVND = ((savedLocations[idx].averageFareVND * oldCount) + record.totalIncomeVND) / newCount
                    savedLocations[idx].averageWaitMinutes = ((savedLocations[idx].averageWaitMinutes * oldCount) + record.waitingMinutesBeforeRide) / newCount
                    savedLocations[idx].recordedRidesCount += 1
                }
            }
            persistSavedLocations()
        }
        persistHistoryAndShifts()
    }
    
    func updateRideRecord(_ updated: RideHistoryRecord) {
        if let idx = rideHistory.firstIndex(where: { $0.id == updated.id }) {
            rideHistory[idx] = updated
            persistHistoryAndShifts()
        }
    }
    
    func deleteRideRecord(id: UUID) {
        rideHistory.removeAll { $0.id == id }
        persistHistoryAndShifts()
    }
    
    /// Chỉ nạp dữ liệu mẫu khi người dùng chủ động bật Chế độ Demo (Quy tắc 8 & 9 Mục 25)
    func toggleDemoMode(_ enabled: Bool) {
        isDemoMode = enabled
        storage.saveBool(enabled, forKey: AppConstants.StorageKeys.isDemoMode)
        if enabled && rideHistory.isEmpty {
            loadDemoDataset()
        } else if !enabled {
            rideHistory.removeAll { $0.notes.contains("[DEMO]") }
            persistHistoryAndShifts()
        }
    }
    
    private func loadDemoDataset() {
        let now = Date()
        let cal = Calendar.current
        let demoRides: [RideHistoryRecord] = [
            RideHistoryRecord(
                id: UUID(),
                timestamp: cal.date(byAdding: .hour, value: -1, to: now) ?? now,
                shiftId: currentShift?.id,
                pickupArea: "Quận 1",
                dropoffArea: "Quận 3",
                netFareVND: 28_000,
                tipOrBonusVND: 5_000,
                pickupDistanceKm: 0.7,
                tripDistanceKm: 3.2,
                durationMinutes: 12,
                waitingMinutesBeforeRide: 4,
                fuelCostEstimatedVND: 1_500,
                evaluationScore: 91,
                evaluationTier: RideScoreTier.highlySuitable.rawValue,
                status: .completed,
                notes: "[DEMO] Cuốc văn phòng giờ cao điểm",
                latitude: 10.7756,
                longitude: 106.7019
            ),
            RideHistoryRecord(
                id: UUID(),
                timestamp: cal.date(byAdding: .hour, value: -2, to: now) ?? now,
                shiftId: currentShift?.id,
                pickupArea: "Quận 1",
                dropoffArea: "Bình Thạnh",
                netFareVND: 34_000,
                tipOrBonusVND: 0,
                pickupDistanceKm: 0.9,
                tripDistanceKm: 4.4,
                durationMinutes: 16,
                waitingMinutesBeforeRide: 5,
                fuelCostEstimatedVND: 2_050,
                evaluationScore: 86,
                evaluationTier: RideScoreTier.highlySuitable.rawValue,
                status: .completed,
                notes: "[DEMO] Khách đi Điện Biên Phủ",
                latitude: 10.7798,
                longitude: 106.6990
            ),
            RideHistoryRecord(
                id: UUID(),
                timestamp: cal.date(byAdding: .hour, value: -3, to: now) ?? now,
                shiftId: currentShift?.id,
                pickupArea: "Quận 3",
                dropoffArea: "Quận Tân Bình",
                netFareVND: 42_000,
                tipOrBonusVND: 10_000,
                pickupDistanceKm: 1.1,
                tripDistanceKm: 5.5,
                durationMinutes: 20,
                waitingMinutesBeforeRide: 6,
                fuelCostEstimatedVND: 2_550,
                evaluationScore: 88,
                evaluationTier: RideScoreTier.highlySuitable.rawValue,
                status: .completed,
                notes: "[DEMO] Khách đi sân bay / Cộng Hòa",
                latitude: 10.7830,
                longitude: 106.6920
            ),
            RideHistoryRecord(
                id: UUID(),
                timestamp: cal.date(byAdding: .day, value: -1, to: now) ?? now,
                shiftId: nil,
                pickupArea: "Quận Tân Bình",
                dropoffArea: "Quận Phú Nhuận",
                netFareVND: 26_000,
                tipOrBonusVND: 0,
                pickupDistanceKm: 0.8,
                tripDistanceKm: 3.1,
                durationMinutes: 13,
                waitingMinutesBeforeRide: 5,
                fuelCostEstimatedVND: 1_510,
                evaluationScore: 82,
                evaluationTier: RideScoreTier.suitable.rawValue,
                status: .completed,
                notes: "[DEMO] Cuốc sáng khu Cộng Hòa",
                latitude: 10.8015,
                longitude: 106.6425
            )
        ]
        rideHistory.append(contentsOf: demoRides)
        persistHistoryAndShifts()
    }
    
    func clearLocationData() {
        storage.clearLocationDataOnly()
        LocationService.shared.clearCachedRuntimeLocation()
        savedLocations = []
        for idx in rideHistory.indices {
            rideHistory[idx].latitude = nil
            rideHistory[idx].longitude = nil
        }
    }
    
    func wipeAllUserData() {
        storage.clearAllAppData()
        isDemoMode = false
        driverProfile = .default
        configurations = RideCriteria.defaultPresets
        activeConfigurationId = configurations[0].id
        rideHistory = []
        shiftRecords = []
        currentShift = nil
        savedLocations = SavedDriverLocation.sampleLocations
        timeSlotConfigs = TimeSlotConfig.defaultSlots
        fuelSettings = .standard
        expenseRecords = []
        readyCheckState = .initial
        notificationSettings = .default
        syncWidgetSnapshot()
    }
    
    func syncWidgetSnapshot() {
        let cfg = activeConfiguration
        let todayRides = todayCompletedRides
        let todayRev = todayRides.reduce(0.0) { $0 + $1.totalIncomeVND }
        let activeHoursText: String
        if let shift = currentShift {
            activeHoursText = Formatters.formatDuration(seconds: shift.activeWorkingDurationSeconds())
        } else {
            let totalMins = todayRides.reduce(0.0) { $0 + $1.durationMinutes }
            activeHoursText = Formatters.formatDuration(seconds: totalMins * 60)
        }
        
        let maxPickupStr: String
        if let maxP = cfg.maxPickupDistanceKm {
            maxPickupStr = Formatters.formatDistanceKm(maxP)
        } else {
            maxPickupStr = "Không giới hạn"
        }
        
        let snapshot = WidgetDataSnapshot(
            isShiftActive: currentShift?.status == .active,
            shiftStatusText: currentShift?.status.rawValue ?? "Chưa bắt đầu ca",
            revenueGoalVND: currentShift?.revenueGoalVND ?? driverProfile.defaultDailyRevenueGoal,
            currentRevenueVND: currentShift?.totalRevenueVND ?? todayRev,
            recordedRidesCount: currentShift?.recordedRidesCount ?? todayRides.count,
            activeHoursText: activeHoursText,
            priorityArea: cfg.priorityAreas.prefix(2).joined(separator: ", "),
            targetMinimumFareVND: cfg.minimumFareVND,
            maxPickupDistanceText: maxPickupStr,
            activeConfigName: cfg.profileName,
            updatedAt: Date()
        )
        storage.updateWidgetSnapshot(snapshot)
    }
    
    var todayCompletedRides: [RideHistoryRecord] {
        let cal = Calendar.current
        return rideHistory.filter { $0.status == .completed && cal.isDateInToday($0.timestamp) }
    }
    
    static func defaultOfficialFeatures() -> [OfficialGrabFeatureGuideItem] {
        return [
            OfficialGrabFeatureGuideItem(
                id: "grabnow_2banh",
                title: "GrabNow – Kết nối trực tiếp qua mã PIN 6 số",
                category: "Tính năng nhận chuyến",
                summary: "Hỗ trợ Đối tác GrabBike kết nối trực tiếp với hành khách đang đứng tại điểm đón bằng mã PIN 6 chữ số mà không cần chờ hệ thống điều phối từ xa.",
                conditionsToUse: [
                    "Chỉ áp dụng cho tài khoản Đối tác GrabBike được Grab mở tính năng GrabNow (Không phải mọi tài khoản đều mặc định có).",
                    "Tài xế và hành khách đang đứng trực tiếp cạnh nhau tại điểm đón an toàn.",
                    "Không bật đồng thời tính năng Tự động nhận cuốc (Auto Accept) hoặc Điểm đến yêu thích khi đang mở màn hình GrabNow."
                ],
                applicableAreas: "Theo quy định hiện hành của Grab Việt Nam tại các tỉnh/thành phố hỗ trợ GrabNow (TP.HCM, Hà Nội và các điểm bến bãi/khu vực cho phép).",
                activationSteps: [
                    "Bước 1: Dừng xe an toàn, mở ứng dụng Grab Driver.",
                    "Bước 2: Chọn biểu tượng/chế độ GrabNow trên màn hình nếu tài khoản được hỗ trợ.",
                    "Bước 3: Cung cấp mã PIN 6 số hiển thị trên màn hình Grab Driver cho hành khách nhập vào ứng dụng Grab của khách.",
                    "Bước 4: Kiểm tra lộ trình, giá cước trên màn hình và bấm Chấp nhận để bắt đầu chuyến đi."
                ],
                importantNotesAndRateImpacts: [
                    "Khi đang ở màn hình chờ GrabNow, hệ thống sẽ tạm ngừng chỉ định các cuốc xe thông thường khác.",
                    "Tài xế KHÔNG THỂ hủy chuyến sau khi đã bấm 'Chấp nhận' cuốc GrabNow.",
                    "Cuốc xe GrabNow thường không được tính vào chương trình thưởng ngọc/thưởng doanh thu theo quy định từng thời kỳ, nhưng vẫn tính vào Tỷ lệ hoàn thành và Đánh giá sao."
                ],
                officialURL: AppConstants.OfficialGrabURLs.grabNow,
                verificationState: .verified,
                lastVerifiedDate: "15/11/2026"
            ),
            OfficialGrabFeatureGuideItem(
                id: "auto_accept",
                title: "Tự động nhận cuốc (Auto Accept)",
                category: "Tính năng nhận chuyến",
                summary: "Hệ thống tự động tiếp nhận cuốc xe đổ về thay vì tài xế phải chạm nút 'Chấp nhận' thủ công khi đang lưu thông.",
                conditionsToUse: [
                    "Được xác nhận trong tài liệu hướng dẫn Đối tác Grab chính thức.",
                    "Tài khoản người dùng có hiển thị tùy chọn Tự động nhận trong Cài đặt Grab Driver."
                ],
                applicableAreas: "Toàn quốc đối với các dịch vụ 2 bánh áp dụng Auto Accept trên Grab Driver.",
                activationSteps: [
                    "Bước 1: Mở ứng dụng Grab Driver chính thức.",
                    "Bước 2: Vào mục Hồ sơ của tôi (My Profile) > Cài đặt (Settings).",
                    "Bước 3: Kiểm tra trạng thái Bật/Tắt Tự động nhận cuốc tùy theo nhu cầu hoạt động."
                ],
                importantNotesAndRateImpacts: [
                    "LƯU Ý QUAN TRỌNG: Khi có cuốc tự động nhận đổ về, tài xế bắt buộc phải chạm xác nhận trên màn hình trong thời gian quy định (thường là 3 phút).",
                    "Nếu không xác nhận kịp thời, hệ thống sẽ tự hủy chuyến và tính vào Tỷ lệ hủy chuyến của tài xế.",
                    "Ride Assist Pro tuyệt đối KHÔNG tự bật/tắt tính năng này và KHÔNG tự nhận chuyến ngoài ứng dụng Grab."
                ],
                officialURL: AppConstants.OfficialGrabURLs.driverBlog,
                verificationState: .verified,
                lastVerifiedDate: "15/11/2026"
            ),
            OfficialGrabFeatureGuideItem(
                id: "my_destination_2banh",
                title: "Điểm đến yêu thích (2 bánh)",
                category: "Tối ưu lộ trình",
                summary: "Giúp Đối tác cài đặt trước hướng/địa điểm mong muốn di chuyển đến (ví dụ khi muốn chạy về gần nhà cuối ca), hệ thống sẽ ưu tiên phân bổ cuốc cùng chiều.",
                conditionsToUse: [
                    "Tài khoản GrabBike đủ điều kiện sử dụng Điểm đến yêu thích và còn lượt sử dụng trong ngày theo quy định hiện hành của Grab.",
                    "Có thể sử dụng kết hợp với Tự động nhận cuốc, nhưng không dùng chung lúc đang mở màn hình GrabNow."
                ],
                applicableAreas: "Các thành phố triển khai tính năng Điểm đến yêu thích 2 bánh của Grab Việt Nam.",
                activationSteps: [
                    "Bước 1: Trên màn hình chính Grab Driver, chọn biểu tượng Điểm đến yêu thích.",
                    "Bước 2: Chọn địa chỉ đã lưu (như Nhà) hoặc nhập điểm đến mong muốn.",
                    "Bước 3: Kích hoạt chế độ để nhận các chuyến xe thuận chiều."
                ],
                importantNotesAndRateImpacts: [
                    "Số lượt sử dụng mỗi ngày có giới hạn theo quy định của Grab.",
                    "Việc bỏ qua (để trôi) hoặc hủy chuyến khi đang bật Điểm đến yêu thích VẪN ảnh hưởng trực tiếp đến Tỷ lệ chấp nhận và Tỷ lệ hủy chuyến.",
                    "Cần kiểm tra kỹ điều kiện của từng chương trình thưởng xem cuốc Điểm đến yêu thích có được tính thưởng ngọc hay không."
                ],
                officialURL: AppConstants.OfficialGrabURLs.myDestination,
                verificationState: .verified,
                lastVerifiedDate: "15/11/2026"
            ),
            OfficialGrabFeatureGuideItem(
                id: "notifications_and_incentives",
                title: "Thông báo & Chương trình thưởng chính thức",
                category: "Chương trình thưởng & Quy định",
                summary: "Hướng dẫn kiểm tra điều kiện chương trình thưởng ngọc, thưởng giờ cao điểm và thông báo chính thức ngay trong ứng dụng Grab Driver.",
                conditionsToUse: [
                    "Tất cả chương trình thưởng áp dụng theo từng tài khoản và khu vực cụ thể hiển thị trực tiếp trong mục 'Kho phần thưởng / Chương trình thưởng' trên Grab Driver.",
                    "Đảm bảo duy trì Tỷ lệ chấp nhận chuyến, Tỷ lệ hủy chuyến và Đánh giá sao theo đúng ngưỡng quy định."
                ],
                applicableAreas: "Tùy theo khu vực đăng ký hoạt động của từng Đối tác.",
                activationSteps: [
                    "Bước 1: Mở mục Thông báo hoặc Chương trình thưởng trực tiếp trên ứng dụng Grab Driver.",
                    "Bước 2: Xem kỹ Thời gian áp dụng, Khu vực áp dụng và Loại dịch vụ được tính.",
                    "Bước 3: Đối chiếu tiến độ thực tế trên Grab Driver."
                ],
                importantNotesAndRateImpacts: [
                    "Ride Assist Pro KHÔNG tự tạo chương trình thưởng giả và KHÔNG thu thập dữ liệu thưởng từ tài khoản của bạn.",
                    "Luôn kiểm tra thông tin mới nhất tại Blog Tài xế Grab Việt Nam khi có kết nối Internet."
                ],
                officialURL: AppConstants.OfficialGrabURLs.driverBlog,
                verificationState: .verified,
                lastVerifiedDate: "15/11/2026"
            )
        ]
    }
}
