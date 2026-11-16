//
//  ShortcutAndQuickResponseView.swift
//  RideAssistPro
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ShortcutAndQuickResponseView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let shortcutSteps: [String] = [
        "1. Mở ứng dụng Phím tắt (Shortcuts) có sẵn trên iPhone.",
        "2. Nhấn nút (+) ở góc trên bên phải để tạo Phím tắt mới (New Shortcut).",
        "3. Chọn Thêm tác vụ (Add Action) → Tìm và chọn 'Mở ứng dụng' (Open App).",
        "4. Chạm vào chữ 'Ứng dụng' (App) màu xanh và chọn 'Grab Driver'.",
        "5. Đổi tên phím tắt thành 'MỞ GRAB'.",
        "6. Nhấn biểu tượng Chia sẻ / Tuỳ chọn → Chọn 'Thêm vào Màn hình chính' (Add to Home Screen) để mở chỉ với 1 chạm.",
        "7. (Tuỳ chọn iPhone 8 trở lên): Vào Cài đặt iPhone > Trợ năng > Cảm ứng > Chạm vào mặt sau (Back Tap) > Chọn Chạm hai lần = phím tắt 'MỞ GRAB'."
    ]
    
    private let notificationChecklist: [String] = [
        "Bật Cho phép Thông báo (Allow Notifications) cho ứng dụng Grab Driver.",
        "Bật đầy đủ 3 kiểu cảnh báo: Màn hình khóa (Lock Screen), Trung tâm thông báo, Biểu ngữ (Banners - chọn kiểu Hiển thị lâu/Persistent).",
        "Bật Âm thanh (Sounds) và kéo thanh âm lượng chuông trong Cài đặt > Âm thanh & Cảm ứng lên mức tối đa.",
        "Kiểm tra chế độ Tập trung (Focus / Không làm phiền): Đảm bảo đã tắt hoặc thêm Grab Driver vào danh sách Ứng dụng được phép thông báo.",
        "Kiểm tra kết nối Dữ liệu di động (4G/5G) luôn bật cho Grab Driver."
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    shortcutSetupCard
                    notificationOptimizationCard
                    iosNotificationCapabilityNoticeCard
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Thao tác Nhanh & Thông báo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
    
    private var shortcutSetupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.horizontal.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.primaryGreen)
                VStack(alignment: .leading, spacing: 2) {
                    Text("11.1. Mở nhanh Grab Driver qua Apple Shortcuts")
                        .font(.subheadline.bold())
                    Text("Hợp lệ 100% theo chuẩn Apple – Không dùng URL Scheme trái phép")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            ForEach(shortcutSteps, id: \.self) { step in
                Text(step)
                    .font(.caption)
                    .padding(.vertical, 2)
            }
            
            Button {
                #if canImport(UIKit)
                if let url = URL(string: "shortcuts://") {
                    UIApplication.shared.open(url)
                }
                #endif
            } label: {
                Label("Mở ứng dụng Apple Shortcuts ngay", systemImage: "arrow.up.forward.app.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(AppTheme.primaryGreen)
                    .cornerRadius(12)
            }
            
            Text("Lưu ý bảo mật: Ride Assist Pro không sử dụng URL Scheme nội bộ chưa được xác minh của Grab và không tự mở Grab khi có thông báo trên iOS 18.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var notificationOptimizationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .font(.title3)
                    .foregroundColor(AppTheme.accentTeal)
                Text("11.2. Hướng dẫn tối ưu thông báo trên iPhone")
                    .font(.subheadline.bold())
            }
            
            ForEach(notificationChecklist, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.primaryGreen)
                        .font(.caption)
                    Text(item)
                        .font(.caption)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var iosNotificationCapabilityNoticeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(AppTheme.warningAmber)
                Text("11.3. Minh bạch giới hạn thông báo của iOS 16–18")
                    .font(.subheadline.bold())
            }
            
            Text("• Trên iOS 16, 17 và 18, Apple thiết kế cơ chế Sandbox bảo mật nghiêm ngặt: Không một ứng dụng bên thứ ba nào được phép đọc nội dung thông báo của ứng dụng Grab Driver.")
                .font(.caption)
            Text("• Ride Assist Pro chỉ phát các thông báo nhắc nhở ca chạy của chính mình thông qua UserNotifications.")
                .font(.caption)
            Text("• Ứng dụng KHÔNG sử dụng Notification Service Extension để nghe lén và KHÔNG tuyên bố có thể nhận diện cuốc Grab trực tiếp trong nền.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
}
