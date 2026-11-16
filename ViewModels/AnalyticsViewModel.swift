//
//  AnalyticsViewModel.swift
//  RideAssistPro
//

import Foundation

enum AnalyticsPeriodFilter: String, CaseIterable, Identifiable {
    case today = "Hôm nay"
    case sevenDays = "7 ngày"
    case thirtyDays = "30 ngày"
    case allTime = "Toàn bộ"
    
    var id: String { rawValue }
}

struct DailyRevenuePoint: Identifiable, Equatable {
    var id: Date { date }
    var date: Date
    var dateLabel: String
    var revenueVND: Double
    var rideCount: Int
}

struct HourlyRidePoint: Identifiable, Equatable {
    var id: Int { hour }
    var hour: Int
    var hourLabel: String
    var rideCount: Int
    var averageFareVND: Double
}

final class AnalyticsViewModel: ObservableObject {
    @Published var selectedPeriod: AnalyticsPeriodFilter = .sevenDays
    
    func filteredCompletedRides(from history: [RideHistoryRecord]) -> [RideHistoryRecord] {
        let completed = history.filter { $0.status == .completed }
        let cal = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .today:
            return completed.filter { cal.isDateInToday($0.timestamp) }
        case .sevenDays:
            let start = cal.date(byAdding: .day, value: -7, to: now) ?? now
            return completed.filter { $0.timestamp >= start }
        case .thirtyDays:
            let start = cal.date(byAdding: .day, value: -30, to: now) ?? now
            return completed.filter { $0.timestamp >= start }
        case .allTime:
            return completed
        }
    }
    
    func dailyRevenueSeries(from rides: [RideHistoryRecord]) -> [DailyRevenuePoint] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: rides) { cal.startOfDay(for: $0.timestamp) }
        let sortedDates = grouped.keys.sorted()
        
        return sortedDates.map { date in
            let dayRides = grouped[date] ?? []
            let rev = dayRides.reduce(0.0) { $0 + $1.totalIncomeVND }
            return DailyRevenuePoint(
                date: date,
                dateLabel: Formatters.dateFormatter.string(from: date),
                revenueVND: rev,
                rideCount: dayRides.count
            )
        }
    }
    
    func hourlyDistribution(from rides: [RideHistoryRecord]) -> [HourlyRidePoint] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: rides) { cal.component(.hour, from: $0.timestamp) }
        return (5...23).map { hour in
            let hRides = grouped[hour] ?? []
            let totalRev = hRides.reduce(0.0) { $0 + $1.totalIncomeVND }
            let avg = hRides.isEmpty ? 0 : (totalRev / Double(hRides.count))
            return HourlyRidePoint(
                hour: hour,
                hourLabel: "\(hour)h",
                rideCount: hRides.count,
                averageFareVND: avg
            )
        }
    }
}
