//
//  SmartLocationAssistantView.swift
//  RideAssistPro
//

import SwiftUI
import MapKit

struct SmartLocationAssistantView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel = LocationViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    safetyNoticeBanner
                    permissionControlCard
                    mapDisplayCard
                    categoryFilterBar
                    savedLocationsListSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Bản đồ Khu vực")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showAddLocationSheet = true
                    } label: {
                        Label("Lưu vị trí", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddLocationSheet) {
                AddSavedLocationSheet()
            }
        }
    }
    
    private var safetyNoticeBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.raised.fill")
                .foregroundColor(AppTheme.warningAmber)
            Text("An toàn giao thông: Chỉ xem bản đồ và thao tác khi bạn đã dừng xe sát lề an toàn. Không tạo bản đồ cuốc chờ giả.")
                .font(.caption2)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private var permissionControlCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Trạng thái định vị: \(locationService.authorizationStatusLabel)", systemImage: "location.circle.fill")
                    .font(.caption.bold())
                Spacer()
                if locationService.isAuthorizedWhenInUse {
                    Button("Định vị lại") {
                        locationService.refreshSingleLocation()
                        viewModel.centerOnUserLocation(locationService.currentLocation)
                    }
                    .font(.caption.bold())
                } else {
                    Button("Bật vị trí") {
                        locationService.requestWhenInUsePermission()
                    }
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.primaryGreen)
                }
            }
            
            if let err = locationService.locationError {
                Text(err)
                    .font(.caption2)
                    .foregroundColor(AppTheme.warningAmber)
            }
            
            HStack {
                Text("Ứng dụng mở chỉ đường bên ngoài:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Picker("Bản đồ", selection: $viewModel.preferGoogleMaps) {
                    Text("Apple Maps").tag(false)
                    Text("Google Maps").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var mapDisplayCard: some View {
        let pins = viewModel.filteredLocations(from: appState.savedLocations)
        return VStack(alignment: .leading, spacing: 8) {
            Map(
                coordinateRegion: $viewModel.region,
                showsUserLocation: locationService.isAuthorizedWhenInUse,
                annotationItems: pins
            ) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    VStack(spacing: 2) {
                        Image(systemName: place.category.symbolName)
                            .font(.title3)
                            .foregroundColor(AppTheme.primaryGreen)
                            .padding(4)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                        Text(place.areaDistrict)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(.systemBackground).opacity(0.9))
                            .cornerRadius(4)
                    }
                }
            }
            .frame(height: 250)
            .cornerRadius(14)
            
            Text("Hiển thị các vị trí bạn đã lưu và đánh dấu cá nhân. Không theo dõi vị trí liên tục ở chế độ nền.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    viewModel.selectedCategoryFilter = nil
                } label: {
                    Text("Tất cả (\(appState.savedLocations.count))")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(viewModel.selectedCategoryFilter == nil ? AppTheme.primaryGreen : Color(.secondarySystemGroupedBackground))
                        .foregroundColor(viewModel.selectedCategoryFilter == nil ? .white : .primary)
                        .cornerRadius(8)
                }
                
                ForEach(SavedLocationCategory.allCases) { cat in
                    let isSelected = viewModel.selectedCategoryFilter == cat
                    Button {
                        viewModel.selectedCategoryFilter = cat
                    } label: {
                        Label(cat.rawValue, systemImage: cat.symbolName)
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(isSelected ? AppTheme.primaryGreen : Color(.secondarySystemGroupedBackground))
                            .foregroundColor(isSelected ? .white : .primary)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var savedLocationsListSection: some View {
        let items = viewModel.filteredLocations(from: appState.savedLocations)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Danh sách khu vực & điểm chờ đã lưu")
                .font(.subheadline.bold())
            
            if items.isEmpty {
                Text("Chưa có điểm lưu nào trong danh mục này. Bấm 'Lưu vị trí' ở góc trên để thêm mới.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            } else {
                ForEach(items) { loc in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: loc.category.symbolName)
                                .foregroundColor(AppTheme.primaryGreen)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(loc.name)
                                    .font(.subheadline.bold())
                                Text("\(loc.areaDistrict) • \(loc.category.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if let userLoc = locationService.currentLocation {
                                Text(Formatters.formatDistanceKm(loc.distanceKm(from: userLoc)))
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.primaryGreen)
                            }
                        }
                        
                        if loc.recordedRidesCount > 0 {
                            HStack(spacing: 14) {
                                Text("Đã ghi nhận: \(loc.recordedRidesCount) cuốc")
                                Text("Giá TB: \(Formatters.formatVND(loc.averageFareVND))")
                                Text("Chờ TB: \(Int(round(loc.averageWaitMinutes)))p")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                        
                        if !loc.notes.isEmpty {
                            Text(loc.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 10) {
                            Button {
                                viewModel.region = MKCoordinateRegion(
                                    center: loc.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                )
                            } label: {
                                Label("Xem trên bản đồ", systemImage: "mappin.and.ellipse")
                                    .font(.caption.bold())
                            }
                            
                            Spacer()
                            
                            Button {
                                locationService.openExternalMap(
                                    latitude: loc.latitude,
                                    longitude: loc.longitude,
                                    label: loc.name,
                                    preferGoogleMaps: viewModel.preferGoogleMaps
                                )
                            } label: {
                                Label(viewModel.preferGoogleMaps ? "Mở Google Maps" : "Mở Apple Maps", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.primaryGreen)
                            }
                            
                            Button(role: .destructive) {
                                appState.savedLocations.removeAll { $0.id == loc.id }
                                appState.persistSavedLocations()
                            } label: {
                                Image(systemName: "trash")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct AddSavedLocationSheet: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var district: String = "Quận 1"
    @State private var category: SavedLocationCategory = .favoriteSpot
    @State private var latitude: Double = 10.7769
    @State private var longitude: Double = 106.7009
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Thông tin vị trí hoạt động") {
                    TextField("Tên điểm (VD: Ngã tư Phú Nhuận)", text: $name)
                    TextField("Quận / Khu vực (VD: Quận Phú Nhuận)", text: $district)
                    Picker("Phân loại", selection: $category) {
                        ForEach(SavedLocationCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    TextField("Ghi chú kinh nghiệm đậu xe", text: $notes)
                }
                
                Section("Tọa độ") {
                    if let current = locationService.currentLocation {
                        Button("Lấy tọa độ vị trí hiện tại của tôi") {
                            latitude = current.coordinate.latitude
                            longitude = current.coordinate.longitude
                            if !locationService.currentDistrictOrAreaName.isEmpty {
                                district = locationService.currentDistrictOrAreaName
                            }
                        }
                    }
                    HStack {
                        Text("Vĩ độ (Lat)")
                        Spacer()
                        TextField("10.7769", value: $latitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Kinh độ (Lng)")
                        Spacer()
                        TextField("106.7009", value: $longitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Lưu điểm hoạt động")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        let newLoc = SavedDriverLocation(
                            id: UUID(),
                            name: name.isEmpty ? "Điểm đã lưu (\(district))" : name,
                            areaDistrict: district,
                            category: category,
                            latitude: latitude,
                            longitude: longitude,
                            recordedRidesCount: 0,
                            averageFareVND: 0,
                            averageWaitMinutes: 0,
                            notes: notes,
                            createdAt: Date()
                        )
                        appState.savedLocations.insert(newLoc, at: 0)
                        appState.persistSavedLocations()
                        dismiss()
                    }
                }
            }
        }
    }
}
