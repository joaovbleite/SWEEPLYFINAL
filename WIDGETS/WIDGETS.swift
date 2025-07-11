//
//  WIDGETS.swift
//  WIDGETS
//
//  Created by Joao Leite on 7/6/25.
//

import WidgetKit
import SwiftUI

struct SweeplyWidget: Widget {
    let kind: String = "sweeply.SWEEPLYPRO.WIDGETS"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: SweeplyWidgetProvider()) { entry in
            // Widget view based on size
            switch entry.family {
            case .systemSmall:
                SweeplySmallWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            case .systemMedium:
                SweeplyMediumWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            case .systemLarge:
                SweeplyLargeWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            default:
                SweeplySmallWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
            }
        }
        .configurationDisplayName("Sweeply Business Dashboard")
        .description("Track your daily customers and tasks at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Preview configurations
extension ConfigurationAppIntent {
    fileprivate static var blue: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayMode = .alternating
        intent.colorTheme = .blue
        return intent
    }
    
    fileprivate static var green: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayMode = .alternating
        intent.colorTheme = .green
        return intent
    }
    
    fileprivate static var teal: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayMode = .alternating
        intent.colorTheme = .teal
        return intent
    }
}

// Preview for the widget
#Preview(as: .systemSmall) {
    SweeplyWidget()
} timeline: {
    SweeplyWidgetEntry(
        date: .now, 
        configuration: .blue, 
        customersToday: 5, 
        tasksDueToday: 8, 
        alternateView: false, 
        family: .systemSmall,
        overdueTasks: 2,
        totalRevenue: 1250.0,
        pendingInvoices: 3
    )
    SweeplyWidgetEntry(
        date: .now, 
        configuration: .blue, 
        customersToday: 5, 
        tasksDueToday: 8, 
        alternateView: true, 
        family: .systemSmall,
        overdueTasks: 2,
        totalRevenue: 1250.0,
        pendingInvoices: 3
    )
}

#Preview(as: .systemMedium) {
    SweeplyWidget()
} timeline: {
    SweeplyWidgetEntry(
        date: .now, 
        configuration: .green, 
        customersToday: 3, 
        tasksDueToday: 12, 
        alternateView: false, 
        family: .systemMedium,
        overdueTasks: 1,
        totalRevenue: 950.0,
        pendingInvoices: 2
    )
}

#Preview(as: .systemLarge) {
    SweeplyWidget()
} timeline: {
    SweeplyWidgetEntry(
        date: .now, 
        configuration: .teal, 
        customersToday: 7, 
        tasksDueToday: 5, 
        alternateView: false, 
        family: .systemLarge,
        overdueTasks: 3,
        totalRevenue: 1750.0,
        pendingInvoices: 4
    )
}
