# RIDE ASSIST PRO – TRỢ LÝ TÀI XẾ - TỐI ƯU CUỐC XE

> **RIDE ASSIST PRO – DRIVE SMARTER, EARN BETTER.**  
> Ứng dụng trợ lý tài xế độc lập dành cho Đối tác GrabBike tại Việt Nam trên iPhone (iOS 16, 17, 18+).  
> **Mục tiêu quan trọng nhất:** Tối ưu cơ hội nhận cuốc, đánh giá hiệu quả từng chuyến và quản lý thu nhập bền vững mà **KHÔNG làm ảnh hưởng tài khoản Grab (Bảo mật cấp P0: 100%)**.

---

## 1. Định hướng & Tuyên bố Minh bạch

- **Ride Assist Pro** là công cụ trợ lý tính toán, phân tích dữ liệu cá nhân và hướng dẫn thao tác hợp lệ, **KHÔNG phải ứng dụng chính thức của Grab**.
- Ứng dụng **KHÔNG** yêu cầu đăng nhập tài khoản Grab, **KHÔNG** lấy mật khẩu/OTP/token, **KHÔNG** gọi API nội bộ Grab, **KHÔNG** đọc trộm thông báo hay theo dõi màn hình Grab, và **KHÔNG** tự động bấm nhận/từ chối/hủy chuyến.
- Ứng dụng **KHÔNG** tuyên bố có thể nhận trước toàn bộ tài xế khác hoặc bảo đảm 100% lúc nào cũng có cuốc, bởi không có ứng dụng bên thứ ba nào kiểm soát được hệ thống phân phối chuyến của Grab.

---

## 2. Danh sách Module & Chức năng Đã Hoàn thành (100%)

1. **Splash Screen & Onboarding**:
   - Hiển thị thương hiệu độc lập `RIDE ASSIST PRO - SMART DRIVER ASSISTANT` (không sử dụng logo Grab).
   - Giới thiệu nguyên tắc P0 và hướng dẫn cấp quyền vị trí tùy chọn (`WhenInUse`).
2. **Module 1 – Smart Dashboard (`DashboardView.swift`)**:
   - Quản lý trạng thái ca làm, giờ bắt đầu, thời gian hoạt động, khu vực hiện tại, tiến độ mục tiêu doanh thu & số cuốc.
   - Thống kê hôm nay: Số cuốc ghi nhận, số cuốc hoàn thành, doanh thu, TB/giờ, quãng đường, thời gian chờ TB, hiệu quả/km.
   - Bảng **READY CHECK** minh bạch giữa trạng thái kiểm tra bằng API hệ thống iOS (Internet `NWPathMonitor`, CoreLocation, Pin `UIDevice`) và các mục Người dùng tự xác nhận.
   - Các nút hành động lớn thao tác một tay: `BẮT ĐẦU CA CHẠY`, `KẾT THÚC CA CHẠY`, `MỞ GRAB DRIVER` (qua Apple Shortcuts), `PHÂN TÍCH HIỆU QUẢ`.
3. **Module 2 – Smart Opportunity Engine (`OpportunityEngineView.swift`)**:
   - Phân tích khu vực và 8 khung giờ cá nhân (Sáng sớm, Cao điểm sáng, Giữa sáng, Trưa, Chiều, Cao điểm chiều, Tối, Đêm – cho phép chỉnh sửa).
   - Gợi ý khu vực tiếp theo kèm lý do, khoảng cách và cấp độ tin cậy (`HIGH CONFIDENCE`, `MEDIUM CONFIDENCE`, `LOW CONFIDENCE`, `NO DATA`).
   - Khi chưa có dữ liệu, hiển thị rõ `CHƯA ĐỦ DỮ LIỆU PHÂN TÍCH`, tuyệt đối không tạo bản đồ nhiệt giả.
4. **Module 3 & 4 – Smart Ride Filter & Ride Scoring (`RideFilterAndScoringView.swift`)**:
   - Thiết lập giá trị chuyến tối thiểu (15K, 20K, 25K, 30K, 40K, tùy chỉnh), khoảng cách đón (1km, 2km, 3km, 5km, không giới hạn), phân loại độ dài cuốc và chế độ lọc `STRICT`, `BALANCED`, `FLEXIBLE`.
   - Chấm điểm chuyến xe từ `0 – 100` (4 mức: Rất phù hợp, Phù hợp, Cần cân nhắc, Hiệu quả thấp) với trọng số tùy chỉnh (mặc định 25/15/20/20/10/10).
   - Chặn chấm điểm khi thiếu dữ liệu quan trọng và giải thích chi tiết điểm cộng / điểm trừ.
