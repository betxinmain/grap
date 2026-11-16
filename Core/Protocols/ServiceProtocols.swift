//
//  ServiceProtocols.swift
//  RideAssistPro
//

import Foundation
import CoreLocation

protocol StorageServiceProtocol {
    func save<T: Codable>(_ value: T, forKey key: String) throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func remove(forKey key: String)
    func clearAllAppData()
    func exportAllDataJSON() throws -> Data
}

protocol RideScoringServiceProtocol {
    func evaluateRide(
        candidate: RideCandidate,
        criteria: RideCriteria,
        fuelSettings: FuelAndExpenseSettings
    ) -> Result<RideEvaluation, RideScoringError>
}

enum RideScoringError: LocalizedError, Equatable {
    case missingFare
    case missingDistance
    case missingDuration
    case invalidWeights
    
    var errorDescription: String? {
        switch self {
        case .missingFare:
            return "Thiếu giá trị cuốc xe (cần lớn hơn 0 VNĐ)."
        case .missingDistance:
            return "Thiếu tổng quãng đường di chuyển (cần lớn hơn 0 km)."
        case .missingDuration:
            return "Thiếu thời gian dự kiến của chuyến đi (cần lớn hơn 0 phút)."
        case .invalidWeights:
            return "Tổng trọng số chấm điểm không hợp lệ (cần lớn hơn 0%)."
        }
    }
}
