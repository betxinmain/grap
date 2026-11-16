//
//  RideAssistWidget.swift
//  RideAssistProWidgetExtension
//
//  MODULE 12 – IPHONE WIDGET (WidgetKit + App Intents cho iOS 16, 17, 18)
//

import WidgetKit
import SwiftUI
#if canImport(AppIntents)
import AppIntents
#endif

struct RideAssistWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetDataSnapshot
}

struct RideAssistTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> RideAssistWidgetEntry {
        RideAssistWidgetEntry(date: Date(), snapshot: .placeholder)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RideAssistWidgetEntry) -> Void) {
        let snapshot = loadSharedSnapshot()
        completion(RideAssistWidgetEntry(date: Date(), snapshot: snapshot))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RideAssistWidgetEntry>) -> Void) {
        let snapshot = loadSharedSnapshot()
        let entry = RideAssistWidgetEntry(date: Date(), snapshot: snapshot)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
    
    private func loadSharedSnapshot() -> WidgetDataSnapshot {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier),
           let data = sharedDefaults.data(forKey: AppConstants.StorageKeys.widgetSnapshot),
           let decoded = try? decoder.decode(WidgetDataSnapshot.self, from: data) {
            return decoded
        }
        return .placeholder
    }
}

struct RideAssistWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: RideAssistTimelineProvider.Entry
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        default:
            mediumWidgetView
        }
    }
    
    // Widget nhỏ: Mục tiêu doanh thu, Số cuốc đã ghi nhận, Giờ hoạt động
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(AppTheme.primaryGreen)
                Text("RIDE ASSIST")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(AppTheme.primaryGreen)
            }
            
            Spacer(minLength: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Mục tiêu doanh thu")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Text("\(Formatters.formatShortVND(entry.snapshot.currentRevenueVND)) / \(Formatters.formatShortVND(entry.snapshot.revenueGoalVND))")
                    .font(.system(size: 14, weight: .bold))
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Số cuốc")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text("\(entry.snapshot.recordedRidesCount)")
                        .font(.system(size: 13, weight: .bold))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 1) {
                    Text("Hoạt động")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(entry.snapshot.activeHoursText)
                        .font(.system(size: 12, weight: .semibold))
                }
            }
        }
        .padding(12)
    }
    
    // Widget vừa: Khu vực ưu tiên, Giá trị cuốc mục tiêu, Khoảng cách đón tối đa, Tình trạng ca chạy, Nút mở Ride Assist
    private var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(entry.snapshot.shiftStatusText, systemImage: entry.snapshot.isShiftActive ? "bolt.circle.fill" : "clock")
                    .font(.caption.bold())
                    .foregroundColor(entry.snapshot.isShiftActive ? AppTheme.primaryGreen : .secondary)
                Spacer()
                Text("Mở Ride Assist ↗")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.primaryGreen.opacity(0.18))
                    .foregroundColor(AppTheme.primaryGreen)
                    .cornerRadius(6)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Khu vực ưu tiên")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(entry.snapshot.priorityArea.isEmpty ? "Chưa đặt" : entry.snapshot.priorityArea)
                        .font(.caption.bold())
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text("Cước tối thiểu")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(Formatters.formatVND(entry.snapshot.targetMinimumFareVND))
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primaryGreen)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    Text("Đón tối đa")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(entry.snapshot.maxPickupDistanceText)
                        .font(.caption.bold())
                }
            }
            
            Divider()
            
            HStack {
                Text("Doanh thu: \(Formatters.formatVND(entry.snapshot.currentRevenueVND)) / \(Formatters.formatVND(entry.snapshot.revenueGoalVND))")
                    .font(.caption2.weight(.semibold))
                Spacer()
                Text("Đã ghi: \(entry.snapshot.recordedRidesCount) cuốc • \(entry.snapshot.activeHoursText)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
    }
}

struct RideAssistWidget: Widget {
    let kind: String = "RideAssistWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RideAssistTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                RideAssistWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                RideAssistWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Ride Assist Pro")
        .description("Theo dõi mục tiêu doanh thu, ca chạy và tiêu chí lọc cuốc cá nhân.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#if canImport(AppIntents)
@available(iOS 16.0, *)
struct OpenRideAssistFilterIntent: AppIntent {
    static var title: LocalizedStringResource = "Mở Bộ lọc & Chấm điểm cuốc trên Ride Assist Pro"
    static var description = IntentDescription("Mở nhanh màn hình đánh giá cuốc xe cá nhân trên Ride Assist Pro.")
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        AppStateManager.shared.selectedTab = .dashboard
        return .result()
    }
}

@available(iOS 16.0, *)
struct RideAssistAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenRideAssistFilterIntent(),
            phrases: [
                "Chấm điểm cuốc xe trong \(.applicationName)",
                "Mở \(.applicationName)"
            ],
            shortTitle: "Chấm điểm cuốc",
            systemImageName: "gauge.with.dots.needle.67percent"
        )
    }
}
#endif
