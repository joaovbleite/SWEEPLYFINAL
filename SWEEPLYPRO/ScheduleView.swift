//
//  ScheduleView.swift
//  SWEEPLYPRO
//
//  Created on 7/6/25.
//

import SwiftUI
import SwiftData

// MARK: - Appointment Model
struct Appointment: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let clientName: String
    let location: String
    let startTime: String
    let endTime: String
    let date: Int
    let color: String
    
    static func == (lhs: Appointment, rhs: Appointment) -> Bool {
        lhs.id == rhs.id
    }
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

// MARK: - Week Data Model
struct WeekData: Identifiable {
    let id = UUID()
    let startDate: Date
    let dates: [Date]
    let days: [Int]
    let month: String
    let year: Int
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
    @State private var selectedViewMode: ViewMode = .day // Ensure default is set to day
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
    @State private var weeksData: [WeekData] = [] // New state for carousel
    @State private var currentWeekIndex: Int = 0 // New state for carousel
    
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
        let today = Date()
        
        // Clear existing weeks data to avoid duplication
        weeksData.removeAll()
        
        // Get the current week's Sunday (or first day of week based on locale)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        currentWeekStartDate = calendar.date(from: components) ?? today
        
        // Add two previous weeks for better scrolling
        if let prevWeekStartDate2 = calendar.date(byAdding: .day, value: -14, to: currentWeekStartDate) {
            addWeekToCarousel(startDate: prevWeekStartDate2)
        }
        
        // Add previous week
        if let prevWeekStartDate = calendar.date(byAdding: .day, value: -7, to: currentWeekStartDate) {
            addWeekToCarousel(startDate: prevWeekStartDate)
        }
        
        // Add current week
        addWeekToCarousel(startDate: currentWeekStartDate)
        
        // Add next week
        if let nextWeekStartDate = calendar.date(byAdding: .day, value: 7, to: currentWeekStartDate) {
            addWeekToCarousel(startDate: nextWeekStartDate)
        }
        
        // Add second next week for better scrolling
        if let nextWeekStartDate2 = calendar.date(byAdding: .day, value: 14, to: currentWeekStartDate) {
            addWeekToCarousel(startDate: nextWeekStartDate2)
        }
        
        // Set current week as the middle index (2)
        currentWeekIndex = 2
        
        // Set the current week data as active
        setActiveWeek(index: currentWeekIndex)
        
        // Find today's index in the week and select it
        let todayWeekday = calendar.component(.weekday, from: today) - 1 // 0-based index (0 = Sunday)
        selectedDayIndex = todayWeekday
        
        // Make sure selectedDate is set to today
        selectedDate = today
        
