//
//  LocationViewModel.swift
//  RideAssistPro
//

import Foundation
import CoreLocation
import MapKit

final class LocationViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009), // Trung tâm TP.HCM mặc định
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    )
    @Published var selectedCategoryFilter: SavedLocationCategory? = nil
    @Published var showAddLocationSheet: Bool = false
    @Published var preferGoogleMaps: Bool = false
    
    func centerOnUserLocation(_ location: CLLocation?) {
        guard let loc = location else { return }
        region = MKCoordinateRegion(
            center: loc.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    }
    
    func filteredLocations(from all: [SavedDriverLocation]) -> [SavedDriverLocation] {
        guard let filter = selectedCategoryFilter else { return all }
        return all.filter { $0.category == filter }
    }
}
