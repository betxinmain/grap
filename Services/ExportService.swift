//
//  ExportService.swift
//  RideAssistPro
//

import Foundation

final class ExportService {
    static let shared = ExportService()
    
    /// Xuất lịch sử cuốc xe do tài xế tự ghi nhận sang định dạng CSV chuẩn UTF-8
    func generateRideHistoryCSV(records: [RideHistoryRecord]) -> String {
        var lines: [String] = []
        lines.append("# Dữ liệu lịch sử cuốc xe cá nhân do người dùng tự ghi nhận trên Ride Assist Pro (Không phải dữ liệu lấy từ hệ thống Grab)")
        lines.append("ID,ThoiGian,KhuVucDon,KhuVucTra,TrangThai,CuocThucNhanVND,TipThuongVND,TongThuNhapVND,QuangDuongDonKm,QuangDuongChuyenKm,TongQuangDuongKm,ThoiGianChayPhut,ThoiGianChoPhut,ChiPhiXangUocTinhVND,LoiNhuanUocTinhVND,DiemDanhGia,GhiChu")
        
        for r in records {
            let timeStr = Formatters.dateTimeFormatter.string(from: r.timestamp)
            let pickup = escapeCSV(r.pickupArea)
            let dropoff = escapeCSV(r.dropoffArea)
            let status = escapeCSV(r.status.rawValue)
            let scoreStr = r.evaluationScore.map { String($0) } ?? ""
            let noteStr = escapeCSV(r.notes)
            
            let row = [
                r.id.uuidString,
                escapeCSV(timeStr),
                pickup,
                dropoff,
                status,
                String(format: "%.0f", r.netFareVND),
                String(format: "%.0f", r.tipOrBonusVND),
                String(format: "%.0f", r.totalIncomeVND),
                String(format: "%.2f", r.pickupDistanceKm),
                String(format: "%.2f", r.tripDistanceKm),
                String(format: "%.2f", r.totalDistanceKm),
                String(format: "%.0f", r.durationMinutes),
                String(format: "%.0f", r.waitingMinutesBeforeRide),
                String(format: "%.0f", r.fuelCostEstimatedVND),
                String(format: "%.0f", r.estimatedNetProfitVND),
                scoreStr,
                noteStr
            ].joined(separator: ",")
            
            lines.append(row)
        }
        return lines.joined(separator: "\n")
    }
    
    func writeCSVToTempFile(csvContent: String, fileName: String = "RideAssistPro_History.csv") -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        do {
            // Thêm UTF-8 BOM để Excel trên máy tính đọc tiếng Việt không bị lỗi font
            let bom = "\u{FEFF}"
            try (bom + csvContent).write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
    
    private func escapeCSV(_ field: String) -> String {
        let cleaned = field.replacingOccurrences(of: "\"", with: "\"\"")
        if cleaned.contains(",") || cleaned.contains("\n") || cleaned.contains("\"") {
            return "\"\(cleaned)\""
        }
        return cleaned
    }
}
