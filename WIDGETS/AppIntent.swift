//
//  AppIntent.swift
//  WIDGETS
//
//  Created by Joao Leite on 7/6/25.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Configure your Sweeply widget." }

    // Widget display mode
    @Parameter(title: "Display Mode", default: .alternating)
    var displayMode: DisplayMode
    
    // Widget color theme
    @Parameter(title: "Color Theme", default: .blue)
    var colorTheme: ColorTheme
}

// Display mode options
enum DisplayMode: String, AppEnum {
    case customers = "Customers"
    case tasks = "Tasks"
    case alternating = "Alternating"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Display Mode"
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .customers: "Customers Only",
        .tasks: "Tasks Only",
        .alternating: "Alternate Between Both"
    ]
}

// Color theme options
enum ColorTheme: String, AppEnum {
    case blue = "Blue"
    case green = "Green"
    case teal = "Teal"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Color Theme"
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .blue: "Blue",
        .green: "Green",
        .teal: "Teal"
    ]
    
    var primaryColor: String {
        switch self {
        case .blue: return "#246BFD"
        case .green: return "#4CAF50"
        case .teal: return "#153B3F"
        }
    }
    
    var secondaryColor: String {
        switch self {
        case .blue: return "#EAF0FF"
        case .green: return "#E8F5E9"
        case .teal: return "#E0F2F1"
        }
    }
}
