//
//  FindmeWidgetLiveActivity.swift
//  FindmeWidget
//
//  Created by Евгений Полтавец on 12/12/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FindmeWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FindmeWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FindmeWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FindmeWidgetAttributes {
    fileprivate static var preview: FindmeWidgetAttributes {
        FindmeWidgetAttributes(name: "World")
    }
}

extension FindmeWidgetAttributes.ContentState {
    fileprivate static var smiley: FindmeWidgetAttributes.ContentState {
        FindmeWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FindmeWidgetAttributes.ContentState {
         FindmeWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FindmeWidgetAttributes.preview) {
   FindmeWidgetLiveActivity()
} contentStates: {
    FindmeWidgetAttributes.ContentState.smiley
    FindmeWidgetAttributes.ContentState.starEyes
}
