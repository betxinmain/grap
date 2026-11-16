//
//  SplashAndOnboardingViews.swift
//  RideAssistPro
//

import SwiftUI

struct SplashScreenView: View {
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.deepNavy, AppTheme.darkGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logo độc lập, tuyệt đối không sử dụng logo Grab
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryGreen.opacity(0.2))
                        .frame(width: 128, height: 128)
                    Circle()
                        .stroke(AppTheme.primaryGreen, lineWidth: 3)
                        .frame(width: 112, height: 112)
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text(AppConstants.appName)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1.2)
                    
                    Text(AppConstants.appSubtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppTheme.primaryGreen)
                        .tracking(2.0)
                    
                    Text(AppConstants.appVietnameseTitle)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.top, 4)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Phiên bản \(AppConstants.appVersion) (Build \(AppConstants.appBuild))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                    
                    Text("Ứng dụng trợ lý tài xế độc lập • Bảo vệ tài khoản cấp P0")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 32)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onFinished()
            }
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject var locationService: LocationService
    var onComplete: () -> Void
    
    @State private var currentPage: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                onboardingPage(
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    title: "Tối ưu hiệu quả chạy GrabBike",
                    subtitle: "Phân tích khu vực, khung giờ cá nhân và chấm điểm hiệu quả từng chuyến xe (0–100 điểm) để giảm thời gian chờ và tối ưu lợi nhuận ròng.",
                    bullets: [
                        "Ứng dụng trợ lý độc lập, KHÔNG thay thế ứng dụng Grab Driver.",
                        "Hỗ trợ thiết lập bộ lọc tiêu chí cá nhân (Giá cước, Khoảng cách đón, Điểm đến).",
                        "Quản lý ca chạy, chi phí nhiên liệu và lợi nhuận ước tính minh bạch."
                    ]
                )
                .tag(0)
                
                onboardingPage(
                    icon: "lock.shield.fill",
                    title: "Nguyên tắc An toàn Tài khoản P0",
                    subtitle: "Bảo vệ tài khoản Grab của bạn là ưu tiên số 1. Ride Assist Pro hoạt động hoàn toàn cách ly.",
                    bullets: [
                        "KHÔNG đăng nhập tài khoản Grab, KHÔNG thu thập mật khẩu hay OTP.",
                        "KHÔNG tự động bấm nhận, từ chối hoặc hủy chuyến.",
                        "KHÔNG đọc thông báo từ ứng dụng khác trên iOS 16–18.",
                        "Toàn bộ dữ liệu được lưu cục bộ ngay trên iPhone của bạn."
                    ]
                )
                .tag(1)
                
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "location.magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundColor(AppTheme.primaryGreen)
                    
                    Text("Quyền Vị trí Tuỳ chọn")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Nếu bạn muốn xem bản đồ các điểm chờ yêu thích và tính khoảng cách tới khu vực hiệu quả, hãy cấp quyền vị trí 'Khi dùng ứng dụng'. Bạn hoàn toàn có thể bỏ qua và dùng các chức năng khác bình thường.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Button {
                            locationService.requestWhenInUsePermission()
                        } label: {
                            Label("Cấp quyền vị trí khi dùng ứng dụng", systemImage: "location.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.primaryGreen.opacity(0.15))
                                .foregroundColor(AppTheme.primaryGreen)
                                .cornerRadius(AppTheme.buttonCornerRadius)
                        }
                        
                        Text("Trạng thái hiện tại: \(locationService.authorizationStatusLabel)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            VStack(spacing: 12) {
                Button {
                    if currentPage < 2 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentPage < 2 ? "Tiếp tục" : "Bắt đầu sử dụng Ride Assist Pro")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryGreen)
                        .cornerRadius(AppTheme.buttonCornerRadius)
                }
                
                if currentPage < 2 {
                    Button("Bỏ qua giới thiệu") {
                        onComplete()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(20)
        }
    }
    
    private func onboardingPage(icon: String, title: String, subtitle: String, bullets: [String]) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 68))
                .foregroundColor(AppTheme.primaryGreen)
            
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(bullets, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppTheme.primaryGreen)
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
            .padding(18)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(AppTheme.cardCornerRadius)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}
