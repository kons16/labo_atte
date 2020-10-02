//
//  AttendingWidget.swift
//  AttendingWidget
//
//  Created by jun on 2020/10/01.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.com.Taped.labo-atte")
    
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), currentAttendingNum: 0)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        guard let num = userDefaults?.object(forKey: "currentNumOfAttendees") as? Int else {
            let entry = SimpleEntry(date: Date(), currentAttendingNum: -1)
            completion(entry)
            return
        }
        let entry = SimpleEntry(date: Date(), currentAttendingNum: num)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        if let num = userDefaults?.object(forKey: "currentNumOfAttendees") as? Int {
            let entry = SimpleEntry(date: Date(), currentAttendingNum: num)
            entries.append(entry)
        } else {
            let entry = SimpleEntry(date: Date(), currentAttendingNum: -1)
            entries.append(entry)
        }

        
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    var currentAttendingNum: Int
}

struct AttendingWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("現在の人数")
                .font(.custom("Hiragino Maru Gothic ProN", size: 16))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            HStack(alignment: .bottom) {
                let str = entry.currentAttendingNum == -1 ? "-" : String(entry.currentAttendingNum)
                Text(String(str))
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundColor(.gray)
                    .frame(height: 27)
                
                Text("人")
                    .font(.custom("Hiragino Maru Gothic ProN", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 0))
        .foregroundColor(.gray)
        
    }
}

@main
struct AttendingWidget: Widget {
    let kind: String = "今いる人数を確認"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            AttendingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Labo Atte")
        .description("今いる人数が表示されます。")
        .supportedFamilies([.systemSmall])
    }
}

struct AttendingWidget_Previews: PreviewProvider {
    static var previews: some View {
        AttendingWidgetEntryView(entry: SimpleEntry(date: Date(), currentAttendingNum: 0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
