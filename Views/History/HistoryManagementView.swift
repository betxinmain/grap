//
//  HistoryManagementView.swift
//  RideAssistPro
//

import SwiftUI

struct HistoryManagementView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var searchText: String = ""
    @State private var selectedAreaFilter: String = "Tất cả"
    @State private var minimumEfficiencyFilter: Double = 0
    @State private var filterByDateEnabled: Bool = false
    @State private var selectedDate: Date = Date()
    @State private var editingRecord: RideHistoryRecord? = nil
    @State private var exportedCSVFileURL: URL? = nil
    @State private var showAddManualRideSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterHeaderSection
                
                let records = filteredRecords
                if records.isEmpty {
                    emptyHistoryView
                } else {
                    List {
                        Section {
                            ForEach(records) { item in
                                historyRow(item)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            appState.deleteRideRecord(id: item.id)
                                        } label: {
                                            Label("Xóa", systemImage: "trash")
                                        }
                                        Button {
                                            editingRecord = item
                                        } label: {
                                            Label("Sửa", systemImage: "pencil")
                                        }
                                        .tint(AppTheme.accentTeal)
                                    }
                            }
                        } header: {
                            Text("Danh sách cuốc đã nhập (\(records.count)) • Không phải dữ liệu lấy từ hệ thống Grab")
                                .font(.caption2)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color(.systemGroupedBackground))
            .searchable(text: $searchText, prompt: "Tìm khu vực đón, trả hoặc ghi chú...")
            .navigationTitle("Lịch sử Cuốc & Ca")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        let csv = ExportService.shared.generateRideHistoryCSV(records: filteredRecords)
                        exportedCSVFileURL = ExportService.shared.writeCSVToTempFile(csvContent: csv)
                    } label: {
                        Label("Xuất CSV", systemImage: "square.and.arrow.up")
                            .font(.caption.bold())
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddManualRideSheet = true
                    } label: {
                        Label("Nhập cuốc", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(item: $editingRecord) { record in
                EditRideRecordSheet(record: record)
            }
            .sheet(isPresented: $showAddManualRideSheet) {
                RideFilterAndScoringView()
            }
        }
    }
    
    private var filterHeaderSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Khu vực:")
                    .font(.caption)
                Picker("Khu vực", selection: $selectedAreaFilter) {
                    ForEach(availableAreaOptions, id: \.self) { area in
                        Text(area).tag(area)
                    }
                }
                .pickerStyle(.menu)
                
                Spacer()
                
                Toggle("Lọc theo ngày", isOn: $filterByDateEnabled)
                    .font(.caption)
                    .fixedSize()
            }
            
            if filterByDateEnabled {
                DatePicker("Chọn ngày", selection: $selectedDate, displayedComponents: .date)
                    .font(.caption)
            }
            
            HStack {
                Text("Hiệu quả tối thiểu: \(Formatters.formatVND(minimumEfficiencyFilter))/km")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Slider(value: $minimumEfficiencyFilter, in: 0...12_000, step: 1_000)
            }
            
            if let fileURL = exportedCSVFileURL {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(AppTheme.primaryGreen)
                    Text("Đã tạo file CSV (\(filteredRecords.count) dòng)")
                        .font(.caption.bold())
                    Spacer()
                    ShareLink(item: fileURL) {
                        Label("Chia sẻ / Lưu CSV", systemImage: "square.and.arrow.up")
                            .font(.caption.bold())
                    }
                }
                .padding(8)
                .background(AppTheme.primaryGreen.opacity(0.12))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 46))
                .foregroundColor(.secondary)
            Text("Chưa có lịch sử cuốc xe phù hợp")
                .font(.headline)
            Text("Dữ liệu lịch sử do bạn chủ động nhập hoặc lưu sau khi chấm điểm cuốc xe.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
    
    private func historyRow(_ item: RideHistoryRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(item.pickupArea) → \(item.dropoffArea)")
                    .font(.subheadline.bold())
                Spacer()
                Text(Formatters.formatVND(item.totalIncomeVND))
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.primaryGreen)
            }
            
            HStack(spacing: 12) {
                Text(Formatters.dateTimeFormatter.string(from: item.timestamp))
                Text("• \(item.status.rawValue)")
                if let score = item.evaluationScore {
                    Text("• Điểm: \(score)/100")
                        .foregroundColor(AppTheme.primaryGreen)
                }
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            
            HStack {
                Text("Quãng đường: \(Formatters.formatDistanceKm(item.totalDistanceKm))")
                Spacer()
                Text("Hiệu quả: \(Formatters.formatVND(item.efficiencyPerKm))/km")
                Spacer()
                Text("Lợi nhuận ròng ~\(Formatters.formatVND(item.estimatedNetProfitVND))")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            
            if !item.notes.isEmpty {
                Text("Ghi chú: \(item.notes)")
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            editingRecord = item
        }
    }
    
    private var availableAreaOptions: [String] {
        let areas = Set(appState.rideHistory.map { $0.pickupArea }.filter { !$0.isEmpty })
        return ["Tất cả"] + areas.sorted()
    }
    
    private var filteredRecords: [RideHistoryRecord] {
        let cal = Calendar.current
        return appState.rideHistory.filter { record in
            if selectedAreaFilter != "Tất cả" && record.pickupArea != selectedAreaFilter {
                return false
            }
            if filterByDateEnabled && !cal.isDate(record.timestamp, inSameDayAs: selectedDate) {
                return false
            }
            if record.efficiencyPerKm < minimumEfficiencyFilter {
                return false
            }
            if !searchText.isEmpty {
                let q = searchText.lowercased()
                let matchPickup = record.pickupArea.lowercased().contains(q)
                let matchDropoff = record.dropoffArea.lowercased().contains(q)
                let matchNotes = record.notes.lowercased().contains(q)
                if !(matchPickup || matchDropoff || matchNotes) {
                    return false
                }
            }
            return true
        }
    }
}

struct EditRideRecordSheet: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    @State var record: RideHistoryRecord
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Khu vực đón & trả") {
                    TextField("Khu vực đón", text: $record.pickupArea)
                    TextField("Khu vực trả", text: $record.dropoffArea)
                    Picker("Trạng thái", selection: $record.status) {
                        ForEach(RideCompletionStatus.allCases) { st in
                            Text(st.rawValue).tag(st)
                        }
                    }
                }
                
                Section("Thu nhập & Quãng đường") {
                    HStack {
                        Text("Cước thực nhận (VNĐ)")
                        Spacer()
                        TextField("25000", value: $record.netFareVND, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Tip / Thưởng (VNĐ)")
                        Spacer()
                        TextField("0", value: $record.tipOrBonusVND, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Quãng đường đón (km)")
                        Spacer()
                        TextField("1.0", value: $record.pickupDistanceKm, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Quãng đường chuyến (km)")
                        Spacer()
                        TextField("3.5", value: $record.tripDistanceKm, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Thời gian chạy (phút)")
                        Spacer()
                        TextField("15", value: $record.durationMinutes, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Thời gian chờ (phút)")
                        Spacer()
                        TextField("5", value: $record.waitingMinutesBeforeRide, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Ghi chú") {
                    TextField("Ghi chú", text: $record.notes)
                }
            }
            .navigationTitle("Chỉnh sửa dữ liệu cuốc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        appState.updateRideRecord(record)
                        dismiss()
                    }
                }
            }
        }
    }
}
