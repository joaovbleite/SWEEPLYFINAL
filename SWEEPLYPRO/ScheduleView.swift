//
//  ScheduleView.swift
//  SWEEPLYPRO
//
//  Created on 7/6/25.
//

import SwiftUI
import SwiftData

// MARK: - Appointment Model
struct Appointment: Identifiable {
    let id = UUID()
    let title: String
    let clientName: String
    let location: String
    let startTime: String
    let endTime: String
    let date: Int
    let color: String
}

// MARK: - WorkTask Model (renamed from Task to avoid conflicts)
struct WorkTask: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let time: String
    let date: Int
    let priority: WorkPriority
    let isCompleted: Bool
    
    enum WorkPriority: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: String {
            switch self {
            case .low: return "#4CAF50" // Green
            case .medium: return "#FF9800" // Orange
            case .high: return "#F44336" // Red
            }
        }
    }
}

struct ScheduleView: View {
    // SwiftData query for tasks
    @Query(filter: #Predicate<Task> { task in
        task.status != "Completed"
    }) private var tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    
    // State variables
    @State private var selectedMonth = "July"
    @State private var selectedDate = Date()
    @State private var selectedViewMode: ViewMode = .day
    @State private var selectedDayIndex = 0
    @State private var showMonthPicker = false
    @State private var showAppointmentDetails = false
    @State private var showTaskDetails = false
    @State private var selectedAppointment: Appointment?
    @State private var selectedTask: Task?
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var initialScrollDone = false
    @State private var showViewOptions = false
    @State private var showSettings = false
    
    // Week navigation variables
    @State private var currentWeekStartDate = Date()
    @State private var currentWeekDates: [Date] = []
    @State private var currentWeekDays: [Int] = []
    @State private var currentWeekMonth = "July"
    @State private var currentWeekYear = 2025
    
    // View options state
    @State private var showUnscheduledAppointments = false
    @State private var showWeekends = true
    @State private var selectedTeamMembers: [String] = ["Joao"]
    
    // Current time for the time indicator
    @State private var currentTime = Date()
    @State private var timer: Timer? = nil
    
    // Mock data
    let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    let dates = [6, 7, 8, 9, 10, 11, 12]
    let timeSlots = [
        "12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", 
        "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM",
        "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM",
        "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"
    ]
    let months = ["January", "February", "March", "April", "May", "June", 
                 "July", "August", "September", "October", "November", "December"]
    
    // Team members
    let teamMembers = ["Joao", "Emma", "Michael", "Sophia", "David"]
    
    // Sample appointments
    let appointments = [
        Appointment(
            title: "Window Cleaning",
            clientName: "John Smith",
            location: "123 Main St",
            startTime: "7 PM",
            endTime: "8 PM",
            date: 6,
            color: "#246BFD"
        ),
        Appointment(
            title: "Carpet Cleaning",
            clientName: "Jane Doe",
            location: "456 Oak Ave",
            startTime: "8 PM",
            endTime: "9 PM",
            date: 8,
            color: "#9747FF"
        ),
        Appointment(
            title: "Morning Service",
            clientName: "Robert Johnson",
            location: "789 Pine St",
            startTime: "9 AM",
            endTime: "10 AM",
            date: 6,
            color: "#052017"
        )
    ]
    
    // Sample work tasks
    let workTasks = [
        WorkTask(
            title: "Call Supplier",
            description: "Discuss new cleaning product pricing",
            time: "10 AM",
            date: 6,
            priority: .high,
            isCompleted: false
        ),
        WorkTask(
            title: "Invoice Review",
            description: "Review and send monthly invoices",
            time: "2 PM",
            date: 6,
            priority: .medium,
            isCompleted: false
        )
    ]
    
    // Define view modes
    enum ViewMode: String, CaseIterable {
        case day = "Day"
        case list = "List"
        case map = "Map"
    }
    
    // Get appointments for the selected day
    private var appointmentsForSelectedDay: [Appointment] {
        if currentWeekDays.isEmpty || selectedDayIndex >= currentWeekDays.count {
            return []
        }
        
        let selectedDay = currentWeekDays[selectedDayIndex]
        return appointments.filter { $0.date == selectedDay }
    }
    
    // Get tasks for the selected day
    private var tasksForSelectedDay: [Task] {
        if currentWeekDates.isEmpty || selectedDayIndex >= currentWeekDates.count {
            return []
        }
        
        let selectedDate = currentWeekDates[selectedDayIndex]
        let calendar = Calendar.current
        
        return tasks.filter { task in
            guard let taskDate = task.dueDate else { return false }
            // Only include tasks that match the selected date
            // (Completed tasks are already filtered out in the @Query)
            return calendar.isDate(taskDate, inSameDayAs: selectedDate)
        }
    }
    
    // Function to get time string from a date
    private func timeString(from date: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let amPm = hour < 12 ? "AM" : "PM"
        
        // Convert to 12-hour format
        let hour12 = hour % 12
        let hourString = hour12 == 0 ? "12" : "\(hour12)"
        
        // Format as "1 AM", "2 PM", etc. to match timeSlots
        return "\(hourString) \(amPm)"
    }
    
    // Current hour for scrolling
    private var currentHour: Int {
        Calendar.current.component(.hour, from: currentTime)
    }
    
    // MARK: - Week Navigation Functions
    
    // Function to initialize the week dates
    private func initializeWeekDates() {
        let calendar = Calendar.current
        
        // Get the current week's Sunday (or first day of week based on locale)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        currentWeekStartDate = calendar.date(from: components) ?? Date()
        
        // Generate dates for the full week
        currentWeekDates = (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: currentWeekStartDate) ?? Date()
        }
        
        // Extract day numbers
        currentWeekDays = currentWeekDates.map { calendar.component(.day, from: $0) }
        
        // Get month name and year for display
        let firstDate = currentWeekDates.first ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        currentWeekMonth = dateFormatter.string(from: firstDate)
        currentWeekYear = calendar.component(.year, from: firstDate)
        
        // Update selected month
        selectedMonth = currentWeekMonth
    }
    
    // Function to navigate to the previous week
    private func goToPreviousWeek() {
        let calendar = Calendar.current
        if let newStartDate = calendar.date(byAdding: .day, value: -7, to: currentWeekStartDate) {
            currentWeekStartDate = newStartDate
            
            // Generate dates for the new week
            currentWeekDates = (0..<7).map { day in
                calendar.date(byAdding: .day, value: day, to: currentWeekStartDate) ?? Date()
            }
            
            // Extract day numbers
            currentWeekDays = currentWeekDates.map { calendar.component(.day, from: $0) }
            
            // Get month name and year for display
            let firstDate = currentWeekDates.first ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            currentWeekMonth = dateFormatter.string(from: firstDate)
            currentWeekYear = calendar.component(.year, from: firstDate)
            
            // Update selected month if it changed
            selectedMonth = currentWeekMonth
            
            // Reset selected day index to first day
            selectedDayIndex = 0
        }
    }
    
    // Function to navigate to the next week
    private func goToNextWeek() {
        let calendar = Calendar.current
        if let newStartDate = calendar.date(byAdding: .day, value: 7, to: currentWeekStartDate) {
            currentWeekStartDate = newStartDate
            
            // Generate dates for the new week
            currentWeekDates = (0..<7).map { day in
                calendar.date(byAdding: .day, value: day, to: currentWeekStartDate) ?? Date()
            }
            
            // Extract day numbers
            currentWeekDays = currentWeekDates.map { calendar.component(.day, from: $0) }
            
            // Get month name and year for display
            let firstDate = currentWeekDates.first ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            currentWeekMonth = dateFormatter.string(from: firstDate)
            currentWeekYear = calendar.component(.year, from: firstDate)
            
            // Update selected month if it changed
            selectedMonth = currentWeekMonth
            
            // Reset selected day index to first day
            selectedDayIndex = 0
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar with month selector and icons
            topBar
            
            // Week day selector (redesigned)
            weekDaySelector
            
            // View mode selector (redesigned)
            viewModeSelector
            
            // Main content based on selected view mode
            switch selectedViewMode {
            case .day:
                dayViewContent
            case .list:
                listViewContent
            case .map:
                mapViewContent
            }
        }
        .background(Color(hex: "#F5F5F5"))
        .onAppear {
            // Start timer to update current time indicator
            self.currentTime = Date()
            self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.currentTime = Date()
            }
        }
        .onDisappear {
            // Invalidate timer when view disappears
            self.timer?.invalidate()
            self.timer = nil
        }
        .sheet(isPresented: $showMonthPicker) {
            monthPickerView
        }
        .sheet(isPresented: $showAppointmentDetails) {
            if let appointment = selectedAppointment {
                appointmentDetailView(appointment: appointment)
            }
        }
        .fullScreenCover(isPresented: $showTaskDetails) {
            if let task = selectedTask {
                TaskDetailView(task: task)
            }
        }
        .sheet(isPresented: $showViewOptions) {
            viewOptionsSheet
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Month selector with dropdown
            Button(action: {
                showMonthPicker = true
            }) {
                HStack(spacing: 4) {
                    Text(selectedMonth)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#052017"))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#052017"))
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            // Calendar icon
            Button(action: {
                // Action for calendar button
            }) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "#052017"))
            }
            .padding(.horizontal, 12)
            
            // Settings icon
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "#052017"))
            }
            .padding(.trailing, 16)
        }
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Month Picker View
    private var monthPickerView: some View {
        NavigationView {
            List {
                ForEach(months, id: \.self) { month in
                    Button(action: {
                        selectedMonth = month
                        showMonthPicker = false
                    }) {
                        HStack {
                            Text(month)
                                .foregroundColor(Color(hex: "#052017"))
                            
                            Spacer()
                            
                            if selectedMonth == month {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "#246BFD"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showMonthPicker = false
                    }
                    .foregroundColor(Color(hex: "#246BFD"))
                }
            }
        }
    }
    
    // MARK: - View Mode Selector (Redesigned)
    private var viewModeSelector: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation {
                        selectedViewMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedViewMode == mode ? .white : Color(hex: "#5A7184"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedViewMode == mode ? 
                                Color(hex: "#246BFD") : 
                                Color.clear
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#F4F4F2"))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Week Day Selector (Redesigned)
    private var weekDaySelector: some View {
        VStack(spacing: 0) {
            // Week navigation controls
            HStack {
                // Previous week button
                Button(action: {
                    goToPreviousWeek()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#246BFD"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#F4F4F2"))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Week date range display
                if !currentWeekDates.isEmpty {
                    let firstDay = currentWeekDays.first ?? 1
                    let lastDay = currentWeekDays.last ?? 7
                    
                    Text("\(currentWeekMonth) \(firstDay)-\(lastDay), \(currentWeekYear)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#5A7184"))
                }
                
                Spacer()
                
                // Next week button
                Button(action: {
                    goToNextWeek()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#246BFD"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#F4F4F2"))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Day selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<currentWeekDays.count, id: \.self) { index in
                        Button(action: {
                            withAnimation {
                                selectedDayIndex = index
                            }
                        }) {
                            VStack(spacing: 8) {
                                // Day letter (S, M, T, etc.)
                                if !currentWeekDates.isEmpty && index < currentWeekDates.count {
                                    let date = currentWeekDates[index]
                                    let dayLetter = String(Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1].prefix(1))
                                    
                                    Text(dayLetter)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "#5A7184"))
                                } else {
                                    Text(weekdays[index % 7])
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "#5A7184"))
                                }
                                
                                ZStack {
                                    Circle()
                                        .fill(index == selectedDayIndex ? Color(hex: "#246BFD") : Color.clear)
                                        .frame(width: 40, height: 40)
                                    
                                    // Day number
                                    if !currentWeekDays.isEmpty && index < currentWeekDays.count {
                                        Text("\(currentWeekDays[index])")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(index == selectedDayIndex ? .white : Color(hex: "#1A2E3B"))
                                    } else {
                                        Text("\(index + 1)")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(index == selectedDayIndex ? .white : Color(hex: "#1A2E3B"))
                                    }
                                }
                                
                                // Indicator for days with appointments
                                if !currentWeekDays.isEmpty && index < currentWeekDays.count && 
                                   appointments.contains(where: { $0.date == currentWeekDays[index] }) {
                                    Circle()
                                        .fill(Color(hex: "#246BFD"))
                                        .frame(width: 4, height: 4)
                                } else {
                                    Spacer()
                                        .frame(height: 4)
                                }
                            }
                            .frame(width: 50)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.white)
        .padding(.vertical, 8)
        .onAppear {
            initializeWeekDates()
        }
    }
    
    // MARK: - Day View Content
    private var dayViewContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    // All-day tasks section
                    if !allDayTasksForSelectedDay.isEmpty {
                        allDayTasksSection
                    }
                    
                    // Time slots
                    ForEach(Array(timeSlots.enumerated()), id: \.offset) { index, time in
                        timeSlotRow(time: time)
                            .id(index) // Use index as ID for scrolling
                            .overlay(
                                // Current time indicator - only show for current hour
                                Group {
                                    if index == currentHour {
                                        GeometryReader { geometry in
                                            let hourHeight: CGFloat = 64
                                            let minutes = Calendar.current.component(.minute, from: currentTime)
                                            
                                            // Calculate position within this hour slot
                                            let yPosition = CGFloat(minutes) / 60.0 * hourHeight
                                            
                                            HStack(spacing: 0) {
                                                Circle()
                                                    .fill(Color(hex: "#246BFD"))
                                                    .frame(width: 8, height: 8)
                                                
                                                Rectangle()
                                                    .fill(Color(hex: "#246BFD"))
                                                    .frame(height: 2)
                                            }
                                            .padding(.leading, 16)
                                            .offset(y: yPosition)
                                        }
                                    }
                                }
                            )
                    }
                    
                    // Extra space at the bottom for better scrolling
                    Color.clear.frame(height: 100)
                }
                .onAppear {
                    scrollProxy = proxy
                    
                    // Scroll to current hour with a slight delay to ensure view is ready
                    if !initialScrollDone {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                proxy.scrollTo(currentHour, anchor: .top)
                                initialScrollDone = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - All-Day Tasks Section
    private var allDayTasksForSelectedDay: [Task] {
        if currentWeekDates.isEmpty || selectedDayIndex >= currentWeekDates.count {
            return []
        }
        
        let selectedDate = currentWeekDates[selectedDayIndex]
        let calendar = Calendar.current
        
        return tasks.filter { task in
            guard let taskDate = task.dueDate else { return false }
            return calendar.isDate(taskDate, inSameDayAs: selectedDate) && task.isAllDayTask
        }
    }
    
    private var allDayTasksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All-day")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#5A7184"))
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(allDayTasksForSelectedDay) { task in
                        allDayTaskBlock(task: task)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            Divider()
                .padding(.horizontal, 16)
        }
        .background(Color(hex: "#F8F8F8"))
    }
    
    // MARK: - All-Day Task Block
    private func allDayTaskBlock(task: Task) -> some View {
        Button(action: {
            selectedTask = task
            showTaskDetails = true
        }) {
            HStack(spacing: 8) {
                // Priority indicator
                Circle()
                    .fill(Color(hex: priorityColor(for: task.priority)))
                    .frame(width: 8, height: 8)
                
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#052017"))
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        }
    }
    
    // MARK: - Time Slot Row
    private func timeSlotRow(time: String) -> some View {
        let appointmentsInSlot = appointmentsForSelectedDay.filter { $0.startTime == time }
        
        // Debug print to see what's happening
        print("Looking for tasks at time: \(time)")
        
        let tasksInSlot = tasksForSelectedDay.filter { task in
            guard let dueDate = task.dueDate, !task.isAllDayTask else { return false }
            let taskTime = timeString(from: dueDate)
            print("Task due date: \(dueDate), formatted as: \(taskTime)")
            return taskTime == time
        }
        
        let totalCards = appointmentsInSlot.count + tasksInSlot.count
        
        // Calculate dynamic height based on number of cards
        // Base height is 64, add 60 points for each additional card
        let rowHeight: CGFloat = totalCards > 1 ? 64 + CGFloat(totalCards - 1) * 60 : 64
        
        return HStack(alignment: .top, spacing: 12) {
            // Time label
            Text(time)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#5A7184"))
                .frame(width: 50, alignment: .leading)
                .padding(.top, 12)
            
            // Content area
            ZStack(alignment: .topLeading) {
                // Divider line
                Rectangle()
                    .fill(Color(hex: "#D9D9D9"))
                    .frame(height: 1)
                    .padding(.top, 12)
                
                // Tap area for creating events - MOVED BEHIND other content
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Handle tap to create event
                        print("Create event at \(time)")
                    }
                
                VStack(spacing: 8) {
                    // Appointment blocks
                    ForEach(appointmentsInSlot) { appointment in
                        appointmentBlock(appointment: appointment)
                            .padding(.top, 2)
                    }
                    
                    // Work task blocks - using real tasks
                    ForEach(tasksInSlot) { task in
                        realTaskBlock(task: task)
                            .padding(.top, 2)
                            .zIndex(1) // Ensure task blocks are above the tap area
                    }
                    
                    // Add spacer if there are cards to push them to the top
                    if totalCards > 0 {
                        Spacer()
                    }
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .frame(height: rowHeight)
        .background(
            // Add subtle background highlight if there are cards in this slot
            totalCards > 0 
                ? Color(hex: "#F8F8F8") 
                : Color.clear
        )
    }
    
    // MARK: - Appointment Block
    private func appointmentBlock(appointment: Appointment) -> some View {
        Button(action: {
            selectedAppointment = appointment
            showAppointmentDetails = true
        }) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(Color(hex: appointment.color))
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(appointment.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#052017"))
                    
                    Text(appointment.clientName)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#5A7184"))
                }
                
                Spacer()
                
                Text(appointment.startTime)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#5A7184"))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        }
    }
    
    // MARK: - Real Task Block
    private func realTaskBlock(task: Task) -> some View {
        Button(action: {
            selectedTask = task
            showTaskDetails = true
        }) {
            HStack(spacing: 8) {
                // Priority indicator
                Circle()
                    .fill(Color(hex: priorityColor(for: task.priority)))
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(task.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#052017"))
                        
                        Spacer()
                        
                        // Completion indicator
                        if task.status == "Completed" {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#4CAF50"))
                                .font(.system(size: 14))
                        }
                    }
                    
                    Text(task.taskDescription)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#5A7184"))
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: priorityColor(for: task.priority)), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)
        }
    }
    
    // Function to get priority color
    private func priorityColor(for priority: String) -> String {
        switch priority {
        case "Low":
            return "#10B981" // Green
        case "Medium":
            return "#F59E0B" // Amber
        case "High":
            return "#EF4444" // Red
        case "Urgent":
            return "#DC2626" // Dark Red
        default:
            return "#6B7280" // Gray
        }
    }
    
    // MARK: - List View Content
    private var listViewContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Date header
                Text("July \(dates[selectedDayIndex]), 2025")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#052017"))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                if appointmentsForSelectedDay.isEmpty {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#5A7184").opacity(0.6))
                            .padding(.bottom, 8)
                        
                        Text("No scheduled appointments")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#5A7184"))
                        
                        Text("Tap the + button to create a new appointment")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#5A7184").opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // List of appointments
                    ForEach(appointmentsForSelectedDay) { appointment in
                        listAppointmentRow(appointment: appointment)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 100) // Add padding for tab bar
        }
    }
    
    // MARK: - List Appointment Row
    private func listAppointmentRow(appointment: Appointment) -> some View {
        Button(action: {
            selectedAppointment = appointment
            showAppointmentDetails = true
        }) {
            HStack(spacing: 12) {
                // Time column
                VStack(spacing: 4) {
                    Text(appointment.startTime)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#052017"))
                    
                    Text(appointment.endTime)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#5A7184"))
                }
                .frame(width: 60)
                
                // Vertical line
                Rectangle()
                    .fill(Color(hex: appointment.color))
                    .frame(width: 4, height: 50)
                
                // Appointment details
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#052017"))
                    
                    Text(appointment.clientName)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#5A7184"))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#5A7184"))
                        
                        Text(appointment.location)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#5A7184"))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "#5A7184"))
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        }
    }
    
    // MARK: - Map View Content
    private var mapViewContent: some View {
        VStack {
            // Placeholder for map view
            ZStack {
                Color(hex: "#F8F8F6")
                
                VStack(spacing: 16) {
                    Image(systemName: "map")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#5A7184").opacity(0.6))
                    
                    Text("Map View")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#5A7184"))
                    
                    Text("Your scheduled appointments will appear here")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#5A7184").opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.bottom, 100) // Add padding for tab bar
    }
    
    // MARK: - Appointment Detail View
    private func appointmentDetailView(appointment: Appointment) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Appointment header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(appointment.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#052017"))
                        
                        Text("Client: \(appointment.clientName)")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#5A7184"))
                    }
                    
                    // Time and date
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Date")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#5A7184"))
                            
                            Text("July \(appointment.date), 2025")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#052017"))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#5A7184"))
                            
                            Text("\(appointment.startTime) - \(appointment.endTime)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#052017"))
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#5A7184"))
                        
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Color(hex: "#246BFD"))
                            
                            Text(appointment.location)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#052017"))
                        }
                        
                        // Placeholder for map
                        Rectangle()
                            .fill(Color(hex: "#F8F8F6"))
                            .frame(height: 120)
                            .cornerRadius(8)
                            .overlay(
                                Text("Map placeholder")
                                    .foregroundColor(Color(hex: "#5A7184"))
                            )
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            // Handle edit action
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .foregroundColor(Color(hex: "#246BFD"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "#246BFD"), lineWidth: 1)
                            )
                        }
                        
                        Button(action: {
                            // Handle cancel action
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Cancel")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#F8F8F6"))
                            .foregroundColor(Color(hex: "#5A7184"))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Appointment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAppointmentDetails = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "#5A7184"))
                    }
                }
            }
        }
    }
    
    // MARK: - View Options Sheet
    private var viewOptionsSheet: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // View options section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("View")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#052017"))
                            .padding(.horizontal, 16)
                        
                        // View mode selector
                        HStack(spacing: 0) {
                            ForEach(ViewMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    withAnimation {
                                        selectedViewMode = mode
                                    }
                                }) {
                                    Text(mode.rawValue)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(selectedViewMode == mode ? .white : Color(hex: "#5A7184"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedViewMode == mode ? 
                                                Color(hex: "#246BFD") : 
                                                Color.clear
                                        )
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#F4F4F2"))
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // Toggle options
                    VStack(spacing: 20) {
                        // Section header
                        Text("Display Options")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#052017"))
                            .padding(.horizontal, 16)
                        
                        // Unscheduled appointments toggle
                        toggleOption(
                            title: "Show unscheduled appointments on map view",
                            isOn: $showUnscheduledAppointments
                        )
                        
                        // Show weekends toggle
                        toggleOption(
                            title: "Show weekends on week view",
                            isOn: $showWeekends
                        )
                    }
                    .padding(.top, 8)
                    
                    // Team members section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Team Members")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#052017"))
                            .padding(.horizontal, 16)
                        
                        // Search field
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(hex: "#5A7184"))
                            
                            Text("Search")
                                .foregroundColor(Color(hex: "#5A7184"))
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                        .padding(.horizontal, 16)
                        
                        // Selected count and deselect button
                        HStack {
                            Text("\(selectedTeamMembers.count) selected")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#052017"))
                            
                            Spacer()
                            
                            Button(action: {
                                selectedTeamMembers = []
                            }) {
                                Text("Deselect all")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#246BFD"))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Team members list
                        VStack(spacing: 0) {
                            ForEach(teamMembers, id: \.self) { member in
                                teamMemberRow(member: member)
                                
                                if member != teamMembers.last {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical, 16)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("View Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showViewOptions = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(hex: "#052017"))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showViewOptions = false
                    }) {
                        Text("Apply")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#246BFD"))
                    }
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    
                    // Apply button (mobile style)
                    Button(action: {
                        showViewOptions = false
                    }) {
                        Text("Apply")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#246BFD"))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .background(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0), Color.white]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 100)
                        .edgesIgnoringSafeArea(.bottom),
                    alignment: .bottom
                )
            )
        }
    }
    
    // MARK: - Helper Views for Options Sheet
    private func toggleOption(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#052017"))
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#246BFD")))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        .padding(.horizontal, 16)
    }
    
    private func teamMemberRow(member: String) -> some View {
        HStack {
            Text(member)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#052017"))
            
            Spacer()
            
            // Checkmark
            ZStack {
                Circle()
                    .fill(selectedTeamMembers.contains(member) ? Color(hex: "#246BFD") : Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "#246BFD"), lineWidth: selectedTeamMembers.contains(member) ? 0 : 2)
                    )
                
                if selectedTeamMembers.contains(member) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .onTapGesture {
                if selectedTeamMembers.contains(member) {
                    selectedTeamMembers.removeAll { $0 == member }
                } else {
                    selectedTeamMembers.append(member)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ScheduleView()
} 