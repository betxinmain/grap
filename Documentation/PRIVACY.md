# CHÍNH SÁCH QUYỀN RIÊNG TƯ & QUẢN LÝ DỮ LIỆU (PRIVACY.md)

## 1. Nguyên tắc Quyền riêng tư trên iPhone

- **Xử lý cục bộ (On-Device First):** Toàn bộ dữ liệu cá nhân của tài xế (Hồ sơ, Tiêu chí lọc cuốc, Lịch sử chuyến xe tự nhập, Ca chạy, Chi phí nhiên liệu, Điểm chờ yêu thích) được lưu trữ ngay trên thiết bị thông qua `UserDefaults` / `App Groups` cục bộ.
- **Không thu thập và không bán dữ liệu:** Ứng dụng không gửi dữ liệu vị trí, thu nhập hay lịch sử di chuyển của tài xế về bất kỳ máy chủ nào.
- **Khai báo Privacy Manifest chuẩn Apple (`PrivacyInfo.xcprivacy`):**
  - `NSPrivacyTracking`: `false`
  - `NSPrivacyCollectedDataTypes`: Rỗng (Không thu thập dữ liệu người dùng ra khỏi thiết bị).
  - `NSPrivacyAccessedAPITypes`: Khai báo hợp lệ `NSPrivacyAccessedAPICategoryUserDefaults` với mã lý do `CA92.1` (Lưu trữ dữ liệu cục bộ của chính ứng dụng).

---

## 2. Quyền Vị trí (CoreLocation)

- Ứng dụng **chỉ yêu cầu quyền vị trí khi người dùng chủ động bấm nút bật** (`requestWhenInUseAuthorization`).
- Nếu người dùng **từ chối quyền vị trí**, toàn bộ các chức năng cốt lõi khác (Dashboard, Chấm điểm cuốc, Quản lý ca chạy, Phân tích doanh thu, Lịch sử, Xuất CSV) vẫn hoạt động đầy đủ 100%.
- **Không yêu cầu quyền vị trí chạy nền (`Always Authorization`).**

---

## 3. Quyền Kiểm soát Dữ liệu của Người dùng

Trong màn hình **Cài đặt > Quản lý Dữ liệu & Quyền riêng tư (`DataAndPrivacyManagementView`)**, người dùng có toàn quyền:
1. **Xóa dữ liệu vị trí:** Xóa sạch toàn bộ các điểm lưu trên bản đồ và xóa trường tọa độ (`latitude`, `longitude`) khỏi lịch sử cuốc xe.
2. **Xuất dữ liệu cá nhân:** Xuất toàn bộ dữ liệu sang định dạng `JSON` (Backup) hoặc `CSV` (Excel) để tự lưu trữ.
3. **Xóa toàn bộ dữ liệu ứng dụng:** Xóa sạch 100% dữ liệu về trạng thái xuất xưởng.
