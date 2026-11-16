//
//  Formatters.swift
//  RideAssistPro
//

import Foundation

enum Formatters {
    static let vndCurrencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = . decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    static func formatVND(_ amount: Double) -> String {
        let number = NSNumber(value: round(amount))
        let formatted = vndCurrencyFormatter.string(from: number) ?? "\(Int(round(amount)))"
        return "\(formatted) đ"
    }
    
    static func formatShortVND(_ amount: Double) -> String {
        if abs(amount) >= 1_000_000 {
            return String(format: "%.2f Tr", amount / 1_000_000)
        } else if abs(amount) >= 1_000 {
            return String(format: "%.0fK", amount / 1_000)
        }
        return formatVND(amount)
    }
    
    static func formatDistanceKm(_ km: Double) -> String {
        return String(format: "%.1f km", km)
    }
    
    static func formatDuration(seconds: TimeInterval) -> String {
        let totalMinutes = max(0, Int(seconds) / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)g \(minutes)p"
        }
        return "\(minutes) phút"
    }
    
    static func formatHours(_ hours: Double) -> String {
        return String(format: "%.1f giờ", hours)
    }
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "vi_VN")
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()
    
    static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "vi_VN")
        df.dateFormat = "HH:mm"
        return df
    }()
    
    static let dateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "vi_VN")
        df.dateFormat = "HH:mm - dd/MM/yyyy"
        return df
    }()
}
