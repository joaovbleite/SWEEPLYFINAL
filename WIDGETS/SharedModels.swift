//
//  SharedModels.swift
//  WIDGETS
//
//  Created for Sweeply Pro
//

import Foundation
import SwiftData

// These models mirror the main app models but are simplified for widget use

// Client model for widget use
struct ClientModel {
    var firstName: String
    var lastName: String
    var companyName: String
    var phoneNumber: String
    var email: String
    var propertyAddress: String
    var createdAt: Date
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return companyName.isEmpty ? "Unnamed Client" : companyName
        }
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Task model for widget use (avoiding conflict with SwiftUI's Task)
struct TaskModel {
    var title: String
    var taskDescription: String
    var status: String
    var priority: String
    var dueDate: Date?
    var assignee: String
    var createdAt: Date
    
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && !Calendar.current.isDateInToday(dueDate)
    }
}

// Widget data manager
class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private init() {}
    
    // Get count of clients created today
    func getClientsCreatedToday() -> Int {
        // In a real implementation, this would use app group shared data
        // or another mechanism to share data with the main app
        
        // For demo purposes, return a random number
        return Int.random(in: 0...10)
    }
    
    // Get count of tasks due today
    func getTasksDueToday() -> Int {
        // In a real implementation, this would use app group shared data
        // or another mechanism to share data with the main app
        
        // For demo purposes, return a random number
        return Int.random(in: 0...15)
    }
    
    // Get count of overdue tasks
    func getOverdueTasks() -> Int {
        // For demo purposes
        return Int.random(in: 0...5)
    }
    
    // Get total revenue
    func getTotalRevenue() -> Double {
        // For demo purposes
        return Double.random(in: 500...2000)
    }
    
    // Get pending invoice count
    func getPendingInvoiceCount() -> Int {
        // For demo purposes
        return Int.random(in: 0...5)
    }
} 