5. **Module 5 – Smart Location Assistant (`SmartLocationAssistantView.swift`)**:
   - Sử dụng `CoreLocation` (`requestWhenInUseAuthorization`), hiển thị bản đồ `MapKit`, lưu vị trí yêu thích, tính khoảng cách và mở chỉ đường qua Apple Maps hoặc Google Maps khi đã dừng xe an toàn.
6. **Module 6 – Official Grab Features Center (`OfficialGrabFeaturesCenterView.swift`)**:
   - Hướng dẫn chi tiết **GrabNow**, **Tự động nhận cuốc (Auto Accept)**, **Điểm đến yêu thích (2 bánh)** và **Thông báo & Chương trình thưởng** kèm nguồn chính thức `grab.com/vn/blog/driver/`, ngày kiểm chứng và trạng thái xác minh.
7. **Module 7 – Quick Response (`ShortcutAndQuickResponseView.swift`)**:
   - Hướng dẫn 7 bước tạo phím tắt `MỞ GRAB` trên Apple Shortcuts + Back Tap và danh sách kiểm tra tối ưu chuông thông báo iPhone.
8. **Module 8 – Personal Demand Analytics (`PersonalDemandAnalyticsView.swift`)**:
   - Biểu đồ `Swift Charts` theo ngày, theo giờ và phân tích hiệu suất khu vực từ dữ liệu cá nhân.
9. **Module 9 – Shift Optimizer (`ShiftAndIncomeViews.swift`)**:
   - Bắt đầu, tạm nghỉ, tiếp tục, kết thúc ca chạy và cảnh báo nghỉ ngơi định kỳ an toàn.
10. **Module 10 – Income & Fuel Manager (`ShiftAndIncomeViews.swift`)**:
    - Tính toán chính xác Doanh thu TB/km, Doanh thu TB/giờ, Chi phí nhiên liệu và Lợi nhuận ước tính; gắn nhãn phân biệt rõ `THỰC TẾ` và `ƯỚC TÍNH`.
11. **Module 11 – History Management (`HistoryManagementView.swift`)**:
    - Xem, tìm kiếm, lọc theo ngày/khu vực/hiệu quả, sửa, xóa và xuất file CSV chuẩn UTF-8 BOM.
12. **Module 12 – iPhone Widget (`RideAssistWidget.swift`)**:
    - Hỗ trợ `systemSmall` và `systemMedium` qua `WidgetKit` + `AppIntents` chia sẻ dữ liệu qua App Groups.
13. **Module 13, 14, 15 – Smart Notification, Configuration Center & Offline Mode**:
    - Nhắc nhở ca chạy nội bộ qua `UserNotifications`, quản lý nhiều cấu hình (Chạy sáng, Chạy trưa, Chạy tối, Cuốc ngắn, Gần nhà) và hoạt động 100% khi mất mạng đối với các tính năng cục bộ.

---

## 3. Các hạn chế môi trường hiện tại & Phần cần thực hiện trên máy Mac

- **Môi trường phát triển hiện tại:** Windows (`win32`).
- **Đã hoàn thành trên Windows:** 100% mã nguồn Swift 5.9 / SwiftUI, cấu trúc MVVM, Unit Tests (`XCTest`), `Info.plist`, `PrivacyInfo.xcprivacy`, `RideAssistPro.entitlements`, `Package.swift`, `project.yml` và `RideAssistPro.xcodeproj`.
- **Phần cần máy Mac cài Xcode (Chưa thực hiện trên Windows):**
  - Biên dịch (`xcodebuild`) với iOS SDK.
  - Chạy thực tế bộ Unit Tests trên iOS Simulator.
  - Ký ứng dụng (Code Signing với Apple ID / Apple Developer Account) và đóng gói file `.ipa` cài lên iPhone thực tế.
  - Xem hướng dẫn chi tiết từng bước tại [BUILD_IOS.md](file:///d:/code%20t%C3%AAst/grap/RideAssistPro/Documentation/BUILD_IOS.md).
