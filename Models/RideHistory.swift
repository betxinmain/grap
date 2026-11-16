//
//  RideHistory.swift
//  RideAssistPro
//

import Foundation

enum RideCompletionStatus: String, Codable, CaseIterable, Identifiable {
    case completed = "Hoàn thành"
    case evaluatedOnly = "Chỉ chấm điểm"
    case cancelledByCustomer = "Khách hủy"
    
    var id: String { rawValue }
}

struct RideHistoryRecord: Codable, Identifiable, Equatable {
    var id: UUID
    var timestamp: Date
    var shiftId: UUID?
    var pickupArea: String
    var dropoffArea: String
    var netFareVND: Double
    var tipOrBonusVND: Double
    var pickupDistanceKm: Double
    var tripDistanceKm: Double
    var durationMinutes: Double
    var waitingMinutesBeforeRide: Double
    var fuelCostEstimatedVND: Double
    var evaluationScore: Int?
    var evaluationTier: String?
    var status: RideCompletionStatus
    var notes: String
    var latitude: Double?
    var longitude: Double?
    
    var totalIncomeVND: Double {
        netFareVND + tipOrBonusVND
    }
    
    var totalDistanceKm: Double {
        pickupDistanceKm + tripDistanceKm
    }
    
    var efficiencyPerKm: Double {
        guard totalDistanceKm > 0 else { return 0 }
        return totalIncomeVND / totalDistanceKm
    }
    
    var efficiencyPerHour: Double {
        guard durationMinutes > 0 else { return 0 }
        return totalIncomeVND / (durationMinutes / 60.0)
    }
    
    var estimatedNetProfitVND: Double {
        totalIncomeVND - fuelCostEstimatedVND
    }
}
