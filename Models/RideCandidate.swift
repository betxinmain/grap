//
//  RideCandidate.swift
//  RideAssistPro
//

import Foundation

enum ReturnTripLikelihood: String, Codable, CaseIterable, Identifiable {
    case high = "Cao (Khu sầm uất)"
    case medium = "Trung bình"
    case low = "Thấp (Dễ chạy rỗng chiều về)"
    
    var id: String { rawValue }
    
    var bonusMultiplier: Double {
        switch self {
        case .high: return 1.0
        case .medium: return 0.75
        case .low: return 0.35
        }
    }
}

struct RideCandidate: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var netFareVND: Double
    var pickupDistanceKm: Double
    var tripDistanceKm: Double
    var estimatedDurationMinutes: Double
    var pickupArea: String
    var dropoffArea: String
    var destinationType: DestinationPreferenceType
    var returnTripLikelihood: ReturnTripLikelihood
    var extraFeeOrTipVND: Double
    var notes: String
    
    var totalDistanceKm: Double {
        max(0, pickupDistanceKm) + max(0, tripDistanceKm)
    }
    
    var totalIncomeVND: Double {
        max(0, netFareVND) + max(0, extraFeeOrTipVND)
    }
    
    static let empty = RideCandidate(
        netFareVND: 25_000,
        pickupDistanceKm: 1.0,
        tripDistanceKm: 3.5,
        estimatedDurationMinutes: 14,
        pickupArea: "Quận 1",
        dropoffArea: "Quận 3",
        destinationType: .priorityArea,
        returnTripLikelihood: .high,
        extraFeeOrTipVND: 0,
        notes: ""
    )
}
