//
//  DriverProfile.swift
//  RideAssistPro
//

import Foundation

struct DriverProfile: Codable, Equatable {
    var displayName: String
    var city: String
    var vehicleModel: String
    var preferredHomeArea: String
    var preferredShiftEndArea: String
    var defaultDailyRevenueGoal: Double
    var defaultDailyRidesGoal: Int
    var maxContinuousDrivingHours: Double
    
    static let `default` = DriverProfile(
        displayName: "Đối tác Tài xế",
        city: "TP. Hồ Chí Minh",
        vehicleModel: "Honda Wave / Vision",
        preferredHomeArea: "Quận Tân Bình",
        preferredShiftEndArea: "Quận Tân Bình",
        defaultDailyRevenueGoal: 600_000,
        defaultDailyRidesGoal: 18,
        maxContinuousDrivingHours: 4.0
    )
}

struct ReadyCheckState: Codable, Equatable {
    /// Các mục không thể kiểm tra bằng API công khai của iOS được đánh dấu là Người dùng tự xác nhận (User Verified)
    var userConfirmedGrabNotificationsOn: Bool
    var userConfirmediPhoneSoundLoud: Bool
    var userConfirmedOfficialGrabFeaturesChecked: Bool
    var lastCheckedDate: Date?
    
    static let initial = ReadyCheckState(
        userConfirmedGrabNotificationsOn: false,
        userConfirmediPhoneSoundLoud: false,
        userConfirmedOfficialGrabFeaturesChecked: false,
        lastCheckedDate: nil
    )
}
