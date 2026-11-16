//
//  StorageService.swift
//  RideAssistPro
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

final class StorageService: StorageServiceProtocol {
    static let shared = StorageService()
    
    private let userDefaults: UserDefaults
    private let sharedDefaults: UserDefaults?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
        
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = enc
        
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        self.decoder = dec
    }
    
    func save<T: Codable>(_ value: T, forKey key: String) throws {
        let data = try encoder.encode(value)
        userDefaults.set(data, forKey: key)
        sharedDefaults?.set(data, forKey: key)
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = userDefaults.data(forKey: key),
           let decoded = try? decoder.decode(type, from: data) {
            return decoded
        }
        if let sharedData = sharedDefaults?.data(forKey: key),
           let decoded = try? decoder.decode(type, from: sharedData) {
            return decoded
        }
        return nil
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        sharedDefaults?.removeObject(forKey: key)
    }
    
    func saveBool(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
        sharedDefaults?.set(value, forKey: key)
    }
    
    func loadBool(forKey key: String, defaultValue: Bool = false) -> Bool {
        if userDefaults.object(forKey: key) != nil {
            return userDefaults.bool(forKey: key)
        }
        return defaultValue
    }
    
    func updateWidgetSnapshot(_ snapshot: WidgetDataSnapshot) {
        try? save(snapshot, forKey: AppConstants.StorageKeys.widgetSnapshot)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    func clearLocationDataOnly() {
        remove(forKey: AppConstants.StorageKeys.savedAreas)
        if var history = load([RideHistoryRecord].self, forKey: AppConstants.StorageKeys.rideHistory) {
            for index in history.indices {
                history[index].latitude = nil
                history[index].longitude = nil
            }
            try? save(history, forKey: AppConstants.StorageKeys.rideHistory)
        }
    }
    
    func clearAllAppData() {
        let keys = [
            AppConstants.StorageKeys.driverProfile,
            AppConstants.StorageKeys.activeConfigurationId,
            AppConstants.StorageKeys.configurations,
            AppConstants.StorageKeys.rideHistory,
            AppConstants.StorageKeys.shiftRecords,
            AppConstants.StorageKeys.currentShift,
            AppConstants.StorageKeys.savedAreas,
            AppConstants.StorageKeys.timeSlotConfigs,
            AppConstants.StorageKeys.incomeSettings,
            AppConstants.StorageKeys.expenseRecords,
            AppConstants.StorageKeys.readyCheckState,
            AppConstants.StorageKeys.notificationSettings,
            AppConstants.StorageKeys.isDemoMode,
            AppConstants.StorageKeys.widgetSnapshot
        ]
        for key in keys {
            remove(forKey: key)
        }
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    struct FullExportBundle: Codable {
        var exportedAt: Date
        var appVersion: String
        var profile: DriverProfile?
        var configurations: [RideCriteria]
        var rideHistory: [RideHistoryRecord]
        var shiftRecords: [ShiftRecord]
        var savedAreas: [SavedDriverLocation]
        var fuelSettings: FuelAndExpenseSettings?
        var expenses: [ExpenseItem]
    }
    
    func exportAllDataJSON() throws -> Data {
        let bundle = FullExportBundle(
            exportedAt: Date(),
            appVersion: AppConstants.appVersion,
            profile: load(DriverProfile.self, forKey: AppConstants.StorageKeys.driverProfile),
            configurations: load([RideCriteria].self, forKey: AppConstants.StorageKeys.configurations) ?? [],
            rideHistory: load([RideHistoryRecord].self, forKey: AppConstants.StorageKeys.rideHistory) ?? [],
            shiftRecords: load([ShiftRecord].self, forKey: AppConstants.StorageKeys.shiftRecords) ?? [],
            savedAreas: load([SavedDriverLocation].self, forKey: AppConstants.StorageKeys.savedAreas) ?? [],
            fuelSettings: load(FuelAndExpenseSettings.self, forKey: AppConstants.StorageKeys.incomeSettings),
            expenses: load([ExpenseItem].self, forKey: AppConstants.StorageKeys.expenseRecords) ?? []
        )
        return try encoder.encode(bundle)
    }
}
