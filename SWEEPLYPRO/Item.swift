//
//  Item.swift
//  SWEEPLYPRO
//
//  Created by Joao Leite on 7/2/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

// Task model
@Model
final class Task {
    var title: String
    var taskDescription: String
    var status: String
    var priority: String
    var dueDate: Date?
    var assignee: String
    var createdAt: Date
    var isAllDayTask: Bool
    
    init(title: String, taskDescription: String, status: String, priority: String, dueDate: Date?, assignee: String, isAllDayTask: Bool = true) {
        self.title = title
        self.taskDescription = taskDescription
        self.status = status
        self.priority = priority
        self.dueDate = dueDate
        self.assignee = assignee
        self.createdAt = Date()
        self.isAllDayTask = isAllDayTask
    }
}

// Job model for SwiftData
@Model
final class Job {
    // Basic job information
    var firstName: String
    var lastName: String
    var propertyAddress: String
    var jobTitle: String
    var instructions: String
    var phoneNumber: String
    var email: String
    var salesperson: String
    
    // Financial information
    var subtotal: Double
    
    // Scheduling information
    var scheduleLater: Bool
    var scheduledDate: Date?
    var teamMember: String
    
    // Invoicing information
    var remindToInvoice: Bool
    
    // Metadata
    var createdAt: Date
    var status: String
    
    // Relationships
    @Relationship(deleteRule: .cascade) var lineItems: [JobLineItem] = []
    @Relationship(inverse: \Client.jobs) var client: Client?
    
    init(
        firstName: String,
        lastName: String,
        propertyAddress: String,
        jobTitle: String,
        instructions: String,
        phoneNumber: String,
        email: String,
        salesperson: String,
        lineItems: [LineItem] = [],
        subtotal: Double = 0.0,
        scheduleLater: Bool = false,
        scheduledDate: Date? = nil,
        teamMember: String = "",
        remindToInvoice: Bool = false,
        client: Client? = nil,
        createdAt: Date = Date(),
        status: String = "New"
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.propertyAddress = propertyAddress
        self.jobTitle = jobTitle
        self.instructions = instructions
        self.phoneNumber = phoneNumber
        self.email = email
        self.salesperson = salesperson
        self.subtotal = subtotal
        self.scheduleLater = scheduleLater
        self.scheduledDate = scheduledDate
        self.teamMember = teamMember
        self.remindToInvoice = remindToInvoice
        self.client = client
        self.createdAt = createdAt
        self.status = status
        
        // Convert LineItem to JobLineItem
        for item in lineItems {
            let jobLineItem = JobLineItem(name: item.name, quantity: item.quantity, price: item.price)
            self.lineItems.append(jobLineItem)
        }
    }
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return "Unnamed Client"
        }
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// JobLineItem model for SwiftData
@Model
final class JobLineItem {
    var name: String
    var quantity: Int
    var price: Double
    
    @Relationship(inverse: \Job.lineItems) var job: Job?
    
    init(name: String, quantity: Int, price: Double) {
        self.name = name
        self.quantity = quantity
        self.price = price
    }
}
