//
//  NewTaskView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import SwiftData

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
    
    // Success state
    @State private var showSuccessMessage = false
    
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
    
    var body: some View {
        NavigationView {
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
                    
                    // Client section
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "person")
                                .font(.system(size: 20))
                                .foregroundColor(accentColor)
                            
                            Text("Client")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#0F1A2B"))
                            
                            Spacer()
                            
                            Button(action: {
                                // Add client action
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                    .foregroundColor(accentColor)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Schedule section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Schedule")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#0F1A2B"))
                        
                        // Due date picker
                        Button(action: {
                            // Open date picker
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
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Assignee section
                    Button(action: {
                        // Select assignee action
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
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                // Add tap gesture to dismiss keyboard
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if hasContent {
                        Button(action: {
                            saveTask()
                        }) {
                            Text("Save")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(accentColor)
                                .cornerRadius(12)
                        }
                    }
                }
                
                // Add keyboard toolbar with done button
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .overlay(
                // Success message overlay
                ZStack {
                    if showSuccessMessage {
                        VStack {
                            Text("Task created successfully!")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
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
        }
    }
    
    // Function to save task
    private func saveTask() {
        // Validate required fields
        guard !title.isEmpty else { return }
        
        // Create and save task
        let newTask = Task(
            title: title,
            taskDescription: description,
            status: status,
            priority: priority,
            dueDate: dueDate,
            assignee: assignee
        )
        
        modelContext.insert(newTask)
        
        // Show success message
        withAnimation {
            showSuccessMessage = true
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    NewTaskView()
} 