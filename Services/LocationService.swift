//
//  LocationService.swift
//  RideAssistPro
//

import Foundation
import CoreLocation
import Combine
#if canImport(UIKit)
import UIKit
#endif

final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var currentDistrictOrAreaName: String = "Chưa xác định vị trí"
    @Published private(set) var locationError: String?
    
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 150 // Hạn chế cập nhật dày gây hao pin
        authorizationStatus = manager.authorizationStatus
    }
    
    var isAuthorizedWhenInUse: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var authorizationStatusLabel: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Chưa cấp quyền"
        case .restricted:
            return "Bị giới hạn"
        case .denied:
            return "Đã từ chối quyền vị trí"
        case .authorizedWhenInUse:
            return "Cho phép khi dùng ứng dụng"
        case .authorizedAlways:
            return "Đã cấp quyền"
        @unknown default:
            return "Không xác định"
        }
    }
    
    /// Chỉ xin quyền vị trí khi người dùng chủ động bật chức năng. Không xin quyền chạy nền.
    func requestWhenInUsePermission() {
        locationError = nil
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if isAuthorizedWhenInUse {
            manager.requestLocation()
        } else {
            locationError = "Quyền vị trí đang tắt. Bạn có thể bật lại trong Cài đặt iPhone > Quyền riêng tư > Dịch vụ định vị nếu muốn sử dụng bản đồ."
        }
    }
    
    func refreshSingleLocation() {
        guard isAuthorizedWhenInUse else {
            return
        }
        manager.requestLocation()
    }
    
    func clearCachedRuntimeLocation() {
        currentLocation = nil
        currentDistrictOrAreaName = "Đã xóa vị trí tạm thời"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if self.isAuthorizedWhenInUse {
                manager.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = latest
            self.locationError = nil
            self.reverseGeocodeArea(latest)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Không thể lấy vị trí hiện tại: \(error.localizedDescription)"
        }
    }
    
    private func reverseGeocodeArea(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let placemark = placemarks?.first else { return }
            let subAdmin = placemark.subAdministrativeArea ?? placemark.locality ?? ""
            let subLocality = placemark.subLocality ?? ""
            let combined = [subLocality, subAdmin].filter { !$0.isEmpty }.joined(separator: ", ")
            DispatchQueue.main.async {
                if !combined.isEmpty {
                    self?.currentDistrictOrAreaName = combined
                } else {
                    self?.currentDistrictOrAreaName = String(
                        format: "%.4f, %.4f",
                        location.coordinate.latitude,
                        location.coordinate.longitude
                    )
                }
            }
        }
    }
    
    /// Mở chỉ đường trên Apple Maps hoặc Google Maps (chỉ thực hiện khi người dùng chủ động bấm và đã dừng xe an toàn)
    func openExternalMap(latitude: Double, longitude: Double, label: String, preferGoogleMaps: Bool) {
        #if canImport(UIKit)
        let encodedLabel = label.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "DiemDen"
        if preferGoogleMaps,
           let googleURL = URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"),
           UIApplication.shared.canOpenURL(googleURL) {
            UIApplication.shared.open(googleURL)
            return
        }
        if let appleURL = URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&q=\(encodedLabel)") {
            UIApplication.shared.open(appleURL)
        }
        #endif
    }
}
