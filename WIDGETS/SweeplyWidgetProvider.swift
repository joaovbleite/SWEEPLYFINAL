//
//  SweeplyWidgetProvider.swift
//  WIDGETS
//
//  Created for Sweeply Pro
//

import WidgetKit
import SwiftUI
import SwiftData

// Import models from main app
struct Client {
    var firstName: String
    var lastName: String
    var companyName: String
    var phoneNumber: String
    var phoneLabel: String
    var receivesTextMessages: Bool
    var email: String
    var leadSource: String
    var propertyAddress: String
    var billingAddress: String
    var createdAt: Date
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return companyName.isEmpty ? "Unnamed Client" : companyName
        }
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Define TaskItem to avoid conflict with SwiftUI's Task
struct TaskItem {
    var title: String
    var taskDescription: String
    var status: String
    var priority: String
    var dueDate: Date?
    var assignee: String
    var createdAt: Date
}

// Widget entry model
struct SweeplyWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let customersToday: Int
    let tasksDueToday: Int
    let alternateView: Bool
    var family: WidgetFamily = .systemSmall
    
    // Additional business metrics
    let overdueTasks: Int
    let totalRevenue: Double
    let pendingInvoices: Int
    
    // Helper to determine what to show in alternating mode
    var showCustomers: Bool {
        if configuration.displayMode == .customers {
            return true
        } else if configuration.displayMode == .tasks {
            return false
        } else {
            // For alternating mode, use the alternateView flag
            return alternateView
        }
    }
}

// Widget provider
struct SweeplyWidgetProvider: IntentTimelineProvider {
    typealias Intent = SweeplyWidgetConfigurationIntent
    typealias Entry = SweeplyWidgetEntry
    
    // Placeholder for widget gallery
    func placeholder(in context: Context) -> SweeplyWidgetEntry {
        SweeplyWidgetEntry(
            date: Date(),
            configuration: SweeplyWidgetConfigurationIntent(),
            customersToday: 5,
            tasksDueToday: 8,
            showCustomers: true,
            totalRevenue: 1250.0,
            pendingInvoices: 3,
            overdueTasks: 2
        )
    }

    // Snapshot for widget gallery
    func getSnapshot(for configuration: SweeplyWidgetConfigurationIntent, in context: Context, completion: @escaping (SweeplyWidgetEntry) -> ()) {
        let entry = SweeplyWidgetEntry(
            date: Date(),
            configuration: configuration,
            customersToday: 5,
            tasksDueToday: 8,
            showCustomers: configuration.displayMode == .customers || (configuration.displayMode == .alternating),
            totalRevenue: 1250.0,
            pendingInvoices: 3,
            overdueTasks: 2
        )
        completion(entry)
    }
    
    // Timeline for widget updates
    func getTimeline(for configuration: SweeplyWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<SweeplyWidgetEntry>) -> ()) {
        var entries: [SweeplyWidgetEntry] = []
        let currentDate = Date()
        
        // Get current data from the data manager
        let dataManager = WidgetDataManager.shared
        let customersToday = dataManager.getClientsCreatedToday()
        let tasksDueToday = dataManager.getTasksDueToday()
        let overdueTasks = dataManager.getOverdueTasks()
        let totalRevenue = dataManager.getTotalRevenue()
        let pendingInvoices = dataManager.getPendingInvoiceCount()
        
        // For alternating mode, create entries that alternate between customers and tasks
        if configuration.displayMode == .alternating {
            // First entry shows customers
            entries.append(SweeplyWidgetEntry(
                date: currentDate,
                configuration: configuration,
                customersToday: customersToday,
                tasksDueToday: tasksDueToday,
                showCustomers: true,
                totalRevenue: totalRevenue,
                pendingInvoices: pendingInvoices,
                overdueTasks: overdueTasks
            ))
            
            // Second entry shows tasks (30 seconds later)
            entries.append(SweeplyWidgetEntry(
                date: Calendar.current.date(byAdding: .second, value: 30, to: currentDate)!,
                configuration: configuration,
                customersToday: customersToday,
                tasksDueToday: tasksDueToday,
                showCustomers: false,
                totalRevenue: totalRevenue,
                pendingInvoices: pendingInvoices,
                overdueTasks: overdueTasks
            ))
            
            // Third entry goes back to customers (60 seconds from now)
            entries.append(SweeplyWidgetEntry(
                date: Calendar.current.date(byAdding: .second, value: 60, to: currentDate)!,
                configuration: configuration,
                customersToday: customersToday,
                tasksDueToday: tasksDueToday,
                showCustomers: true,
                totalRevenue: totalRevenue,
                pendingInvoices: pendingInvoices,
                overdueTasks: overdueTasks
            ))
        } else {
            // For non-alternating modes, update every hour
            for hourOffset in 0..<24 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SweeplyWidgetEntry(
                    date: entryDate,
                    configuration: configuration,
                    customersToday: customersToday,
                    tasksDueToday: tasksDueToday,
                    showCustomers: configuration.displayMode == .customers,
                    totalRevenue: totalRevenue,
                    pendingInvoices: pendingInvoices,
                    overdueTasks: overdueTasks
                )
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
} 