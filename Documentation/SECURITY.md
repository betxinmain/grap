# TÀI LIỆU KIỂM ĐỊNH BẢO MẬT CẤP P0 (SECURITY.md)

## 1. Cam kết Bảo vệ Tài khoản Grab (P0 – 100%)

**Ride Assist Pro** được thiết kế với kiến trúc **Cách ly Hoàn toàn (Zero-Interference Architecture)** nhằm đảm bảo an toàn tuyệt đối cho tài khoản Đối tác Tài xế GrabBike:

| Hạng mục Kiểm định Bảo mật P0 | Trạng thái trong Mã nguồn | Cơ chế Đảm bảo |
| :--- | :--- | :--- |
| **Grab Account Connection** | `NOT CONNECTED` | Không có màn hình đăng nhập Grab, không có WebView nhúng trang Grab. |
| **Grab Password / OTP Storage** | `DISABLED` | Không có bất kỳ trường dữ liệu hay biến nào lưu mật khẩu, số điện thoại đăng nhập hay mã OTP. |
| **Grab API / Token / Cookie Access** | `DISABLED` | Không chứa bất kỳ endpoint nội bộ nào của Grab, không thu thập token hay cookie. |
| **Automated Grab Interaction** | `DISABLED` | Không giả lập thao tác chạm, không tự động bấm nhận, từ chối hoặc hủy chuyến. |
| **Grab Notification Interception** | `DISABLED` | Không sử dụng Notification Service Extension hay bất kỳ kỹ thuật đọc thông báo của ứng dụng khác. |
| **Background Screen Monitoring / OCR** | `DISABLED` | Không quay màn hình, không chụp ảnh màn hình tự động, không dùng OCR đọc màn hình Grab. |
| **VPN / Proxy / Jailbreak / Private API** | `DISABLED` | Chỉ sử dụng 100% Public Frameworks của Apple (`SwiftUI`, `CoreLocation`, `UserNotifications`, `WidgetKit`, `Charts`). |
| **Local Data Storage** | `ENABLED` | Toàn bộ dữ liệu cấu hình, lịch sử cuốc và thống kê được lưu cục bộ trên iPhone của người dùng. |

---

## 2. Kiểm tra Mã nguồn Tĩnh (Static Security Audit)

Toàn bộ các file `.swift`, `Info.plist`, `PrivacyInfo.xcprivacy` và `RideAssistPro.entitlements` đã được rà soát:

1. **Không có kết nối máy chủ bên thứ ba ẩn:** Lớp mạng duy nhất là `NetworkMonitor.swift` sử dụng `NWPathMonitor` để kiểm tra trạng thái có mạng / mất mạng trên thiết bị và các liên kết mở trình duyệt Safari tới bài viết hướng dẫn chính thức tại `https://www.grab.com/vn/blog/driver/`.
2. **Không dùng URL Scheme nội bộ chưa xác minh của Grab:** Chức năng mở nhanh được hướng dẫn thực hiện thông qua ứng dụng **Apple Shortcuts** chính thức của iOS (`shortcuts://`).
3. **Không có tiến trình chạy nền trái phép:** Không khai báo `UIBackgroundModes` cho `location`, `audio` hay `voip` trong `Info.plist`.
