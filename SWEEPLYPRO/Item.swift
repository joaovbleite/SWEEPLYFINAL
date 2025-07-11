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
