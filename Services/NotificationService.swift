//
//  NotificationService.swift
//  RideAssistPro
//

import Foundation
import UserNotifications

struct SmartNotificationSettings: Codable, Equatable {
    var remindShiftStart: Bool
    var shiftStartHour: Int
    var shiftStartMinute: Int
    var remindRestBreak: Bool
    var restIntervalMinutes: Int
    var remindUpdateFuelPrice: Bool
    var remindShiftSummary: Bool
    var notifyGoalAchieved: Bool
    var remindLogStats: Bool
    
    static let `default` = SmartNotificationSettings(
        remindShiftStart: true,
        shiftStartHour: 6,
        shiftStartMinute: 30,
        remindRestBreak: true,
        restIntervalMinutes: 150,
        remindUpdateFuelPrice: true,
        remindShiftSummary: true,
        notifyGoalAchieved: true,
        remindLogStats: true
    )
}

final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var statusDescription: String = "Chưa kiểm tra"
    
    init() {
        refreshAuthorizationStatus()
    }
    
    func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.isAuthorized = true
                    self.statusDescription = "Đã bật thông báo Ride Assist Pro"
                case .denied:
                    self.isAuthorized = false
                    self.statusDescription = "Đã tắt trong Cài đặt iOS"
                case .notDetermined:
                    self.isAuthorized = false
                    self.statusDescription = "Chưa cấp quyền thông báo"
                @unknown default:
                    self.isAuthorized = false
                    self.statusDescription = "Không xác định"
                }
            }
        }
    }
    
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                self.refreshAuthorizationStatus()
                completion?(granted)
            }
        }
    }
    
    /// Lên lịch các thông báo nội bộ hợp lệ của Ride Assist Pro (TUYỆT ĐỐI KHÔNG phát thông báo giả về cuốc Grab)
    func applyNotificationSchedules(settings: SmartNotificationSettings) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        guard isAuthorized else { return }
        
        if settings.remindShiftStart {
            var dateComponents = DateComponents()
            dateComponents.hour = settings.shiftStartHour
            dateComponents.minute = settings.shiftStartMinute
            
            let content = UNMutableNotificationContent()
            content.title = "Chuẩn bị bắt đầu ca chạy"
            content.body = "Kiểm tra kết nối mạng, âm lượng chuông và tiêu chí cuốc xe trước khi mở Grab Driver."
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "rap.shiftStart", content: content, trigger: trigger)
            center.add(request)
        }
        
        if settings.remindRestBreak {
            let intervalSeconds = TimeInterval(max(60, settings.restIntervalMinutes) * 60)
            let content = UNMutableNotificationContent()
            content.title = "Nhắc nghỉ ngơi an toàn"
            content.body = "Khi đã dừng xe an toàn, hãy nghỉ giải lao 10-15 phút để giữ sức khỏe và sự tỉnh táo."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalSeconds, repeats: false)
            let request = UNNotificationRequest(identifier: "rap.restBreak", content: content, trigger: trigger)
            center.add(request)
        }
        
        if settings.remindShiftSummary {
            var eveningComponents = DateComponents()
            eveningComponents.hour = 21
            eveningComponents.minute = 0
            
            let content = UNMutableNotificationContent()
            content.title = "Tổng kết ca chạy & Bổ sung thống kê"
            content.body = "Đừng quên ghi nhận các cuốc xe và chi phí xăng hôm nay vào Ride Assist Pro để phân tích hiệu quả."
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: eveningComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "rap.shiftSummary", content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    func sendGoalAchievedNotificationIfEnabled(settings: SmartNotificationSettings, revenue: Double) {
        guard isAuthorized && settings.notifyGoalAchieved else { return }
        let content = UNMutableNotificationContent()
        content.title = "Hoàn thành mục tiêu doanh thu ca!"
        content.body = "Chúc mừng bạn đã đạt \(Formatters.formatVND(revenue)) trong ca chạy hôm nay."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: "rap.goalAchieved.\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}
