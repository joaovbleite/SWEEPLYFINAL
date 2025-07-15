import SwiftUI
import SwiftData

// Line Item model
struct LineItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
    var price: Double
}

struct NewJobView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @Query private var clients: [Client]
    
    // Form fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var propertyAddress = ""
    @State private var jobTitle = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var selectedClient: Client? = nil
    @State private var showClientPicker = false
    
    // Additional form fields from new image
    @State private var instructions = ""
    @State private var salesperson = "Please select"
    @State private var showSalespersonPicker = false
    @State private var lineItems: [LineItem] = []
    @State private var subtotal: Double = 0.00
    @State private var scheduleLater = false
    
    // Calendar and team selection
    @State private var selectedMonth = Date()
    @State private var selectedDate = Date()
    @State private var showTeamPicker = false
    @State private var selectedTeamMember = ""
    @State private var remindToInvoice = false
    
    // Colors from design system
    let primaryColor = Color(hex: "#2563EB")
    let successColor = Color(hex: "#34D399")
    let inputBorderColor = Color(hex: "#D1D5DB")
    let placeholderColor = Color(hex: "#9CA3AF")
    let iconColor = Color(hex: "#6B7280")
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    let greenColor = Color(hex: "#4CAF50")
    let sectionBackgroundColor = Color(hex: "#F5F5F5")
    
    // Check if the form is valid for saving
    private var isFormValid: Bool {
        return (!firstName.isEmpty || !lastName.isEmpty || selectedClient != nil) && !jobTitle.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with back button and title
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                    }
                    
                    Spacer()
                    
                    Text("New job")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(defaultTextColor)
                    
                    Spacer()
                    
                    // Empty space to balance the layout
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                .zIndex(1) // Ensure header stays on top
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Client Info Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Client info")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(defaultTextColor)
                                .padding(.horizontal, 16)
                            
                            // Select Existing Client Button
                            Button(action: {
                                showClientPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 18))
                                        .foregroundColor(greenColor)
                                    
                                    Text("Select Existing Client")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(greenColor)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                            
                            // First name field
                            HStack(spacing: 8) {
                                Image(systemName: "person")
                                    .font(.system(size: 18))
                                    .foregroundColor(iconColor)
                                    .frame(width: 24)
                                
                                TextField("", text: $firstName)
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                    .placeholderText(when: firstName.isEmpty) {
                                        Text("First name")
                                            .foregroundColor(placeholderColor)
                                    }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputBorderColor, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                            
                            // Last name field
                            TextField("", text: $lastName)
                                .font(.system(size: 16))
                                .foregroundColor(defaultTextColor)
                                .placeholderText(when: lastName.isEmpty) {
                                    Text("Last name")
                                        .foregroundColor(placeholderColor)
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            
                            // Property address field
                            HStack(spacing: 8) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 18))
                                    .foregroundColor(iconColor)
                                    .frame(width: 24)
                                
                                TextField("", text: $propertyAddress)
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                    .placeholderText(when: propertyAddress.isEmpty) {
                                        Text("Property address")
                                            .foregroundColor(placeholderColor)
                                    }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputBorderColor, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                            
                            // Add Phone Number Button
                            Button(action: {
                                // Action to add phone number
                            }) {
                                HStack {
                                    Image(systemName: "phone")
                                        .font(.system(size: 18))
                                        .foregroundColor(greenColor)
                                    
                                    Text("Add Phone Number")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(greenColor)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                            
                            // Add Email Button
                            Button(action: {
                                // Action to add email
                            }) {
                                HStack {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 18))
                                        .foregroundColor(greenColor)
                                    
                                    Text("Add Email")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(greenColor)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(sectionBackgroundColor)
                        
                        // Overview Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Overview")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(defaultTextColor)
                                .padding(.horizontal, 16)
                            
                            // Job title field
                            TextField("", text: $jobTitle)
                                .font(.system(size: 16))
                                .foregroundColor(defaultTextColor)
                                .placeholderText(when: jobTitle.isEmpty) {
                                    Text("Job title")
                                        .foregroundColor(placeholderColor)
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            
                            // Instructions field (new)
                            TextField("", text: $instructions)
                                .font(.system(size: 16))
                                .foregroundColor(defaultTextColor)
                                .placeholderText(when: instructions.isEmpty) {
                                    Text("Instructions")
                                        .foregroundColor(placeholderColor)
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 16)
                        .background(sectionBackgroundColor)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Salesperson Section (new)
                        VStack(alignment: .leading, spacing: 16) {
                            Button(action: {
                                showSalespersonPicker = true
                            }) {
                                HStack {
                                    Text("Salesperson")
                                        .font(.system(size: 16))
                                        .foregroundColor(defaultTextColor)
                                    
                                    Spacer()
                                    
                                    Text(salesperson)
                                        .font(.system(size: 16))
                                        .foregroundColor(salesperson == "Please select" ? placeholderColor : defaultTextColor)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(iconColor)
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(sectionBackgroundColor)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Product/Service Section (new)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Product / Service")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(defaultTextColor)
                                .padding(.horizontal, 16)
                            
                            // Line items header
                            HStack {
                                Text("Line items")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(defaultTextColor)
                                
                                Spacer()
                                
                                Button(action: {
                                    // Add line item
                                    let newItem = LineItem(name: "", quantity: 1, price: 0.0)
                                    lineItems.append(newItem)
                                    calculateSubtotal()
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(greenColor)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Line items list
                            ForEach(lineItems.indices, id: \.self) { index in
                                lineItemView(for: index)
                            }
                            
                            // Subtotal
                            HStack {
                                Text("Subtotal")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(defaultTextColor)
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", subtotal))")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(defaultTextColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                        .padding(.vertical, 16)
                        .background(sectionBackgroundColor)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Schedule Section (new)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Schedule")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(defaultTextColor)
                                .padding(.horizontal, 16)
                            
                            // Schedule later toggle
                            HStack {
                                Text("Schedule later")
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                
                                Spacer()
                                
                                Toggle("", isOn: $scheduleLater)
                                    .toggleStyle(SwitchToggleStyle(tint: greenColor))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            
                            if !scheduleLater {
                                // Calendar view
                                VStack(spacing: 16) {
                                    // Month header with navigation
                                    HStack {
                                        Button(action: {
                                            // Previous month
                                            if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
                                                selectedMonth = newDate
                                            }
                                        }) {
                                            Image(systemName: "chevron.left")
                                                .foregroundColor(greenColor)
                                                .font(.system(size: 20, weight: .medium))
                                        }
                                        
                                        Spacer()
                                        
                                        Text(monthYearString(from: selectedMonth))
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(defaultTextColor)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            // Next month
                                            if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
                                                selectedMonth = newDate
                                            }
                                        }) {
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(greenColor)
                                                .font(.system(size: 20, weight: .medium))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Day of week headers
                                    HStack(spacing: 0) {
                                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                            Text(day)
                                                .font(.system(size: 16, weight: .medium))
                                                .frame(maxWidth: .infinity)
                                                .foregroundColor(mutedTextColor)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Calendar grid
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                                        ForEach(daysInSelectedMonth(), id: \.self) { day in
                                            Button(action: {
                                                if day.isCurrentMonth {
                                                    selectedDate = day.date
                                                }
                                            }) {
                                                Text("\(day.day)")
                                                    .font(.system(size: 16))
                                                    .frame(height: 36)
                                                    .frame(maxWidth: .infinity)
                                                    .background(
                                                        ZStack {
                                                            if Calendar.current.isDate(day.date, inSameDayAs: selectedDate) {
                                                                Circle()
                                                                    .fill(greenColor)
                                                            } else if Calendar.current.isDateInToday(day.date) && day.isCurrentMonth {
                                                                Circle()
                                                                    .stroke(greenColor, lineWidth: 1)
                                                            }
                                                        }
                                                    )
                                                    .foregroundColor(
                                                        Calendar.current.isDate(day.date, inSameDayAs: selectedDate) ? .white :
                                                            day.isCurrentMonth ? defaultTextColor : placeholderColor
                                                    )
                                            }
                                            .disabled(!day.isCurrentMonth)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .background(sectionBackgroundColor)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Team section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "person.2")
                                    .font(.system(size: 18))
                                    .foregroundColor(defaultTextColor)
                                
                                Text("Team")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(defaultTextColor)
                                
                                Spacer()
                                
                                Button(action: {
                                    // Navigate to team selection
                                    showTeamPicker = true
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16))
                                        .foregroundColor(greenColor)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Selected team member
                            if !selectedTeamMember.isEmpty {
                                Text(selectedTeamMember)
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(sectionBackgroundColor)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Invoicing section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Invoicing")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(defaultTextColor)
                                .padding(.horizontal, 16)
                            
                            // Remind to invoice toggle
                            HStack {
                                Text("Remind me to invoice when I close the job")
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                
                                Spacer()
                                
                                Toggle("", isOn: $remindToInvoice)
                                    .toggleStyle(SwitchToggleStyle(tint: greenColor))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                        .padding(.vertical, 16)
                        .background(sectionBackgroundColor)
                        
                        Spacer(minLength: 80)
                    }
                }
                
                // Save Button
                Button(action: {
                    // Save job action
                    saveJob()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isFormValid ? greenColor : Color.gray)
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }
                .disabled(!isFormValid)
                .background(Color.white)
            }
            .background(sectionBackgroundColor)
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSalespersonPicker) {
            salespersonPickerView()
        }
        .sheet(isPresented: $showTeamPicker) {
            teamPickerView()
        }
        .sheet(isPresented: $showClientPicker) {
            clientPickerView()
        }
    }
    
    // Line item view
    private func lineItemView(for index: Int) -> some View {
        VStack(spacing: 12) {
            // Item name
            TextField("Item name", text: Binding(
                get: { self.lineItems[index].name },
                set: { self.lineItems[index].name = $0 }
            ))
            .font(.system(size: 16))
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(inputBorderColor, lineWidth: 1)
            )
            
            HStack(spacing: 12) {
                // Quantity
                HStack {
                    Text("Qty:")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("1", value: Binding(
                        get: { self.lineItems[index].quantity },
                        set: { 
                            self.lineItems[index].quantity = $0
                            calculateSubtotal()
                        }
                    ), formatter: NumberFormatter())
                    .font(.system(size: 16))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                }
                .padding(8)
                .frame(width: 80)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(inputBorderColor, lineWidth: 1)
                )
                
                // Price
                HStack {
                    Text("$")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("0.00", value: Binding(
                        get: { self.lineItems[index].price },
                        set: { 
                            self.lineItems[index].price = $0
                            calculateSubtotal()
                        }
                    ), formatter: NumberFormatter())
                    .font(.system(size: 16))
                    .keyboardType(.decimalPad)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(inputBorderColor, lineWidth: 1)
                )
                
                // Delete button
                Button(action: {
                    lineItems.remove(at: index)
                    calculateSubtotal()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // Calculate subtotal
    private func calculateSubtotal() {
        subtotal = lineItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    // Save job to SwiftData
    private func saveJob() {
        // Create client if needed
        var client: Client? = selectedClient
        
        if selectedClient == nil && (!firstName.isEmpty || !lastName.isEmpty) {
            // Create a new client
            let newClient = Client(
                firstName: firstName,
                lastName: lastName,
                companyName: "",
                phoneNumber: phoneNumber,
                phoneLabel: "Main",
                receivesTextMessages: false,
                email: email,
                leadSource: "",
                propertyAddress: propertyAddress,
                billingAddress: propertyAddress
            )
            
            // Save client to SwiftData
            modelContext.insert(newClient)
            client = newClient
        }
        
        // Create the job
        let job = Job(
            firstName: firstName,
            lastName: lastName,
            propertyAddress: propertyAddress,
            jobTitle: jobTitle,
            instructions: instructions,
            phoneNumber: phoneNumber,
            email: email,
            salesperson: salesperson,
            lineItems: lineItems,
            subtotal: subtotal,
            scheduleLater: scheduleLater,
            scheduledDate: scheduleLater ? nil : selectedDate,
            teamMember: selectedTeamMember,
            remindToInvoice: remindToInvoice,
            client: client
        )
        
        // Save job to SwiftData
        modelContext.insert(job)
    }
    
    // Salesperson picker view
    private func salespersonPickerView() -> some View {
        let salespeople = ["John Doe", "Jane Smith", "Michael Johnson", "Sarah Williams"]
        
        return NavigationView {
            List {
                ForEach(salespeople, id: \.self) { person in
                    Button(action: {
                        salesperson = person
                        showSalespersonPicker = false
                    }) {
                        HStack {
                            Text(person)
                                .foregroundColor(defaultTextColor)
                            
                            Spacer()
                            
                            if salesperson == person {
                                Image(systemName: "checkmark")
                                    .foregroundColor(greenColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Salesperson")
            .navigationBarItems(trailing: Button("Cancel") {
                showSalespersonPicker = false
            })
        }
    }
    
    // Team picker view
    private func teamPickerView() -> some View {
        let teamMembers = ["Joao", "Sarah", "Michael", "David", "Emma"]
        
        return NavigationView {
            List {
                ForEach(teamMembers, id: \.self) { member in
                    Button(action: {
                        selectedTeamMember = member
                        showTeamPicker = false
                    }) {
                        HStack {
                            Text(member)
                                .foregroundColor(defaultTextColor)
                            
                            Spacer()
                            
                            if selectedTeamMember == member {
                                Image(systemName: "checkmark")
                                    .foregroundColor(greenColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Team Member")
            .navigationBarItems(trailing: Button("Cancel") {
                showTeamPicker = false
            })
        }
    }
    
    // Client picker view
    private func clientPickerView() -> some View {
        NavigationView {
            List {
                ForEach(clients) { client in
                    Button(action: {
                        selectClient(client)
                        showClientPicker = false
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(client.fullName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(defaultTextColor)
                                
                                if !client.propertyAddress.isEmpty {
                                    Text(client.propertyAddress.components(separatedBy: "\n").first ?? "")
                                        .font(.system(size: 14))
                                        .foregroundColor(mutedTextColor)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedClient?.id == client.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(greenColor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Client")
            .navigationBarItems(trailing: Button("Cancel") {
                showClientPicker = false
            })
        }
    }
    
    // Select client
    private func selectClient(_ client: Client) {
        selectedClient = client
        firstName = client.firstName
        lastName = client.lastName
        propertyAddress = client.propertyAddress
        phoneNumber = client.phoneNumber
        email = client.email
    }
    
    // Calendar helper functions
    
    // Structure to represent a day in the calendar
    private struct CalendarDay: Hashable {
        let day: Int
        let isCurrentMonth: Bool
        let date: Date
    }
    
    // Get days for the selected month
    private func daysInSelectedMonth() -> [CalendarDay] {
        let calendar = Calendar.current
        
        // Get the first day of the month
        var dateComponents = calendar.dateComponents([.year, .month], from: selectedMonth)
        dateComponents.day = 1
        
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else {
            return []
        }
        
        // Get the weekday of the first day (0 = Sunday, 1 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // Get the number of days in the month
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count ?? 0
        
        // Get the previous month for filling in the first week
        var previousDateComponents = dateComponents
        previousDateComponents.month = previousDateComponents.month! - 1
        let previousMonth = calendar.date(from: previousDateComponents)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 0
        
        var days: [CalendarDay] = []
        
        // Add days from previous month to fill the first week
        if firstWeekday > 0 {
            for day in (daysInPreviousMonth - firstWeekday + 1)...daysInPreviousMonth {
                var components = calendar.dateComponents([.year, .month], from: previousMonth)
                components.day = day
                let date = calendar.date(from: components) ?? Date()
                
                days.append(CalendarDay(day: day, isCurrentMonth: false, date: date))
            }
        }
        
        // Add days from current month
        for day in 1...daysInMonth {
            var components = calendar.dateComponents([.year, .month], from: firstDayOfMonth)
            components.day = day
            let date = calendar.date(from: components) ?? Date()
            
            days.append(CalendarDay(day: day, isCurrentMonth: true, date: date))
        }
        
        // Add days from next month to complete the grid (up to 42 days total for 6 weeks)
        let remainingDays = 42 - days.count
        if remainingDays > 0 {
            for day in 1...remainingDays {
                var components = calendar.dateComponents([.year, .month], from: firstDayOfMonth)
                components.month = components.month! + 1
                components.day = day
                let date = calendar.date(from: components) ?? Date()
                
                days.append(CalendarDay(day: day, isCurrentMonth: false, date: date))
            }
        }
        
        return days
    }
    
    // Format month and year string
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// Remove the Job struct since we're now using the SwiftData model
// defined in Item.swift

#Preview {
    NewJobView()
} 