# BÁO CÁO KIỂM THỬ & ĐẢM BẢO CHẤT LƯỢNG (TEST_REPORT.md)

> **Tuyên bố trung thực theo Mục 2 & Mục 22 của Master Prompt:**  
> Môi trường thực thi hiện tại là **Windows (`win32`)**, không có trình biên dịch `swift` / `xcodebuild` và không có iOS Simulator của macOS. Do đó, theo quy tắc *"Không tự đánh dấu PASS nếu chưa chạy thực tế trên iPhone/Xcode"*, báo cáo này phân tách rõ ràng giữa:
> 1. **Kiểm tra Mã nguồn Tĩnh & Logic Công thức (Static & Algorithmic Verification trên Windows):** Đã rà soát 100%.
> 2. **Trạng thái Thực thi XCTest trên Xcode / iPhone:** Đang ở trạng thái `PENDING MAC/XCODE EXECUTION` (Sẵn sàng chạy ngay khi mở trên máy Mac cài Xcode).

---

## 1. Bảng 20 Kịch bản Kiểm thử theo Yêu cầu (Mục 22)

| STT | Hạng mục Kiểm thử | File Kiểm thử / Thực thi | Trạng thái Mã nguồn | Trạng thái Chạy Thực tế trên Xcode (Mac) |
| :-: | :--- | :--- | :---: | :---: |
| 1 | Khởi chạy ứng dụng lần đầu (Splash -> Onboarding -> Dashboard) | `RideAssistProApp.swift`, `SplashAndOnboardingViews.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 2 | Lưu cấu hình bộ lọc & trọng số | `StorageAndShiftTests.swift`, `AppStateManager.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 3 | Khởi động lại vẫn còn cấu hình (`UserDefaults` / App Groups) | `StorageService.swift`, `StorageAndShiftTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 4 | Tính điểm cuốc xe (0–100) và phân hạng 4 mức | `RideScoringService.swift`, `RideScoringTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 5 | Xử lý dữ liệu thiếu (Chặn chấm điểm khi cước = 0, km = 0, phút = 0) | `RideScoringService.swift`, `RideScoringTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 6 | Tính doanh thu trung bình / km (`Doanh thu / Tổng quãng đường`) | `IncomeService.swift`, `IncomeTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 7 | Tính doanh thu trung bình / giờ (`Doanh thu / Tổng thời gian hoạt động`) | `IncomeService.swift`, `IncomeTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 8 | Tính chi phí nhiên liệu (`(Tổng km / 100) × Lít/100km × Giá xăng/lít`) | `IncomeService.swift`, `IncomeTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 9 | Tính lợi nhuận ước tính (`Doanh thu - Nhiên liệu - Vận hành`) | `IncomeService.swift`, `IncomeTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 10 | Tạo ca chạy mới, tạm nghỉ, tiếp tục ca | `ShiftService.swift`, `StorageAndShiftTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 11 | Kết thúc ca chạy & lưu vào lịch sử ca | `ShiftService.swift`, `StorageAndShiftTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 12 | Lưu lịch sử cuốc, sửa và xóa bản ghi lịch sử | `HistoryManagementView.swift`, `AppStateManager.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 13 | Xuất file CSV lịch sử cuốc (Chuẩn UTF-8 BOM mở trên Excel) | `ExportService.swift`, `StorageAndShiftTests.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 14 | Xóa dữ liệu vị trí & Xóa toàn bộ dữ liệu ứng dụng (Reset 100%) | `StorageService.swift`, `DataAndPrivacyManagementView` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 15 | Chuyển đổi giao diện Light Mode / Dark Mode (Semantic System Colors) | Toàn bộ `Views/` sử dụng `systemGroupedBackground` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 16 | Widget nhỏ & vừa cập nhật qua `WidgetCenter.shared.reloadAllTimelines()` | `RideAssistWidget.swift`, `StorageService.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 17 | Từ chối quyền vị trí (Ứng dụng không văng, báo trạng thái rõ ràng) | `LocationService.swift`, `SmartLocationAssistantView.swift` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 18 | Mất kết nối Internet (Hiển thị banner Offline, tính năng cục bộ chạy 100%) | `NetworkMonitor.swift`, `MainTabView` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 19 | Tương thích iOS 16, 17, 18 (`#available(iOS 17.0, *)` fallback cho Widget) | `RideAssistWidget.swift`, `project.pbxproj` | Đã hoàn thiện | `PENDING MAC/XCODE` |
| 20 | Kiểm tra quyền riêng tư & Bảng ACCOUNT SAFETY cấp P0 | `AccountSafetyView`, `PrivacyInfo.xcprivacy` | Đã hoàn thiện | `PENDING MAC/XCODE` |

---

## 2. Hướng dẫn chạy bộ Unit Tests trên máy Mac

Khi mở dự án trên máy Mac có cài Xcode, chạy lệnh sau trong Terminal tại thư mục `RideAssistPro`:

```bash
xcodebuild test \
  -project RideAssistPro.xcodeproj \
  -scheme RideAssistPro \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```
Hoặc mở `RideAssistPro.xcodeproj` trong Xcode và nhấn tổ hợp phím **Cmd + U**.
