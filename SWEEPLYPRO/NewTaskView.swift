//
//  NewTaskView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import SwiftData
import UIKit

struct NewTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    
    // Form fields
    @State private var title = ""
    @State private var description = ""
    @State private var status = "Open"
    @State private var priority = "Medium"
    @State private var dueDate: Date?
    @State private var assignee = "Unassigned"
    @State private var isAllDayTask = false
    @State private var selectedTime = Date()
    
    // UI state
    @State private var showSuccessMessage = false
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var selectedDate = Date()
    @State private var isEditMode = false
    @State private var existingTask: Task?
    
    // Keyboard focus state
    @FocusState private var focusedField: Field?
    
    // Status options
    let statusOptions = ["Open", "In Progress", "Completed", "On Hold"]
    
    // Priority options
    let priorityOptions = ["Low", "Medium", "High", "Urgent"]
    
    // Accent color
    let accentColor = Color(hex: "#2563EB")
    
    // Focus fields enum
    enum Field {
        case title
        case description
    }
    
    // Check if any content has been added
    private var hasContent: Bool {
        return !title.isEmpty || 
               !description.isEmpty || 
               status != "Open" || 
               priority != "Medium" || 
               dueDate != nil || 
               assignee != "Unassigned"
    }
    
    // Function to get status color
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Open":
            return Color(hex: "#3B82F6") // Blue
        case "In Progress":
            return Color(hex: "#F59E0B") // Amber
        case "Completed":
            return Color(hex: "#10B981") // Green
        case "On Hold":
            return Color(hex: "#6B7280") // Gray
        default:
            return Color(hex: "#6B7280")
        }
    }
    
    // Function to get status icon
    private func statusIcon(for status: String) -> String {
        switch status {
        case "Open":
            return "circle"
        case "In Progress":
            return "arrow.triangle.2.circlepath"
        case "Completed":
            return "checkmark.circle"
        case "On Hold":
            return "pause.circle"
        default:
            return "circle"
        }
    }
    
    // Function to get priority color
    private func priorityColor(for priority: String) -> Color {
        switch priority {
        case "Low":
            return Color(hex: "#10B981") // Green
        case "Medium":
            return Color(hex: "#F59E0B") // Amber
        case "High":
            return Color(hex: "#EF4444") // Red
        case "Urgent":
            return Color(hex: "#DC2626") // Dark Red
        default:
            return Color(hex: "#6B7280")
        }
    }
    
    // Function to get priority icon
    private func priorityIcon(for priority: String) -> String {
        switch priority {
        case "Low":
            return "arrow.down.circle"
        case "Medium":
            return "minus.circle"
        case "High":
            return "arrow.up.circle"
        case "Urgent":
            return "exclamationmark.circle"
        default:
            return "minus.circle"
        }
    }
    
    // Initializer for creating a new task
    init() {
        self._isEditMode = State(initialValue: false)
        self._existingTask = State(initialValue: nil)
    }
    
    // Initializer for editing an existing task
    init(task: Task) {
        self._isEditMode = State(initialValue: true)
        self._existingTask = State(initialValue: task)
        self._title = State(initialValue: task.title)
        self._description = State(initialValue: task.taskDescription)
        self._status = State(initialValue: task.status)
        self._priority = State(initialValue: task.priority)
        self._dueDate = State(initialValue: task.dueDate)
        self._assignee = State(initialValue: task.assignee)
        self._isAllDayTask = State(initialValue: task.isAllDayTask)
        
        // Set selected time if due date exists
        if let dueDate = task.dueDate {
            self._selectedTime = State(initialValue: dueDate)
            self._selectedDate = State(initialValue: dueDate)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with back button and title - fixed at the top
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                    
                    Spacer()
                    
                    Text(isEditMode ? "Edit Task" : "New Task")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#0F1A2B"))
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        if hasContent && !title.isEmpty {
                            HapticManager.shared.impact(style: .medium)
                            if isEditMode {
                                updateTask()
                            } else {
                                saveTask()
                            }
                        }
                    }) {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(hasContent && !title.isEmpty ? accentColor : Color.gray)
                    }
                    .disabled(!hasContent || title.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                .zIndex(1) // Ensure header stays on top
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title input field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#374151"))
                                .padding(.horizontal, 4)
                            
                            TextField("", text: $title)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#0F1A2B"))
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#D1D5DB"), lineWidth: 1)
                                )
                                .placeholderText(when: title.isEmpty) {
                                    Text("Enter task title")
                                        .foregroundColor(Color(hex: "#9CA3AF"))
                                        .padding(.leading, 0)
                                }
                                .focused($focusedField, equals: .title)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .description
                                }
                        }
                        
                        // Description input field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#374151"))
                                .padding(.horizontal, 4)
                            
                            TextEditor(text: $description)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#0F1A2B"))
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#D1D5DB"), lineWidth: 1)
                                )
                                .scrollContentBackground(.hidden)
                                .focused($focusedField, equals: .description)
                                .overlay(
                                    Group {
                                        if description.isEmpty {
                                            HStack {
                                                Text("Enter task description")
                                                    .foregroundColor(Color(hex: "#9CA3AF"))
                                                    .padding(.leading, 4)
                                                    .padding(.top, 8)
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                        }
                        
                        // Status and Priority section
                        HStack(spacing: 16) {
                            // Status dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Status")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#374151"))
                                
                                Menu {
                                    ForEach(statusOptions, id: \.self) { option in
                                        Button(action: {
                                            status = option
                                        }) {
                                            Label(option, systemImage: statusIcon(for: option))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: statusIcon(for: status))
                                            .font(.system(size: 16))
                                            .foregroundColor(statusColor(for: status))
                                        
                                        Text(status)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#0F1A2B"))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        
                                        Spacer()
                                        
                                        Circle()
                                            .fill(statusColor(for: status))
                                            .frame(width: 8, height: 8)
                                            .padding(.trailing, 4)
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#6B7280"))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 12)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#D1D5DB"), lineWidth: 1)
                                    )
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            
                            // Priority dropdown
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Priority")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#374151"))
                                
                                Menu {
                                    ForEach(priorityOptions, id: \.self) { option in
                                        Button(action: {
                                            priority = option
                                        }) {
                                            Label(option, systemImage: priorityIcon(for: option))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: priorityIcon(for: priority))
                                            .font(.system(size: 16))
                                            .foregroundColor(priorityColor(for: priority))
                                        
                                        Text(priority)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#0F1A2B"))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        
                                        Spacer()
                                        
                                        Circle()
                                            .fill(priorityColor(for: priority))
                                            .frame(width: 8, height: 8)
                                            .padding(.trailing, 4)
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#6B7280"))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 12)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "#D1D5DB"), lineWidth: 1)
                                    )
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Due date section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Schedule")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#0F1A2B"))
                            
                            // Due date picker
                            Button(action: {
                                showDatePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 20))
                                        .foregroundColor(accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Due Date")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "#374151"))
                                        
                                        Text(dueDate != nil ? formatDate(dueDate!) : "Select due date")
                                            .font(.system(size: 16))
                                            .foregroundColor(dueDate != nil ? Color(hex: "#0F1A2B") : Color(hex: "#6B7280"))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#6B7280"))
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "#D1D5DB"), lineWidth: 1)
                                )
                            }
                            
                            // Time options (only show if a date is selected)
                            if dueDate != nil {
                                VStack(spacing: 12) {
                                    // All-day toggle
                                    Toggle(isOn: $isAllDayTask) {
                                        Text("All-day task")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#374151"))
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: accentColor))
                                    .padding(.horizontal, 12)
                                    
                                    // Time picker button (only show if not an all-day task)
                                    if !isAllDayTask {
                                        Button(action: {
                                            showTimePicker = true
                                        }) {
                                            HStack {
                                                Image(systemName: "clock")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(accentColor)
                                                
                                                Text(formatTime(selectedTime))
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(hex: "#0F1A2B"))
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(hex: "#6B7280"))
                                            }
                                            .padding(12)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(hex: "#D1D5DB"), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Assignee section
                        Button(action: {
                            // Toggle between "Unassigned" and "Me"
                            assignee = assignee == "Unassigned" ? "Me" : "Unassigned"
                        }) {
                            HStack {
                                Image(systemName: "person.2")
                                    .font(.system(size: 20))
                                    .foregroundColor(accentColor)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Assignee")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "#374151"))
                                    
                                    Text(assignee)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#0F1A2B"))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#6B7280"))
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#D1D5DB"), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                    // Add tap gesture to dismiss keyboard
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = nil
                    }
                }
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationBarHidden(true)
            .toolbar {
                // Add keyboard toolbar with done button
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                    .foregroundColor(accentColor)
                }
            }
            .overlay(
                // Success message overlay
                ZStack {
                    if showSuccessMessage {
                        VStack {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                
                                Text(isEditMode ? "Task updated successfully" : "Task created successfully")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(Color(hex: "#10B981"))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 80)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .onAppear {
                            // Dismiss after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSuccessMessage = false
                                }
                                // Dismiss the view after showing success message
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showSuccessMessage)
            )
            .sheet(isPresented: $showDatePicker) {
                // Date picker sheet
                NavigationView {
                    VStack(spacing: 0) {
                        List {
                            Button(action: {
                                dueDate = nil
                                showDatePicker = false
                                HapticManager.shared.selectionChanged()
                            }) {
                                Text("No Due Date")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: {
                                dueDate = Calendar.current.startOfDay(for: Date())
                                showDatePicker = false
                                HapticManager.shared.selectionChanged()
                            }) {
                                Text("Today")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: {
                                dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                                showDatePicker = false
                                HapticManager.shared.selectionChanged()
                            }) {
                                Text("Tomorrow")
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                            }
                            
                            Section(header: Text("Custom Date")) {
                                DatePicker(
                                    "Select a date",
                                    selection: $selectedDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()
                                .onChange(of: selectedDate) { oldValue, newValue in
                                    dueDate = newValue
                                }
                                
                                Button(action: {
                                    dueDate = selectedDate
                                    showDatePicker = false
                                    HapticManager.shared.selectionChanged()
                                }) {
                                    Text("Set Date")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(accentColor)
                                        .cornerRadius(8)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                    .navigationTitle("Due Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showDatePicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showTimePicker) {
                NavigationView {
                    VStack {
                        DatePicker(
                            "Select time",
                            selection: $selectedTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        
                        Button(action: {
                            // Combine the date from dueDate with the time from selectedTime
                            if let existingDate = dueDate {
                                let calendar = Calendar.current
                                let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
                                let dateComponents = calendar.dateComponents([.year, .month, .day], from: existingDate)
                                
                                var combinedComponents = DateComponents()
                                combinedComponents.year = dateComponents.year
                                combinedComponents.month = dateComponents.month
                                combinedComponents.day = dateComponents.day
                                combinedComponents.hour = timeComponents.hour
                                combinedComponents.minute = timeComponents.minute
                                
                                if let combinedDate = calendar.date(from: combinedComponents) {
                                    dueDate = combinedDate
                                }
                            }
                            showTimePicker = false
                            HapticManager.shared.selectionChanged()
                        }) {
                            Text("Set Time")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(accentColor)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    .navigationTitle("Select Time")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showTimePicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    // Function to save task
    private func saveTask() {
        // Validate required fields
        guard !title.isEmpty else { return }
        guard dueDate != nil else { return } // Require due date
        
        // If it's an all-day task, set the time to the start of the day
        var finalDueDate = dueDate
        if let date = dueDate {
            if isAllDayTask {
                finalDueDate = Calendar.current.startOfDay(for: date)
            } else {
                // Combine the date with the selected time if not all-day
                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                
                var combinedComponents = DateComponents()
                combinedComponents.year = dateComponents.year
                combinedComponents.month = dateComponents.month
                combinedComponents.day = dateComponents.day
                combinedComponents.hour = timeComponents.hour
                combinedComponents.minute = timeComponents.minute
                
                if let combinedDate = calendar.date(from: combinedComponents) {
                    finalDueDate = combinedDate
                }
            }
        }
        
        // Create and save task
        let newTask = Task(
            title: title,
            taskDescription: description,
            status: status,
            priority: priority,
            dueDate: finalDueDate,
            assignee: assignee,
            isAllDayTask: isAllDayTask
        )
        
        modelContext.insert(newTask)
        
        // Generate success haptic feedback
        HapticManager.shared.notification(type: .success)
        
        // Show success message
        withAnimation {
            showSuccessMessage = true
        }
        
        // Dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // Function to update an existing task
    private func updateTask() {
        // Validate required fields
        guard !title.isEmpty else { return }
        guard let task = existingTask else { return }
        
        // If it's an all-day task, set the time to the start of the day
        var finalDueDate = dueDate
        if let date = dueDate {
            if isAllDayTask {
                finalDueDate = Calendar.current.startOfDay(for: date)
            } else {
                // Combine the date with the selected time if not all-day
                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                
                var combinedComponents = DateComponents()
                combinedComponents.year = dateComponents.year
                combinedComponents.month = dateComponents.month
                combinedComponents.day = dateComponents.day
                combinedComponents.hour = timeComponents.hour
                combinedComponents.minute = timeComponents.minute
                
                if let combinedDate = calendar.date(from: combinedComponents) {
                    finalDueDate = combinedDate
                }
            }
        }
        
        // Update task properties
        task.title = title
        task.taskDescription = description
        task.status = status
        task.priority = priority
        task.dueDate = finalDueDate
        task.assignee = assignee
        task.isAllDayTask = isAllDayTask
        
        // Save changes
        do {
            try modelContext.save()
            
            // Generate success haptic feedback
            HapticManager.shared.notification(type: .success)
            
            // Show success message
            withAnimation {
                showSuccessMessage = true
            }
            
            // Dismiss after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("Failed to update task: \(error)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview("Create Task") {
    NewTaskView()
}

#Preview("Edit Task") {
    NewTaskView(task: Task(
        title: "Sample Task",
        taskDescription: "This is a sample task for preview",
        status: "In Progress",
        priority: "High",
        dueDate: Date(),
        assignee: "John Doe",
        isAllDayTask: false
    ))
} 