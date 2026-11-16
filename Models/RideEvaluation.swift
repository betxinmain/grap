//
//  RideEvaluation.swift
//  RideAssistPro
//

import Foundation

enum RideScoreTier: String, Codable {
    case highlySuitable = "Rất phù hợp"     // 85 - 100
    case suitable = "Phù hợp"               // 70 - 84
    case consider = "Cần cân nhắc"          // 50 - 69
    case lowEfficiency = "Hiệu quả thấp"    // < 50
    
    static func from(score: Int) -> RideScoreTier {
        switch score {
        case 85...100: return .highlySuitable
        case 70...84: return .suitable
        case 50...69: return .consider
        default: return .lowEfficiency
        }
    }
}

struct RideEvaluationBreakdown: Codable, Equatable {
    var fareSubScore: Double              // 0 - 100
    var pickupDistanceSubScore: Double    // 0 - 100
    var efficiencyPerKmSubScore: Double   // 0 - 100
    var efficiencyPerHourSubScore: Double // 0 - 100
    var destinationSubScore: Double       // 0 - 100
    var operatingCostSubScore: Double     // 0 - 100
}

struct RideEvaluation: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var evaluatedAt: Date = Date()
    var candidate: RideCandidate
    var criteriaProfileName: String
    var filterMode: FilterMode
    var totalScore: Int                   // 0 - 100
    var tier: RideScoreTier
    var passesFilterCriteria: Bool
    var revenuePerKmVND: Double
    var revenuePerHourVND: Double
    var estimatedFuelCostVND: Double
    var estimatedNetProfitVND: Double
    var rideLengthClassification: String  // "Cuốc ngắn", "Cuốc trung bình", "Cuốc dài"
    var breakdown: RideEvaluationBreakdown
    var positiveReasons: [String]
    var warningReasons: [String]
    var personalAssessmentNote: String
}
