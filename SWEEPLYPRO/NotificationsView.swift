import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedFilter: NotificationFilter = .all
    @State private var searchText = ""
    @State private var showFilterOptions = false
    @State private var showSearch = false
    
    // Filter options
    enum NotificationFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case unread = "Unread"
        case client = "Clients"
        case payment = "Payments"
        case job = "Jobs"
        case task = "Tasks"
        case system = "System"
        
        var id: String { self.rawValue }
    }
    
    // Sample notification data
    let notifications = [
        Notification(id: 1, title: "New client request", message: "John Smith has requested a quote for house cleaning", time: "10m ago", isRead: false, type: .client),
        Notification(id: 2, title: "Payment received", message: "You received a payment of $120 from Maria Garcia", time: "2h ago", isRead: false, type: .payment),
        Notification(id: 3, title: "Upcoming job reminder", message: "You have a cleaning job scheduled tomorrow at 10:00 AM", time: "5h ago", isRead: true, type: .job),
        Notification(id: 4, title: "Task completed", message: "You marked 'Send invoice to client' as complete", time: "1d ago", isRead: true, type: .task),
        Notification(id: 5, title: "New feature available", message: "Try our new scheduling assistant to optimize your routes", time: "2d ago", isRead: true, type: .system)
    ]
    
    // Filtered notifications based on selected filter and search text
    var filteredNotifications: [Notification] {
        var filtered = notifications
        
        // Apply type filter
        if selectedFilter != .all && selectedFilter != .unread {
            let filterType = NotificationType(from: selectedFilter)
            filtered = filtered.filter { $0.type == filterType }
        }
        
        // Apply unread filter
        if selectedFilter == .unread {
            filtered = filtered.filter { !$0.isRead }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.title.lowercased().contains(searchText.lowercased()) || 
                $0.message.lowercased().contains(searchText.lowercased())
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    if showSearch {
                        // Search field
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#5F7376"))
                            
                            TextField("Search notifications", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#153B3F"))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#8D9BA8"))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#F4F3EF"))
                        .cornerRadius(8)
                    } else {
                        Text("Notifications")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#153B3F"))
                        
                        Spacer()
                    }
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        if showSearch {
                            Button(action: {
                                showSearch = false
                                searchText = ""
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#246BFD"))
                            }
                        } else {
                            Button(action: {
                                showSearch = true
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#5F7376"))
                                    .padding(8)
                                    .background(Color(hex: "#F4F3EF"))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                showFilterOptions.toggle()
                            }) {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#5F7376"))
                                    .padding(8)
                                    .background(Color(hex: "#F4F3EF"))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#5F7376"))
                                    .padding(8)
                                    .background(Color(hex: "#F4F3EF"))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Filter tabs
                if !showSearch {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach([NotificationFilter.all, .unread]) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    action: {
                                        selectedFilter = filter
                                    }
                                )
                            }
                            
                            Divider()
                                .frame(height: 24)
                                .padding(.horizontal, 4)
                            
                            ForEach([NotificationFilter.client, .payment, .job, .task, .system]) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    action: {
                                        selectedFilter = filter
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 12)
                    }
                }
                
                // Divider
                Rectangle()
                    .fill(Color(hex: "#EAEAEA"))
                    .frame(height: 1)
                
                // Filter options sheet
                if showFilterOptions {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Filter by")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#153B3F"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        
                        Divider()
                        
                        ForEach(NotificationFilter.allCases) { filter in
                            Button(action: {
                                selectedFilter = filter
                                showFilterOptions = false
                            }) {
                                HStack {
                                    Text(filter.rawValue)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#153B3F"))
                                    
                                    Spacer()
                                    
                                    if selectedFilter == filter {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#246BFD"))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(selectedFilter == filter ? Color(hex: "#F4F3EF") : Color.white)
                            }
                            
                            if filter != NotificationFilter.allCases.last {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .transition(.opacity)
                    .zIndex(1)
                }
                
                // Notifications List
                if filteredNotifications.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#8D9BA8"))
                            .padding(.bottom, 8)
                            .padding(.top, 60)
                        
                        Text(emptyStateTitle)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#153B3F"))
                        
                        Text(emptyStateMessage)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#5F7376"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Notifications list
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredNotifications) { notification in
                                NotificationRow(notification: notification)
                                
                                if notification.id != filteredNotifications.last?.id {
                                    Divider()
                                        .padding(.leading, 56)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.2), value: selectedFilter)
            .animation(.easeInOut(duration: 0.2), value: showFilterOptions)
            .animation(.easeInOut(duration: 0.2), value: showSearch)
        }
    }
    
    // Dynamic empty state text based on filter
    var emptyStateTitle: String {
        if !searchText.isEmpty {
            return "No Results Found"
        }
        
        switch selectedFilter {
        case .all:
            return "No Notifications"
        case .unread:
            return "No Unread Notifications"
        default:
            return "No \(selectedFilter.rawValue) Notifications"
        }
    }
    
    var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "Try a different search term"
        }
        
        switch selectedFilter {
        case .all:
            return "You don't have any notifications yet"
        case .unread:
            return "You've read all your notifications"
        default:
            return "You don't have any \(selectedFilter.rawValue.lowercased()) notifications"
        }
    }
}

// Filter chip component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Color.white : Color(hex: "#5F7376"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color(hex: "#246BFD") : Color(hex: "#F4F3EF"))
                .cornerRadius(16)
        }
    }
}

// Notification model
struct Notification: Identifiable {
    let id: Int
    let title: String
    let message: String
    let time: String
    var isRead: Bool
    let type: NotificationType
}

// Notification type enum
enum NotificationType {
    case client, payment, job, task, system
    
    // Helper to convert from filter
    init(from filter: NotificationsView.NotificationFilter) {
        switch filter {
        case .client: self = .client
        case .payment: self = .payment
        case .job: self = .job
        case .task: self = .task
        case .system: self = .system
        default: self = .system // Default fallback
        }
    }
}

// Individual notification row
struct NotificationRow: View {
    let notification: Notification
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 16, weight: notification.isRead ? .medium : .bold))
                    .foregroundColor(Color(hex: "#153B3F"))
                
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#5F7376"))
                    .lineLimit(2)
                
                Text(notification.time)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8D9BA8"))
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // Unread indicator
            if !notification.isRead {
                Circle()
                    .fill(Color(hex: "#246BFD"))
                    .frame(width: 8, height: 8)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(notification.isRead ? Color.white : Color(hex: "#F9F9F9"))
    }
    
    // Helper properties for icon
    private var iconName: String {
        switch notification.type {
        case .client: return "person.fill"
        case .payment: return "dollarsign.circle.fill"
        case .job: return "briefcase.fill"
        case .task: return "checkmark.circle.fill"
        case .system: return "bell.fill"
        }
    }
    
    private var iconBackgroundColor: Color {
        switch notification.type {
        case .client: return Color(hex: "#474F4D")
        case .payment: return Color(hex: "#4CAF50")
        case .job: return Color(hex: "#246BFD")
        case .task: return Color(hex: "#FF9500")
        case .system: return Color(hex: "#8D9BA8")
        }
    }
}

#Preview {
    NotificationsView()
} 