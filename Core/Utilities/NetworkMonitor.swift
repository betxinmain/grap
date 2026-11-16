//
//  NetworkMonitor.swift
//  RideAssistPro
//

import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var connectionType: String = "Wi-Fi / 4G"
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.rideassistpro.networkmonitor")
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = "Wi-Fi"
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = "Dữ liệu di động (4G/5G)"
                } else if path.status == .satisfied {
                    self?.connectionType = "Đã kết nối"
                } else {
                    self?.connectionType = "Ngoại tuyến (Offline)"
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
