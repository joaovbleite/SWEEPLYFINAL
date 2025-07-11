//
//  WIDGETSLiveActivity.swift
//  WIDGETS
//
//  Created by Joao Leite on 7/6/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WIDGETSAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WIDGETSLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WIDGETSAttributes.self) { context in
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

extension WIDGETSAttributes {
    fileprivate static var preview: WIDGETSAttributes {
        WIDGETSAttributes(name: "World")
    }
}

extension WIDGETSAttributes.ContentState {
    fileprivate static var smiley: WIDGETSAttributes.ContentState {
        WIDGETSAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WIDGETSAttributes.ContentState {
         WIDGETSAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WIDGETSAttributes.preview) {
   WIDGETSLiveActivity()
} contentStates: {
    WIDGETSAttributes.ContentState.smiley
    WIDGETSAttributes.ContentState.starEyes
}
