import SwiftUI
import SwiftData

struct MoreView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    // Tab data with all 5 tabs
    let tabs = [
        (label: "Jobs", icon: "briefcase", color: "#246BFD"),
        (label: "Clients", icon: "person", color: "#474F4D"),
        (label: "Quotes", icon: "doc.text", color: "#933B4F"),
        (label: "Invoices", icon: "dollarsign.square", color: "#4CAF50"),
        (label: "Tasks", icon: "checklist", color: "#FF9500")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with settings button
            HStack {
                Text("More")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#153B3F"))
                
                Spacer()
                
                Button(action: {
                    // Settings action
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "#153B3F"))
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "#5F7376"))
                    .font(.system(size: 16))
                
                TextField("Search", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#3D4E50"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#D5DADA"), lineWidth: 1)
            )
            .padding(.bottom, 20)
            .padding(.horizontal, 8)
            
            // Tab Bar - Horizontal Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: tabs[index].icon)
                                    .foregroundColor(Color(hex: tabs[index].color))
                                    .font(.system(size: 18))
                                
                                Text(tabs[index].label)
                                    .font(.system(size: 15, weight: selectedTab == index ? .bold : .semibold))
                                    .foregroundColor(Color(hex: "#153B3F"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#F4F3EF"))
                            .cornerRadius(999)
                            .scaleEffect(selectedTab == index ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.bottom, 16)
            
            // Shadow line below tabs
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                .padding(.bottom, 8)
            
            // Content area based on selected tab
            TabContentView(selectedTab: selectedTab, tabName: tabs[selectedTab].label)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#F5F5F5"))
        }
        .padding(.horizontal, 8)
    }
}

// Tab content view - placeholder for the actual content
struct TabContentView: View {
    let selectedTab: Int
    let tabName: String
    @State private var showNewClientView = false
    @State private var showNewInvoiceView = false
    @State private var showNewTaskView = false
    
    @Query private var clients: [Client]
    @Query private var tasks: [Task]
    
    var body: some View {
        VStack {
            if selectedTab == 1 && !clients.isEmpty { // Clients tab with data
                // Clients list view
                VStack(alignment: .leading) {
                    // Recent clients header
                    Text("Recent clients")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: "#4A5568"))
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    // Client list
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(clients) { client in
                                ClientRow(client: client)
                            }
                        }
                    }
                }
                .overlay(
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            showNewClientView = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Add Client")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#052017"))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.bottom, 16)
                    }
                )
            } else if selectedTab == 4 && !tasks.isEmpty { // Tasks tab with data (now at index 4)
                // Tasks list view
                VStack(alignment: .leading) {
                    // Tasks header
                    Text("Tasks")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: "#4A5568"))
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    // Tasks list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(tasks) { task in
                                TaskRow(task: task)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .overlay(
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            showNewTaskView = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Add Task")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#052017"))
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.bottom, 16)
                    }
                )
            } else {
                // Empty state
                emptyStateView(for: selectedTab)
            }
        }
        .sheet(isPresented: $showNewClientView) {
            NewClientView()
        }
        .sheet(isPresented: $showNewInvoiceView) {
            NewInvoiceView()
        }
        .sheet(isPresented: $showNewTaskView) {
            NewTaskView()
        }
    }
    
    // Helper function to get icon for empty state
    private func getIconForTab(_ tab: Int) -> String {
        switch tab {
        case 0:
            return "briefcase"
        case 1:
            return "person"
        case 2:
            return "doc.text"
        case 3:
            return "dollarsign.square"
        case 4:
            return "checklist"
        default:
            return "briefcase"
        }
    }
    
    // Helper function to get singular form of tab name
    private func getSingular(for tabName: String) -> String {
        if tabName.hasSuffix("s") && tabName != "Business" {
            let lastIndex = tabName.index(before: tabName.endIndex)
            return String(tabName[..<lastIndex])
        }
        return tabName
    }
    
    // Helper function to display empty state view
    private func emptyStateView(for tab: Int) -> some View {
        VStack(spacing: 16) {
            Image(systemName: getIconForTab(tab))
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#8D9BA8"))
                .padding(.bottom, 8)
            
            Text("No \(tabName) Yet")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#153B3F"))
            
            Text("Your \(tabName.lowercased()) will appear here")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#5F7376"))
                .multilineTextAlignment(.center)
            
            Button(action: {
                // Action based on tab type
                switch tab {
                case 0: // Jobs
                    break
                case 1: // Clients
                    showNewClientView = true
                case 2: // Quotes
                    // No action needed for quotes
                    break
                case 3: // Invoices
                    showNewInvoiceView = true
                case 4: // Tasks
                    showNewTaskView = true
                default:
                    break
                }
            }) {
                Text("Create \(getSingular(for: tabName))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#052017"))
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }
}

// Client row view for the clients list
struct ClientRow: View {
    let client: Client
    @State private var showClientDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                // Client avatar/icon
                Circle()
                    .fill(Color(hex: "#EAEAEA"))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#666666"))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Client name
                    Text(client.fullName)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: "#2D3748"))
                    
                    // Date and address
                    HStack {
                        Text(formattedDate)
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#718096"))
                        
                        Text("|")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#718096"))
                            .padding(.horizontal, 8)
                        
                        Text(client.propertyAddress.isEmpty ? "No address" : client.propertyAddress)
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#718096"))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Add chevron icon
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#A0AEC0"))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            
            Divider()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showClientDetail = true
        }
        .sheet(isPresented: $showClientDetail) {
            ClientDetailView(client: client)
        }
    }
    
    // Format the date to "Jun 23" style
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: client.createdAt)
    }
}

// Task row view for the tasks list
struct TaskRow: View {
    let task: Task
    @State private var showTaskDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Task title and status
            HStack {
                Text(task.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#1A202C"))
                
                Spacer()
                
                // Status indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor(for: task.status))
                        .frame(width: 8, height: 8)
                    
                    Text(task.status)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(statusColor(for: task.status))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor(for: task.status).opacity(0.1))
                .cornerRadius(12)
            }
            
            // Description (if not empty)
            if !task.taskDescription.isEmpty {
                Text(task.taskDescription)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#4A5568"))
                    .lineLimit(2)
            }
            
            // Due date and priority
            HStack {
                // Due date
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#718096"))
                        
                        Text(formatDate(dueDate))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#718096"))
                    }
                }
                
                Spacer()
                
                // Priority indicator
                HStack(spacing: 4) {
                    Image(systemName: priorityIcon(for: task.priority))
                        .font(.system(size: 12))
                        .foregroundColor(priorityColor(for: task.priority))
                    
                    Text(task.priority)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(priorityColor(for: task.priority))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(priorityColor(for: task.priority).opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            showTaskDetail = true
        }
        .fullScreenCover(isPresented: $showTaskDetail) {
            TaskDetailView(task: task)
        }
    }
    
    // Format the date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
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
}

#Preview {
    MoreView()
} 

