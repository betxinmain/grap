//
//  RideAssistProApp.swift
//  RideAssistPro
//
//  RIDE ASSIST PRO – TRỢ LÝ TÀI XẾ - TỐI ƯU CUỐC XE
//  Ứng dụng trợ lý độc lập dành cho tài xế GrabBike trên iPhone (iOS 16, 17, 18+)
//

import SwiftUI

@main
struct RideAssistProApp: App {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var locationService = LocationService.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some Scene {
        WindowGroup {
            RootContainerView()
                .environmentObject(appState)
                .environmentObject(locationService)
                .environmentObject(networkMonitor)
                .environmentObject(notificationService)
                .tint(AppTheme.primaryGreen)
        }
    }
}

struct RootContainerView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        ZStack {
            if appState.showSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        appState.showSplash = false
                    }
                }
            } else if !appState.hasCompletedOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        appState.completeOnboarding()
                    }
                }
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        VStack(spacing: 0) {
            if !networkMonitor.isConnected {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.caption.bold())
                    Text("Chế độ Offline: Đang hoạt động cục bộ (Đánh giá cuốc, Ca chạy, Lịch sử & Thống kê vẫn hoạt động 100%).")
                        .font(.caption2)
                        .lineLimit(2)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.warningAmber)
            }
            
            TabView(selection: $appState.selectedTab) {
                DashboardView()
                    .tabItem {
                        Label(AppTab.dashboard.title, systemImage: AppTab.dashboard.iconName)
                    }
                    .tag(AppTab.dashboard)
                
                OpportunityEngineView()
                    .tabItem {
                        Label(AppTab.opportunity.title, systemImage: AppTab.opportunity.iconName)
                    }
                    .tag(AppTab.opportunity)
                
                SmartLocationAssistantView()
                    .tabItem {
                        Label(AppTab.map.title, systemImage: AppTab.map.iconName)
                    }
                    .tag(AppTab.map)
                
                PersonalDemandAnalyticsView()
                    .tabItem {
                        Label(AppTab.analytics.title, systemImage: AppTab.analytics.iconName)
                    }
                    .tag(AppTab.analytics)
                
                HistoryManagementView()
                    .tabItem {
                        Label(AppTab.history.title, systemImage: AppTab.history.iconName)
                    }
                    .tag(AppTab.history)
                
                SettingsCenterView()
                    .tabItem {
                        Label(AppTab.settings.title, systemImage: AppTab.settings.iconName)
                    }
                    .tag(AppTab.settings)
            }
        }
    }
}
