//
//  AppConstants.swift
//  RideAssistPro
//
//  TRỢ LÝ TÀI XẾ - TỐI ƯU CUỐC XE
//  P0 Security Compliant - Local Only - No Grab API/Account Access
//

import Foundation
import SwiftUI

enum AppConstants {
    static let appName = "RIDE ASSIST PRO"
    static let appSubtitle = "SMART DRIVER ASSISTANT"
    static let appVietnameseTitle = "TRỢ LÝ TÀI XẾ - TỐI ƯU CUỐC XE"
    static let appVersion = "1.0.0"
    static let appBuild = "100"
    static let appGroupIdentifier = "group.com.rideassistpro.shared"
    static let slogan = "RIDE ASSIST PRO – DRIVE SMARTER, EARN BETTER."
    
    enum StorageKeys {
        static let hasCompletedOnboarding = "rap.hasCompletedOnboarding"
        static let driverProfile = "rap.driverProfile"
        static let activeConfigurationId = "rap.activeConfigurationId"
        static let configurations = "rap.configurations"
        static let rideHistory = "rap.rideHistory"
        static let shiftRecords = "rap.shiftRecords"
        static let currentShift = "rap.currentShift"
        static let savedAreas = "rap.savedAreas"
        static let timeSlotConfigs = "rap.timeSlotConfigs"
        static let incomeSettings = "rap.incomeSettings"
        static let expenseRecords = "rap.expenseRecords"
        static let readyCheckState = "rap.readyCheckState"
        static let notificationSettings = "rap.notificationSettings"
        static let officialFeaturesStatus = "rap.officialFeaturesStatus"
        static let isDemoMode = "rap.isDemoMode"
        static let widgetSnapshot = "rap.widgetSnapshot"
    }
    
    enum OfficialGrabURLs {
        static let home = "https://www.grab.com/vn/"
        static let driverBlog = "https://www.grab.com/vn/blog/driver/"
        static let myDestination = "https://www.grab.com/vn/blog/driver/diemdenyeuthich-2banh/"
        static let grabNow = "https://www.grab.com/vn/blog/driver/grabbike-grabnow/"
    }
    
    enum SafetyDisclaimer {
        static let p0Notice = "Ride Assist Pro là ứng dụng trợ lý độc lập, KHÔNG phải ứng dụng chính thức của Grab. Ứng dụng KHÔNG yêu cầu đăng nhập Grab, KHÔNG đọc trộm thông báo, KHÔNG can thiệp hay tự động bấm nhận cuốc trên Grab Driver."
        static let noGuaranteeNotice = "Không có ứng dụng bên thứ ba nào kiểm soát được hệ thống phân phối chuyến của Grab. Ride Assist Pro hỗ trợ tối ưu vị trí, khung giờ và đánh giá hiệu quả chuyến dựa trên dữ liệu cá nhân của bạn."
    }
}

enum AppTheme {
    static let primaryGreen = Color(red: 0.0, green: 0.69, blue: 0.31) // #00B14F inspired emerald green
    static let darkGreen = Color(red: 0.02, green: 0.35, blue: 0.18)
    static let deepNavy = Color(red: 0.06, green: 0.12, blue: 0.22)
    static let accentTeal = Color(red: 0.0, green: 0.58, blue: 0.53)
    static let warningAmber = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let dangerRed = Color(red: 0.89, green: 0.22, blue: 0.21)
    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 14
}