        print("Initialized weeks data with \(weeksData.count) weeks")
        print("Current week index: \(currentWeekIndex)")
        print("Today's weekday: \(todayWeekday), selected day index: \(selectedDayIndex)")
    }
    
    // Function to add a week to the carousel
    private func addWeekToCarousel(startDate: Date, addToBeginning: Bool = false) {
        let calendar = Calendar.current
            
        // Generate dates for the week
        let weekDates = (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: startDate) ?? Date()
            }
            
            // Extract day numbers
        let weekDays = weekDates.map { calendar.component(.day, from: $0) }
            
            // Get month name and year for display
        let firstDate = weekDates.first ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
        let weekMonth = dateFormatter.string(from: firstDate)
        let weekYear = calendar.component(.year, from: firstDate)
            
        // Create week data
        let weekData = WeekData(
            startDate: startDate,
            dates: weekDates,
            days: weekDays,
            month: weekMonth,
            year: weekYear
        )
        
        // Add to weeks array
        if addToBeginning {
            weeksData.insert(weekData, at: 0)
            // Update currentWeekIndex if we're adding to the beginning
            if currentWeekIndex >= 0 {
                currentWeekIndex += 1
            }
        } else {
            weeksData.append(weekData)
        }
        
        print("Added week: \(weekMonth) \(weekDays.first ?? 0)-\(weekDays.last ?? 0), total weeks: \(weeksData.count)")
            }
            
    // Function to set the active week
    private func setActiveWeek(index: Int) {
        guard index >= 0 && index < weeksData.count else { return }
        
        let weekData = weeksData[index]
        currentWeekDates = weekData.dates
        currentWeekDays = weekData.days
        currentWeekMonth = weekData.month
        currentWeekYear = weekData.year
        currentWeekStartDate = weekData.startDate
            
        // Update selected month
            selectedMonth = currentWeekMonth
    }
    
    // Function to navigate to the previous week
    private func goToPreviousWeek() {
        print("Going to previous week, current index: \(currentWeekIndex), total weeks: \(weeksData.count)")
        
        withAnimation {
            if currentWeekIndex > 0 {
                currentWeekIndex -= 1
            }
        }
    }
    
    // Function to navigate to the next week
    private func goToNextWeek() {
        print("Going to next week, current index: \(currentWeekIndex), total weeks: \(weeksData.count)")
        
        withAnimation {
            if currentWeekIndex < weeksData.count - 1 {
                currentWeekIndex += 1
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar with month selector and icons
            topBar
            
            // View mode selector (redesigned) - MOVED ABOVE week selector
            viewModeSelector
            
            // Week day selector (redesigned)
            weekDaySelector
            
            // Main content based on selected view mode
            ZStack {
                switch selectedViewMode {
                case .day:
                    dayViewContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .list:
                    listViewContent
                        .transition(.asymmetric(
                            insertion: .move(edge: selectedViewMode == .list ? .trailing : .leading).combined(with: .opacity),
                            removal: .move(edge: selectedViewMode == .list ? .leading : .trailing).combined(with: .opacity)
                        ))
                case .map:
                    mapViewContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectedViewMode)
        }
        .onAppear {
            // Initialize week dates
            initializeWeekDates()
            
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
        .onChange(of: showWeekends) { newValue in
            // If weekends are turned off and current selection is a weekend, select the nearest weekday
            if !newValue && !currentWeekDates.isEmpty && selectedDayIndex < currentWeekDates.count {
                let currentDate = currentWeekDates[selectedDayIndex]
                let weekday = Calendar.current.component(.weekday, from: currentDate)
                
                // If current selection is a weekend (Sunday = 1, Saturday = 7)
                if weekday == 1 || weekday == 7 {
                    // Find the nearest weekday
                    let nearestWeekdayIndex = findNearestWeekdayIndex()
                    if nearestWeekdayIndex != -1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedDayIndex = nearestWeekdayIndex
                            selectedDate = currentWeekDates[nearestWeekdayIndex]
                        }
                    }
                }
            }
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
                        .font(.system(size: 24, weight: .bold))
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
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "#052017"))
            }
            .padding(.horizontal, 12)
            
            // Settings icon - Changed to open view options instead of settings
            Button(action: {
                showViewOptions = true
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: "#052017"))
            }
            .padding(.trailing, 16)
        }
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Month Calendar Picker
    private var monthPickerView: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar header
                HStack {
                    Button(action: {
                        goToPreviousMonth()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#246BFD"))
                    }
                    
                    Spacer()
                    
                    Text("\(selectedMonth) \(currentWeekYear)")
                        .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#052017"))
                            
                            Spacer()
                            
                    Button(action: {
                        goToNextMonth()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#246BFD"))
                            }
                        }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Day of week header
                HStack(spacing: 0) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#5A7184"))
                            .frame(maxWidth: .infinity)
                }
            }
                .padding(.vertical, 8)
                .background(Color(hex: "#F8F8F6"))
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                    ForEach(daysInSelectedMonth(), id: \.self) { day in
                        calendarDayCell(day: day.day, isCurrentMonth: day.isCurrentMonth, hasAppointments: day.hasAppointments)
                    }
                }
                .padding(.top, 8)
                
                // Appointment list for selected date
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Appointments")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#052017"))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        if let selectedDate = getSelectedDate(),
                           let appointmentsForDay = getAppointmentsForDate(selectedDate) {
                            if appointmentsForDay.isEmpty {
                                Text("No appointments for this day")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#5A7184"))
                                    .padding(.horizontal, 16)
                            } else {
                                ForEach(appointmentsForDay) { appointment in
                                    calendarAppointmentRow(appointment: appointment)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
                .background(Color(hex: "#F8F8F6"))
                
                // Done button to close the calendar
                Button(action: {
                    showMonthPicker = false
                }) {
                    Text("Done")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#246BFD"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
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
    
    // MARK: - Calendar Helper Functions
    
    // Structure to represent a day in the calendar
    private struct CalendarDay: Hashable {
        let day: Int
        let isCurrentMonth: Bool
        let hasAppointments: Bool
        let date: Date
    }
    
    // Function to get days in the selected month
    private func daysInSelectedMonth() -> [CalendarDay] {
        let calendar = Calendar.current
        
        // Create date components for the selected month
        var dateComponents = DateComponents()
        dateComponents.year = currentWeekYear
        dateComponents.month = months.firstIndex(of: selectedMonth)! + 1
        dateComponents.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else {
            return []
        }
        
        // Get the weekday of the first day (0 = Sunday, 1 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // Get the number of days in the month
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 0
        
        // Get the previous month for filling in the beginning
        var previousDateComponents = dateComponents
        previousDateComponents.month! -= 1
        let previousMonth = calendar.date(from: previousDateComponents)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 0
        
        var days: [CalendarDay] = []
        
        // Add days from previous month to fill the first week
        for i in 0..<firstWeekday {
            let day = daysInPreviousMonth - firstWeekday + i + 1
            
            // Create date for this day
            var components = DateComponents()
            components.year = previousDateComponents.month == 0 ? currentWeekYear - 1 : currentWeekYear
            components.month = previousDateComponents.month == 0 ? 12 : previousDateComponents.month
            components.day = day
            let date = calendar.date(from: components) ?? Date()
            
            days.append(CalendarDay(day: day, isCurrentMonth: false, hasAppointments: false, date: date))
        }
        
        // Add days from current month
        for day in 1...daysInMonth {
            // Create date for this day
            var components = DateComponents()
            components.year = currentWeekYear
            components.month = dateComponents.month
            components.day = day
            let date = calendar.date(from: components) ?? Date()
            
            // Check if there are appointments for this day
            let hasAppointments = appointments.contains { appointment in
                appointment.date == day
            }
            
            days.append(CalendarDay(day: day, isCurrentMonth: true, hasAppointments: hasAppointments, date: date))
        }
        
        // Fill in the remaining days from the next month
        let remainingDays = 42 - days.count // 6 rows of 7 days
        
        for day in 1...remainingDays {
            // Create date for this day
            var components = DateComponents()
            components.year = dateComponents.month == 12 ? currentWeekYear + 1 : currentWeekYear
            components.month = dateComponents.month == 12 ? 1 : dateComponents.month! + 1
            components.day = day
            let date = calendar.date(from: components) ?? Date()
            
            days.append(CalendarDay(day: day, isCurrentMonth: false, hasAppointments: false, date: date))
        }
        
        return days
    }
    
    // Function to go to previous month
    private func goToPreviousMonth() {
        let calendar = Calendar.current
        let currentMonthIndex = months.firstIndex(of: selectedMonth) ?? 0
        
        if currentMonthIndex == 0 {
            // Go to December of previous year
            selectedMonth = months[11]
            currentWeekYear -= 1
        } else {
            // Go to previous month
            selectedMonth = months[currentMonthIndex - 1]
        }
    }
    
    // Function to go to next month
    private func goToNextMonth() {
        let calendar = Calendar.current
        let currentMonthIndex = months.firstIndex(of: selectedMonth) ?? 0
        
        if currentMonthIndex == 11 {
            // Go to January of next year
            selectedMonth = months[0]
            currentWeekYear += 1
        } else {
            // Go to next month
            selectedMonth = months[currentMonthIndex + 1]
        }
    }
    
    // Function to select a specific day
    private func selectDay(_ day: Int) {
        let calendar = Calendar.current
        
        // Create date components for the selected day
        var dateComponents = DateComponents()
        dateComponents.year = currentWeekYear
        dateComponents.month = months.firstIndex(of: selectedMonth)! + 1
        dateComponents.day = day
        
        if let selectedDate = calendar.date(from: dateComponents) {
            // Find the week that contains this date
            let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
            let components = DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: currentWeekYear)
            
            if let weekStartDate = calendar.date(from: components) {
                // Update the week view
                currentWeekStartDate = weekStartDate
                
                // Generate dates for the week
                currentWeekDates = (0..<7).map { day in
                    calendar.date(byAdding: .day, value: day, to: currentWeekStartDate) ?? Date()
                }
                
                // Extract day numbers
                currentWeekDays = currentWeekDates.map { calendar.component(.day, from: $0) }
                
                // Find the index of the selected day in the week
                for (index, date) in currentWeekDates.enumerated() {
                    if calendar.component(.day, from: date) == day && 
                       calendar.component(.month, from: date) == dateComponents.month! {
                        selectedDayIndex = index
                        break
                    }
                }
                
                // Update month name
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM"
                currentWeekMonth = dateFormatter.string(from: selectedDate)
                selectedMonth = currentWeekMonth
                
                // REMOVED: showMonthPicker = false
                // This line was causing the calendar to close when a day was selected
            }
        }
    }
    
    // Function to get the currently selected date
    private func getSelectedDate() -> Date? {
        let calendar = Calendar.current
        
        // Create date components for the selected day
        var dateComponents = DateComponents()
        dateComponents.year = currentWeekYear
        dateComponents.month = months.firstIndex(of: selectedMonth)! + 1
        dateComponents.day = 1 // Default to first day
        
        return calendar.date(from: dateComponents)
    }
    
    // Function to get appointments for a specific date
    private func getAppointmentsForDate(_ date: Date) -> [Appointment]? {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        return appointments.filter { $0.date == day }
    }
    
    // Calendar day cell
    private func calendarDayCell(day: Int, isCurrentMonth: Bool, hasAppointments: Bool) -> some View {
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        let currentMonthName = DateFormatter().monthSymbols[currentMonth - 1]
        
        let isToday = isCurrentMonth && day == currentDay && 
                      selectedMonth == currentMonthName
        
        return VStack(spacing: 4) {
            Text("\(day)")
                .font(.system(size: 14, weight: isToday ? .semibold : .regular))
                .foregroundColor(
                    isCurrentMonth 
                        ? (isToday ? Color(hex: "#246BFD") : Color(hex: "#052017"))
                        : Color(hex: "#C4C4C4")
                )
            
            // Dot indicator for appointments
            if hasAppointments && isCurrentMonth {
                Circle()
                    .fill(Color(hex: "#246BFD"))
                    .frame(width: 4, height: 4)
            } else {
                Spacer()
                    .frame(height: 4)
            }
        }
        .frame(height: 48)
        .background(
            isToday ? 
                Circle()
                .stroke(Color(hex: "#246BFD"), lineWidth: 1)
                .frame(width: 32, height: 32)
                : nil
        )
        .onTapGesture {
            if isCurrentMonth {
                selectDay(day)
                // Removed: showMonthPicker = false
            }
        }
    }
    
    // Calendar appointment row
    private func calendarAppointmentRow(appointment: Appointment) -> some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color(hex: appointment.color))
                .frame(width: 4, height: 40)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#052017"))
                
                Text("\(appointment.startTime) - \(appointment.endTime) • \(appointment.clientName)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#5A7184"))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        .padding(.horizontal, 16)
    }
    
    // MARK: - View Mode Selector (Redesigned)
    private var viewModeSelector: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)) {
                        selectedViewMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedViewMode == mode ? .white : Color(hex: "#1A1A1A"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedViewMode == mode ? Color(hex: "#246BFD") : Color.clear)
                        .cornerRadius(8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: selectedViewMode)
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    // MARK: - Week Day Selector (Redesigned)
    private var weekDaySelector: some View {
        VStack(spacing: 0) {
            // Week date range display
            HStack {
                Spacer()
                
                if !currentWeekDates.isEmpty {
                    let firstDay = currentWeekDays.first ?? 1
                    let lastDay = currentWeekDays.last ?? 7
                    
                    Text("\(currentWeekMonth) \(firstDay)-\(lastDay), \(String(currentWeekYear))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#5A7184"))
                        .id("week-label-\(currentWeekIndex)")
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Carousel-style day selector
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // This creates a true carousel effect with horizontal sliding
                    TabView(selection: $currentWeekIndex) {
                        ForEach(0..<weeksData.count, id: \.self) { weekIndex in
                            weekView(for: weekIndex, width: geometry.size.width)
                                .tag(weekIndex)
                                .frame(width: geometry.size.width)
                                .contentShape(Rectangle())
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    // Add these modifiers to improve the paging behavior
                    .animation(.easeInOut(duration: 0.3), value: currentWeekIndex)
                    .id("weekTabView-\(weeksData.count)") // Force view refresh when data changes
                    // Disable scrolling resistance for smoother transitions
                    .environment(\.layoutDirection, .leftToRight)
                    .onChange(of: currentWeekIndex) { newIndex in
                        // Use withAnimation to ensure smooth transitions
                        withAnimation(.easeInOut(duration: 0.3)) {
                            setActiveWeek(index: newIndex)
                        }
                        
                        // Check if we need to add more weeks
                        let calendar = Calendar.current
                        if newIndex == weeksData.count - 1 {
                            // Add next week when we reach the end
                            if let newStartDate = calendar.date(byAdding: .day, value: 7, to: weeksData.last!.startDate) {
                                addWeekToCarousel(startDate: newStartDate)
                            }
                        } else if newIndex == 0 {
                            // Add previous week when we reach the beginning
                            if let newStartDate = calendar.date(byAdding: .day, value: -7, to: weeksData[0].startDate) {
                                addWeekToCarousel(startDate: newStartDate, addToBeginning: true)
                                // Adjust currentWeekIndex to account for the new week
                                // Use DispatchQueue to ensure this happens after the view updates
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentWeekIndex = 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 80)
        }
        .background(Color.white)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onAppear {
            initializeWeekDates()
        }
    }
    
    // Helper function to create a week view for the carousel
    private func weekView(for weekIndex: Int, width: CGFloat) -> some View {
        guard weekIndex < weeksData.count else { return AnyView(EmptyView()) }
        
        let weekData = weeksData[weekIndex]
        
        return AnyView(
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<weekData.days.count, id: \.self) { dayIndex in
                        // Filter out weekends if showWeekends is false
                        if showWeekends || (!showWeekends && !isWeekend(dayIndex: dayIndex, weekData: weekData)) {
                            Button(action: {
                                // Use withAnimation for smoother transitions
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    // Only update if this is the current week
                                    if weekIndex == currentWeekIndex {
                                        selectedDayIndex = dayIndex
                                        
                                        // Update selectedDate
                                        if dayIndex < weekData.dates.count {
                                            selectedDate = weekData.dates[dayIndex]
                                        }
                                    } else {
                                        // If tapping a day in a different week, switch to that week first
                                        currentWeekIndex = weekIndex
                                        
                                        // Use a slight delay to ensure the week transition completes first
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedDayIndex = dayIndex
                                                if dayIndex < weekData.dates.count {
                                                    selectedDate = weekData.dates[dayIndex]
                                                }
                                            }
                                        }
                                    }
                                }
                            }) {
                                VStack(spacing: 8) {
                                    // Day letter (S, M, T, etc.)
                                    if !weekData.dates.isEmpty && dayIndex < weekData.dates.count {
                                        let date = weekData.dates[dayIndex]
                                        let dayLetter = String(Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1].prefix(1))
                                        
                                        Text(dayLetter)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "#5A7184"))
                                    } else {
                                        Text(weekdays[dayIndex % 7])
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "#5A7184"))
                                    }
                                    
                                    ZStack {
                                        // Background circle for selected day
                                        Circle()
                                            .fill(weekIndex == currentWeekIndex && dayIndex == selectedDayIndex ? 
                                                  Color(hex: "#246BFD") : Color.clear)
                                            .frame(width: 36, height: 36)
                                        
                                        // Today indicator (thin circle)
                                        if !weekData.dates.isEmpty && dayIndex < weekData.dates.count {
                                            let isToday = Calendar.current.isDateInToday(weekData.dates[dayIndex])
                                            if isToday && !(weekIndex == currentWeekIndex && dayIndex == selectedDayIndex) {
                                                Circle()
                                                    .stroke(Color(hex: "#246BFD"), lineWidth: 1.5)
                                                    .frame(width: 36, height: 36)
                                            }
                                        }
                                        
                                        // Day number
                                        if !weekData.days.isEmpty && dayIndex < weekData.days.count {
                                            Text("\(weekData.days[dayIndex])")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(weekIndex == currentWeekIndex && dayIndex == selectedDayIndex ? 
                                                                .white : Color(hex: "#1A2E3B"))
                                        } else {
                                            Text("\(dayIndex + 1)")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(weekIndex == currentWeekIndex && dayIndex == selectedDayIndex ? 
                                                                .white : Color(hex: "#1A2E3B"))
                                        }
                                    }
                                    
                                    // Indicator for days with appointments
                                    if !weekData.days.isEmpty && dayIndex < weekData.days.count && 
                                       appointments.contains(where: { $0.date == weekData.days[dayIndex] }) {
                                        Circle()
                                            .fill(Color(hex: "#246BFD"))
                                            .frame(width: 4, height: 4)
                                    } else {
                                        Spacer()
                                            .frame(height: 4)
                                    }
                                }
                                .frame(width: 42)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .frame(width: width)
        }
        )
    }
    
    // Helper function to check if a day index represents a weekend
    private func isWeekend(dayIndex: Int, weekData: WeekData) -> Bool {
        guard dayIndex < weekData.dates.count else { return false }
        let date = weekData.dates[dayIndex]
        let weekday = Calendar.current.component(.weekday, from: date)
        // weekday 1 = Sunday, weekday 7 = Saturday
        return weekday == 1 || weekday == 7
    }
    
    // Helper function to find the nearest weekday index
    private func findNearestWeekdayIndex() -> Int {
        guard !currentWeekDates.isEmpty else { return -1 }
        
        // Look for the nearest weekday (prefer forward direction, then backward)
        for offset in 0..<currentWeekDates.count {
            // Check forward
            let forwardIndex = (selectedDayIndex + offset) % currentWeekDates.count
            if forwardIndex < currentWeekDates.count {
                let forwardDate = currentWeekDates[forwardIndex]
                let forwardWeekday = Calendar.current.component(.weekday, from: forwardDate)
                if forwardWeekday != 1 && forwardWeekday != 7 { // Not Sunday or Saturday
                    return forwardIndex
                }
            }
            
            // Check backward (only if offset > 0 to avoid checking the same index twice)
            if offset > 0 {
                let backwardIndex = (selectedDayIndex - offset + currentWeekDates.count) % currentWeekDates.count
                if backwardIndex >= 0 && backwardIndex < currentWeekDates.count {
                    let backwardDate = currentWeekDates[backwardIndex]
                    let backwardWeekday = Calendar.current.component(.weekday, from: backwardDate)
                    if backwardWeekday != 1 && backwardWeekday != 7 { // Not Sunday or Saturday
                        return backwardIndex
                    }
                }
            }
        }
        
        // Fallback to Monday (index 1) if no weekday found
        return 1
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
                // Date header - Fixed to show the actual selected date
                Text(selectedDateFormatted)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#052017"))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                // Check if we have any tasks to show
                let hasTasks = !tasksForSelectedDay.isEmpty
                
                if !hasTasks {
                    // Empty state - no tasks
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#5A7184").opacity(0.6))
                            .padding(.bottom, 8)
                        
                        Text("No tasks scheduled")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#5A7184"))
                        
                        Text("Tap the + button to create a new task")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#5A7184").opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Show tasks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tasks")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#052017"))
                            .padding(.horizontal, 16)
                        
                        ForEach(tasksForSelectedDay) { task in
                            listTaskRow(task: task)
                    }
                    .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.bottom, 100) // Add padding for tab bar
        }
    }
    
    // Computed property for formatted selected date
    private var selectedDateFormatted: String {
        if !currentWeekDates.isEmpty && selectedDayIndex < currentWeekDates.count {
            let selectedDate = currentWeekDates[selectedDayIndex]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            return dateFormatter.string(from: selectedDate)
        } else {
            return "No Date Selected"
        }
    }
    
    // MARK: - List Task Row
    private func listTaskRow(task: Task) -> some View {
        Button(action: {
            selectedTask = task
            showTaskDetails = true
        }) {
            HStack(spacing: 12) {
                // Time column (if task has a specific time)
                VStack(spacing: 4) {
                    if let dueDate = task.dueDate, !task.isAllDayTask {
                        Text(formatTaskTime(dueDate))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#052017"))
                    } else {
                        Text("All Day")
                            .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#5A7184"))
                    }
                }
                .frame(width: 60)
                
                // Priority indicator line
                Rectangle()
                    .fill(Color(hex: priorityColor(for: task.priority)))
                    .frame(width: 4, height: 50)
                
                // Task details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(task.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#052017"))
                    
                        Spacer()
                        
                        // Completion indicator
                        if task.status == "Completed" {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#4CAF50"))
                                .font(.system(size: 16))
                        }
                    }
                    
                    Text(task.taskDescription)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#5A7184"))
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#5A7184"))
                        
                        Text(task.assignee)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#5A7184"))
                        
                        Spacer()
                        
                        // Priority badge
                        Text(task.priority)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: priorityColor(for: task.priority)))
                            .cornerRadius(4)
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
    
    // Helper function to format task time
    private func formatTaskTime(_ date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        return timeFormatter.string(from: date)
    }
    
    // MARK: - Map View Content
    private var mapViewContent: some View {
        VStack {
            // Functional map view using MapKit with filtered POIs
            AppointmentsMapView(appointments: appointmentsForSelectedDay)
                .overlay(
                    VStack {
                        Spacer()
                        Text("Showing \(appointmentsForSelectedDay.count) appointments")
                            .font(.caption)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .padding(.bottom, 16)
                    }
                )
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
                        
                        // Functional map
                        AppointmentLocationMapView(location: appointment.location)
                            .frame(height: 120)
                            .cornerRadius(8)
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
                        
                        // Removed unscheduled appointments toggle since it was related to map view
                        // toggleOption(
                        //     title: "Show unscheduled appointments on map view",
                        //     isOn: $showUnscheduledAppointments
                        // )
                        
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