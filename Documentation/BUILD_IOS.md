# HƯỚNG DẪN BUILD, KÝ ỨNG DỤNG VÀ CÀI ĐẶT LÊN IPHONE (BUILD_IOS.md)

> **Lưu ý minh bạch:** Toàn bộ mã nguồn dự án `RideAssistPro` được khởi tạo trong môi trường Windows. Theo quy định của Apple, việc biên dịch mã nguồn SwiftUI thành ứng dụng iOS, chạy iOS Simulator, ký chứng chỉ bảo mật (Code Signing) và đóng gói file `.ipa` **bắt buộc phải thực hiện trên máy Mac có cài đặt Xcode**.

---

## 1. Yêu cầu trên máy Mac

- **Hệ điều hành:** macOS Ventura 13.5+ hoặc macOS Sonoma 14+ / Sequoia 15+.
- **Công cụ:** Xcode 15.0 hoặc Xcode 16.0 trở lên (hỗ trợ Swift 5.9+ và iOS 16, 17, 18 SDK).
- **Tài khoản ký ứng dụng:**
  - Apple ID cá nhân (Personal Team - miễn phí, cài trực tiếp lên iPhone qua cáp USB) **HOẶC**
  - Tài khoản Apple Developer Program ($99/năm - hỗ trợ đầy đủ App Groups cho Widget và xuất file `.ipa` Ad-Hoc / App Store).

---

## 2. Cách mở dự án trên máy Mac

1. Sao chép thư mục `RideAssistPro` sang máy Mac.
2. Mở trực tiếp file dự án Xcode:
   ```bash
   cd RideAssistPro
   open RideAssistPro.xcodeproj
   ```
   *(Hoặc nếu bạn sử dụng `xcodegen` để sinh lại project kèm target Widget Extension tự động: chạy `xcodegen generate` trong thư mục `RideAssistPro` rồi mở `RideAssistPro.xcodeproj`).*

---

## 3. Cấu hình Code Signing trên Xcode

1. Trong Xcode, chọn project **RideAssistPro** ở thanh Project Navigator bên trái.
2. Chọn target **RideAssistPro** → tab **Signing & Capabilities**.
3. Đánh dấu chọn **Automatically manage signing**.
4. Tại mục **Team**, chọn tài khoản Apple ID / Developer Team của bạn.
5. Tại mục **Bundle Identifier**, đổi thành một định danh duy nhất của bạn (ví dụ: `vn.driver.rideassistpro.yourname`).
6. *(Lưu ý cho tài khoản Apple ID miễn phí)*: Nếu dùng Personal Team miễn phí không hỗ trợ capability `App Groups`, bạn có thể nhấn biểu tượng thùng rác bên cạnh mục **App Groups** trong tab *Signing & Capabilities*. Ứng dụng vẫn tự động lưu trữ bình thường qua `UserDefaults.standard` nhờ cơ chế fallback trong `StorageService.swift`.

---

## 4. Build và Chạy trên iPhone thật hoặc Simulator

### Chạy trên iPhone thật:
1. Cắm cáp kết nối iPhone (iOS 16, 17 hoặc 18) vào máy Mac.
2. Trên iPhone (nếu iOS 16 trở lên): Vào **Cài đặt > Quyền riêng tư & Bảo mật > Chế độ nhà phát triển (Developer Mode)** → Bật và khởi động lại máy.
3. Trong Xcode, chọn iPhone của bạn trên thanh chọn thiết bị (Device Selector) phía trên.
4. Nhấn **Cmd + R** (Run) để biên dịch và cài đặt ứng dụng lên iPhone.
5. Nếu dùng Apple ID miễn phí, trên iPhone vào **Cài đặt > Cài đặt chung > Quản lý VPN & Thiết bị** → Chọn chứng chỉ Apple ID của bạn và nhấn **Tin cậy (Trust)**.

### Chạy Unit Tests trên máy Mac:
```bash
xcodebuild test \
  -project RideAssistPro.xcodeproj \
  -scheme RideAssistPro \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

---

## 5. Đóng gói file IPA (Khi có tài khoản Apple Developer)

1. Chọn thiết bị đích là **Any iOS Device (arm64)**.
2. Trên thanh menu Xcode, chọn **Product > Archive**.
3. Khi cửa sổ Organizer hiện ra, chọn bản Archive vừa tạo → Nhấn **Distribute App**.
4. Chọn **Debugging / Ad Hoc** hoặc **App Store Connect** → Xuất file `RideAssistPro.ipa`.
