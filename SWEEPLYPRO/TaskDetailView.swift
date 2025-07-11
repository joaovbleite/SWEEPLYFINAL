//
//  TaskDetailView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    
    let task: Task
    
    // State variables
    @State private var showActionSheet = false
    @State private var showNotesExpanded = false
    @State private var showScheduleOptions = false
    @State private var showTeamOptions = false
    @State private var showEditTask = false
    @State private var notes: String = ""
    @State private var showCompletionMessage = false
    @State private var isTaskCompleted = false
    
    // Colors
    let primaryColor = Color(hex: "#153B3F")
    let backgroundColor = Color(hex: "#F5F5F5")
    let greenColor = Color(hex: "#4CAF50")
    let dividerColor = Color(hex: "#E5E7EB")
    let arrowColor = Color(hex: "#4CAF50")
    let textColor = Color(hex: "#64748B")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                
                // Task icon
                Image(systemName: "checkmark.square")
                    .font(.system(size: 28))
                    .foregroundColor(primaryColor)
                    .padding(.horizontal, 16)
                
                // Task title
                Text(task.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(primaryColor)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                
                // Task description
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                }
                
                // Schedule section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Schedule")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    
                    Text(task.dueDate == nil ? "This task hasn't been scheduled" : formatFullDate(task.dueDate!))
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    // Complete Task button
                    Button(action: {
                        completeTask()
                    }) {
                        Text("Complete Task")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(greenColor)
                    .cornerRadius(8)
                    
                    // More options button
                    Button(action: {
                        showActionSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#64748B"))
                            .frame(width: 48, height: 48)
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                    .background(dividerColor)
                
                // Notes section
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation {
                            showNotesExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text("Notes")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(primaryColor)
                            
                            Spacer()
                            
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(arrowColor)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    
                    if showNotesExpanded {
                        VStack(alignment: .leading, spacing: 8) {
                            TextEditor(text: $notes)
                                .font(.system(size: 16))
                                .foregroundColor(primaryColor)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "#D1D5DB"), lineWidth: 1)
                                )
                            
                            Button(action: {
                                // Save notes
                                task.taskDescription = notes
                                try? modelContext.save()
                                showNotesExpanded = false
                            }) {
                                Text("Save")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(greenColor)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                
                Divider()
                    .background(dividerColor)
                
                // Schedule section
                VStack(alignment: .leading, spacing: 0) {
                    Text("Schedule")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(primaryColor)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    Button(action: {
                        showScheduleOptions = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 22))
                                .foregroundColor(primaryColor)
                                .frame(width: 32)
                            
                            Text(task.dueDate == nil ? "Unscheduled" : formatFullDate(task.dueDate!))
                                .font(.system(size: 18))
                                .foregroundColor(primaryColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(arrowColor)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    
                    Divider()
                        .padding(.leading, 64)
                }
                
                // Team section
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        showTeamOptions = true
                    }) {
                        HStack {
                            Image(systemName: "person.2")
                                .font(.system(size: 22))
                                .foregroundColor(primaryColor)
                                .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Team")
                                    .font(.system(size: 18))
                                    .foregroundColor(primaryColor)
                                
                                Text(task.assignee.isEmpty ? "Unassigned" : task.assignee)
                                    .font(.system(size: 18))
                                    .foregroundColor(textColor)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(arrowColor)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .background(backgroundColor)
        .navigationBarHidden(true)
        .onAppear {
            // Initialize notes with task description
            notes = task.taskDescription
        }
        .confirmationDialog("Task Options", isPresented: $showActionSheet, titleVisibility: .hidden) {
            Button("Edit Task", role: .none) {
                showEditTask = true
            }
            Button("Delete Task", role: .destructive) {
                deleteTask()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showScheduleOptions) {
            ScheduleOptionsView(task: task, modelContext: modelContext)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showTeamOptions) {
            TeamOptionsView(task: task, modelContext: modelContext)
                .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $showEditTask) {
            NewTaskView(task: task)
        }
        .overlay(
            Group {
                if showCompletionMessage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text("Task completed successfully and archived")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(greenColor)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showCompletionMessage)
                }
            }
        )
    }
    
    // Function to mark task as completed
    private func completeTask() {
        task.status = "Completed"
        
        // Save changes to SwiftData
        do {
            try modelContext.save()
            
            // Show completion message and mark task as completed
            isTaskCompleted = true
            showCompletionMessage = true
            
            // Dismiss the view after a short delay to allow the user to see the message
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("Failed to complete task: \(error)")
        }
    }
    
    // Function to delete the task
    private func deleteTask() {
        modelContext.delete(task)
        
        // Try to save the deletion
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete task: \(error)")
        }
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
    
    // Format the date (full format)
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Schedule Options Sheet View
struct ScheduleOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    var task: Task
    var modelContext: ModelContext
    
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showDatePicker {
                    VStack(spacing: 16) {
                        DatePicker(
                            "Select a date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Removed the "Set Date" button here
                    }
                } else {
                    List {
                        Button(action: {
                            task.dueDate = nil
                            saveChanges()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Unscheduled")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: {
                            task.dueDate = Calendar.current.startOfDay(for: Date())
                            saveChanges()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Today")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: {
                            task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                            saveChanges()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Tomorrow")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: {
                            showDatePicker = true
                        }) {
                            Text("Custom Date")
                                .font(.system(size: 17))
                                .foregroundColor(.primary)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                if showDatePicker {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Set") {
                            task.dueDate = selectedDate
                            saveChanges()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}

// Team Options Sheet View
struct TeamOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    var task: Task
    var modelContext: ModelContext
    
    @State private var assignee = ""
    
    init(task: Task, modelContext: ModelContext) {
        self.task = task
        self.modelContext = modelContext
        _assignee = State(initialValue: task.assignee)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                List {
                    Button(action: {
                        task.assignee = ""
                        saveChanges()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Unassigned")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        task.assignee = "Me"
                        saveChanges()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Me")
                            .font(.system(size: 17))
                            .foregroundColor(.primary)
                    }
                    
                    Section(header: Text("Custom Assignee")) {
                        TextField("Enter name", text: $assignee)
                            .font(.system(size: 17))
                            .padding(.vertical, 8)
                        
                        Button(action: {
                            if !assignee.isEmpty {
                                task.assignee = assignee
                                saveChanges()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Assign")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(assignee.isEmpty ? Color.gray : Color(hex: "#4CAF50"))
                                .cornerRadius(8)
                        }
                        .disabled(assignee.isEmpty)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save task: \(error)")
        }
    }
}

#Preview {
    // Create a sample task for preview
    let task = Task(
        title: "Testingt",
        taskDescription: "This is a test task with instructions.",
        status: "Open",
        priority: "Medium",
        dueDate: nil,
        assignee: ""
    )
    
    return TaskDetailView(task: task)
} 