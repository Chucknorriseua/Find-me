//
//  FindmeWidget.swift
//  FindmeWidget
//
//  Created by Евгений Полтавец on 12/12/2024.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let sharedDefaults = UserDefaults(suiteName: "group.findme.com")
        let isButtonPressed = sharedDefaults?.bool(forKey: "isButtonPressed") ?? false
        
        let currentDate = Date()

        let entry = SimpleEntry(date: currentDate, configuration: ConfigurationAppIntent(isButtonPressed: isButtonPressed))
        entries.append(entry)

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct FindmeWidgetEntryView: View {

    var entry: Provider.Entry

    var body: some View {
        VStack {
            Button(intent: entry.configuration) {
                if !entry.configuration.isButtonPressed {
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text("Find me")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                } else {
                    Image(systemName: "sensor.tag.radiowaves.forward.fill")
                        .resizable()
                        .frame(width: 26, height: 26)
                    Text("Broadcast")
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .padding(.all, 6)
                }
            }
        }
    }
}

struct FindmeWidget: Widget {
    let kind: String = "FindmeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            FindmeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    FindmeWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
