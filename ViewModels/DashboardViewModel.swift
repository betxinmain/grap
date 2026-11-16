//
//  DashboardViewModel.swift
//  RideAssistPro
//

import Foundation
import Combine
#if canImport(UIKit)
import UIKit
#endif

final class DashboardViewModel: ObservableObject {
    @Published var batteryLevelPercent: Int = 100
    @Published var batteryStateDescription: String = "Đang kiểm tra"
    @Published var showShiftOptimizerSheet: Bool = false
    @Published var showQuickRideScoringSheet: Bool = false
    @Published var showShortcutGuideSheet: Bool = false
    
    init() {
        refreshDeviceBatteryInfo()
    }
    
    func refreshDeviceBatteryInfo() {
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        let rawLevel = UIDevice.current.batteryLevel
        if rawLevel < 0 {
            batteryLevelPercent = 100
            batteryStateDescription = "Giả lập / Đủ pin"
        } else {
            batteryLevelPercent = Int(round(rawLevel * 100))
            switch UIDevice.current.batteryState {
            case .charging:
                batteryStateDescription = "\(batteryLevelPercent)% (Đang sạc)"
            case .full:
                batteryStateDescription = "100% (Đầy pin)"
            case .unplugged:
                batteryStateDescription = "\(batteryLevelPercent)% (Đang dùng pin)"
            default:
                batteryStateDescription = "\(batteryLevelPercent)%"
            }
        }
        #else
        batteryLevelPercent = 90
        batteryStateDescription = "90% (Sẵn sàng)"
        #endif
    }
    
    /// Mở ứng dụng Shortcuts chính thức của Apple để người dùng chạy phím tắt "MỞ GRAB" hợp lệ,
    /// tuyệt đối không dùng URL Scheme nội bộ chưa xác minh của Grab.
    func openAppleShortcutsApp(fallbackToGuide: () -> Void) {
        #if canImport(UIKit)
        if let shortcutsURL = URL(string: "shortcuts://"),
           UIApplication.shared.canOpenURL(shortcutsURL) {
            UIApplication.shared.open(shortcutsURL)
        } else {
            fallbackToGuide()
        }
        #else
        fallbackToGuide()
        #endif
    }
}
