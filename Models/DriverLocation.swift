//
//  DriverLocation.swift
//  RideAssistPro
//

import Foundation
import CoreLocation

enum SavedLocationCategory: String, Codable, CaseIterable, Identifiable {
    case favoriteSpot = "Điểm chờ yêu thích"
    case highEfficiencyArea = "Khu vực hiệu quả tốt"
    case frequentDropoff = "Điểm thường trả khách"
    case restStop = "Điểm nghỉ ngơi / Đổ xăng"
    case homeBase = "Gần nhà / Điểm kết thúc ca"
    
    var id: String { rawValue }
    
    var symbolName: String {
        switch self {
        case .favoriteSpot: return "star.circle.fill"
        case .highEfficiencyArea: return "flame.circle.fill"
        case .frequentDropoff: return "flag.checkered.circle.fill"
        case .restStop: return "cup.and.saucer.fill"
        case .homeBase: return "house.circle.fill"
        }
    }
}

struct SavedDriverLocation: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var areaDistrict: String
    var category: SavedLocationCategory
    var latitude: Double
    var longitude: Double
    var recordedRidesCount: Int
    var averageFareVND: Double
    var averageWaitMinutes: Double
    var notes: String
    var createdAt: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func distanceKm(from userLocation: CLLocation) -> Double {
        let target = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: target) / 1000.0
    }
    
    static let sampleLocations: [SavedDriverLocation] = [
        SavedDriverLocation(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222201") ?? UUID(),
            name: "Khu văn phòng Nguyễn Huệ - Lê Lợi",
            areaDistrict: "Quận 1",
            category: .highEfficiencyArea,
            latitude: 10.7745,
            longitude: 106.7019,
            recordedRidesCount: 0,
            averageFareVND: 0,
            averageWaitMinutes: 0,
            notes: "Khu vực trung tâm văn phòng và trung tâm thương mại.",
            createdAt: Date()
        ),
        SavedDriverLocation(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222202") ?? UUID(),
            name: "Khu vực Hồ Con Rùa - Võ Văn Tần",
            areaDistrict: "Quận 3",
            category: .favoriteSpot,
            latitude: 10.7827,
            longitude: 106.6959,
            recordedRidesCount: 0,
            averageFareVND: 0,
            averageWaitMinutes: 0,
            notes: "Nhiều bóng mát, thuận tiện di chuyển sang Q1, Phú Nhuận.",
            createdAt: Date()
        ),
        SavedDriverLocation(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222203") ?? UUID(),
            name: "Khu vực Cộng Hòa - Etown",
            areaDistrict: "Quận Tân Bình",
            category: .homeBase,
            latitude: 10.8017,
            longitude: 106.6422,
            recordedRidesCount: 0,
            averageFareVND: 0,
            averageWaitMinutes: 0,
            notes: "Thuận tiện nhận cuốc giờ tan tầm chiều về gần nhà.",
            createdAt: Date()
        )
    ]
}
