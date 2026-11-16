//
//  OfficialGrabFeaturesCenterView.swift
//  RideAssistPro
//

import SwiftUI

struct OfficialGrabFeaturesCenterView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !networkMonitor.isConnected {
                        HStack(spacing: 8) {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(AppTheme.warningAmber)
                            Text("Thiết bị đang ngoại tuyến (Offline). Dữ liệu hướng dẫn bên dưới được lưu cục bộ vào ngày kiểm chứng gần nhất và có thể chưa cập nhật thay đổi mới nhất trên website Grab.")
                                .font(.caption2)
                        }
                        .padding(12)
                        .background(AppTheme.warningAmber.opacity(0.15))
                        .cornerRadius(10)
                    }
                    
                    headerNoticeCard
                    
                    ForEach($appState.officialFeatures) { $feature in
                        featureGuideCard(feature: $feature)
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tính năng Grab Chính thức")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Đóng") {
                        appState.persistOfficialFeatures()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerNoticeCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppTheme.primaryGreen)
                Text("TRUNG TÂM TÍNH NĂNG NHẬN CHUYẾN CHÍNH THỨC")
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.primaryGreen)
            }
            Text("Tổng hợp từ trang thông tin chính thức của Grab Việt Nam (grab.com/vn/blog/driver/). Ride Assist Pro chỉ hướng dẫn thao tác hợp lệ, tuyệt đối không tự bật tính năng hay can thiệp vào ứng dụng Grab Driver.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func featureGuideCard(feature: Binding<OfficialGrabFeatureGuideItem>) -> some View {
        let item = feature.wrappedValue
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.category.uppercased())
                        .font(.caption2.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                    Text(item.title)
                        .font(.headline)
                }
                Spacer()
                Menu {
                    ForEach(OfficialFeatureVerificationState.allCases, id: \.rawValue) { st in
                        Button(st.rawValue) {
                            feature.wrappedValue.verificationState = st
                            feature.wrappedValue.lastVerifiedDate = Formatters.dateFormatter.string(from: Date())
                            appState.persistOfficialFeatures()
                        }
                    }
                } label: {
                    verificationBadge(item.verificationState)
                }
            }
            
            Text(item.summary)
                .font(.subheadline)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Điều kiện sử dụng & Phạm vi:")
                    .font(.caption.bold())
                Text("• Khu vực áp dụng: \(item.applicableAreas)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(item.conditionsToUse, id: \.self) { cond in
                    Text("• \(cond)")
                        .font(.caption)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Quy trình kích hoạt hợp lệ trên Grab Driver:")
                    .font(.caption.bold())
                ForEach(item.activationSteps, id: \.self) { step in
                    Text(step)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Lưu ý quan trọng về Tỷ lệ nhận, Tỷ lệ hủy & Thưởng:")
                    .font(.caption.bold())
                    .foregroundColor(AppTheme.warningAmber)
                ForEach(item.importantNotesAndRateImpacts, id: \.self) { note in
                    Text("• \(note)")
                        .font(.caption)
                }
            }
            .padding(10)
            .background(AppTheme.warningAmber.opacity(0.1))
            .cornerRadius(8)
            
            HStack {
                Text("Ngày kiểm chứng: \(item.lastVerifiedDate)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                if let url = URL(string: item.officialURL) {
                    Link(destination: url) {
                        Label("Xem nguồn Grab chính thức", systemImage: "safari.fill")
                            .font(.caption.bold())
                            .foregroundColor(AppTheme.primaryGreen)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func verificationBadge(_ state: OfficialFeatureVerificationState) -> some View {
        let color: Color = {
            switch state {
            case .verified: return AppTheme.primaryGreen
            case .needsReview: return AppTheme.warningAmber
            case .unverified: return .secondary
            case .expired: return AppTheme.dangerRed
            }
        }()
        return Text(state.rawValue)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.16))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}
