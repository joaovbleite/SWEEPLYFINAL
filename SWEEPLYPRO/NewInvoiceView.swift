//
//  NewInvoiceView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct InvoiceItem: Identifiable {
    let id = UUID()
    var description: String
    var quantity: Int
    var rate: Double
    
    var amount: Double {
        return Double(quantity) * rate
    }
}

struct InvoiceStatus {
    static let draft = "Draft"
    static let sent = "Sent"
    static let paid = "Paid"
    static let overdue = "Overdue"
    
    static func color(for status: String) -> Color {
        switch status {
        case draft:
            return Color(hex: "#6B7280") // Gray
        case sent:
            return Color(hex: "#3B82F6") // Blue
        case paid:
            return Color(hex: "#10B981") // Green
        case overdue:
            return Color(hex: "#EF4444") // Red
        default:
            return Color(hex: "#6B7280")
        }
    }
    
    static func icon(for status: String) -> String {
        switch status {
        case draft:
            return "doc.text"
        case sent:
            return "paperplane"
        case paid:
            return "checkmark.circle"
        case overdue:
            return "exclamationmark.circle"
        default:
            return "doc.text"
        }
    }
}

struct NewInvoiceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields
    @State private var clientName = ""
    @State private var clientEmail = ""
    @State private var clientPhone = ""
    @State private var clientAddress = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var propertyAddress = ""
    @State private var invoiceTitle = "Invoice title"
    @State private var invoiceSubtitle = "For Services Rendered"
    @State private var issueDateOption = "Date sent"
    @State private var paymentDueOption = "Net 30"
    @State private var issueDate = Date()
    @State private var dueDate = Date().addingTimeInterval(60*60*24*30) // 30 days later
    @State private var status = InvoiceStatus.draft
    @State private var items: [InvoiceItem] = []
    @State private var notes = ""
    @State private var showClientFields = false
    @State private var showIssueDateOptions = false
    @State private var showPaymentDueOptions = false
    @State private var showIssueDatePicker = false
    @State private var showDueDatePicker = false
    @State private var selectedMonth = Date()
    @State private var showCustomDueDateField = false
    @State private var showAddServiceView = false
    
    // Issue date options
    let issueDateOptions = ["Date sent", "Date received", "Custom date"]
    
    // Payment due options
    let paymentDueOptions = ["Net 30", "Net 15", "Net 7", "Due on receipt", "Custom"]
    
    // Keyboard focus state
    @FocusState private var focusedField: Field?
    
    // Focus fields enum
    enum Field: Hashable {
        case notes
        case itemDescription(Int)
        case itemQuantity(Int)
        case itemRate(Int)
    }
    
    // Colors from design system
    let primaryColor = Color(hex: "#2563EB")
    let successColor = Color(hex: "#34D399")
    let inputBorderColor = Color(hex: "#D1D5DB")
    let placeholderColor = Color(hex: "#9CA3AF")
    let iconColor = Color(hex: "#6B7280")
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    let backgroundColor = Color(hex: "#F5F5F5")
    
    var totalAmount: Double {
        return items.reduce(0) { $0 + $1.amount }
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
                            .foregroundColor(primaryColor)
                    }
                    
                    Spacer()
                    
                    Text("New Invoice")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(defaultTextColor)
                    
                    Spacer()
                    
                    // Empty spacer to balance the layout
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                .zIndex(1) // Ensure header stays on top
                
                // All content in ScrollView
                ScrollView {
                    VStack(spacing: 24) {
                        // Client section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Billed To")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(mutedTextColor)
                                
                                Spacer()
                                
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 18))
                                    .foregroundColor(primaryColor)
                            }
                            
                            Button(action: {
                                // Select client action
                                showClientFields = true
                            }) {
                                HStack {
                                    Image(systemName: "person")
                                        .font(.system(size: 18))
                                        .foregroundColor(iconColor)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(clientName.isEmpty ? "Select Client" : clientName)
                                            .font(.system(size: 16))
                                            .foregroundColor(clientName.isEmpty ? placeholderColor : defaultTextColor)
                                        
                                        if !clientName.isEmpty {
                                            Text(clientEmail.isEmpty ? "Add email address" : clientEmail)
                                                .font(.system(size: 14))
                                                .foregroundColor(clientEmail.isEmpty ? placeholderColor : mutedTextColor)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(iconColor)
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                            }
                            
                            // Client information fields (shown if no client is selected or showClientFields is true)
                            if showClientFields || clientName.isEmpty {
                                ClientInfoFields(firstName: $firstName, lastName: $lastName, propertyAddress: $propertyAddress)
                            }
                        }
                        
                        // Invoice details
                        InvoiceDetailsView(invoiceTitle: $invoiceTitle, invoiceSubtitle: $invoiceSubtitle, issueDateOption: $issueDateOption, showIssueDateOptions: $showIssueDateOptions, showIssueDatePicker: $showIssueDatePicker, issueDate: $issueDate, status: status)
                        
                        if showIssueDateOptions {
                            IssueDateOptionsView(issueDateOption: $issueDateOption, showIssueDateOptions: $showIssueDateOptions, showIssueDatePicker: $showIssueDatePicker, issueDateOptions: issueDateOptions)
                        }
                        
                        // Custom Date Picker
                        if issueDateOption == "Custom date" && showIssueDatePicker {
                            CustomDatePickerView(selectedMonth: $selectedMonth, selectedDate: $issueDate, showDatePicker: $showIssueDatePicker)
                        }
                        
                        // Payment due section
                        PaymentDueSectionView(paymentDueOption: $paymentDueOption, showPaymentDueOptions: $showPaymentDueOptions, showDueDatePicker: $showDueDatePicker, showCustomDueDateField: $showCustomDueDateField, dueDate: $dueDate)
                        
                        if showPaymentDueOptions {
                            PaymentDueOptionsView(paymentDueOption: $paymentDueOption, showPaymentDueOptions: $showPaymentDueOptions, showCustomDueDateField: $showCustomDueDateField, showDueDatePicker: $showDueDatePicker, dueDate: $dueDate, issueDate: $issueDate, paymentDueOptions: paymentDueOptions)
                        }
                        
                        // Custom Due Date Field
                        if paymentDueOption == "Custom" && showCustomDueDateField {
                            CustomDueDateFieldView(showDueDatePicker: $showDueDatePicker)
                        }
                        
                        // Custom Due Date Picker
                        if paymentDueOption == "Custom" && showDueDatePicker {
                            CustomDatePickerView(selectedMonth: $selectedMonth, selectedDate: $dueDate, showDatePicker: $showDueDatePicker)
                        }
                    }
                    
                    // Line items
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Service")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mutedTextColor)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("Service")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(defaultTextColor)
                            
                            Spacer()
                            
                            Button(action: {
                                showAddServiceView = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "#2563EB"))
                                    .padding(8)
                            }
                        }
                        
                        // Line items - only show if there are items
                        if !items.isEmpty {
                        ForEach(0..<items.count, id: \.self) { index in
                            LineItemRow(item: $items[index], index: index, isLast: index == items.count - 1, focusedField: $focusedField)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Invoice summary
                        InvoiceSummaryView(totalAmount: totalAmount)
                        
                        Divider()
                            .padding(.vertical, 16)
                        
                        // Client message
                        HStack {
                            Text("Client message")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(defaultTextColor)
                            
                            Spacer()
                            
                            Button(action: {
                                // Add client message action
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "#2563EB"))
                                    .padding(8)
                            }
                        }
                    }
                    
                    // Save button
                    Button(action: {
                        // Save action
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 16))
                            
                            Text("Save Invoice")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(successColor)
                        .cornerRadius(12)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(backgroundColor)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        focusedField = nil
                    }
                    .foregroundColor(primaryColor)
                }
            }
            .sheet(isPresented: $showIssueDatePicker) {
                // Issue date picker sheet
                VStack {
                    HStack {
                        Button("Cancel") {
                            showIssueDatePicker = false
                        }
                        .foregroundColor(primaryColor)
                        
                        Spacer()
                        
                        Text("Select Date")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                        
                        Button("Done") {
                            showIssueDatePicker = false
                        }
                        .foregroundColor(primaryColor)
                    }
                    .padding()
                    
                    DatePicker("", selection: $issueDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showDueDatePicker) {
                // Due date picker sheet
                VStack {
                    HStack {
                        Button("Cancel") {
                            showDueDatePicker = false
                        }
                        .foregroundColor(primaryColor)
                        
                        Spacer()
                        
                        Text("Select Date")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                        
                        Button("Done") {
                            showDueDatePicker = false
                        }
                        .foregroundColor(primaryColor)
                    }
                    .padding()
                    
                    DatePicker("", selection: $dueDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showAddServiceView) {
                AddServiceView(isPresented: $showAddServiceView) { service in
                    items.append(InvoiceItem(description: service.name, quantity: 1, rate: service.price))
                }
            }
        }
    }
}

// Custom calendar grid view to break up complex expressions
struct CalendarGridView: View {
    let selectedMonth: Date
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Days of week
            HStack(spacing: 0) {
                ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        Button(action: {
                            onDateSelected(date)
                        }) {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .white : .white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color(hex: "#246BFD") : Color.clear)
                                )
                        }
                    } else {
                        Text("")
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
    }
    
    // Generate days for the month
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        
        // Get the first day of the month
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        // Get weekday of first day (0 = Sunday, 1 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Create array with empty slots for days before the first day of month
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        // Add the days of the month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Fill the rest of the last week with nil
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7 {
            days.append(contentsOf: Array(repeating: nil, count: remainingDays))
        }
        
        return days
    }
}

// Line item row component
struct LineItemRow: View {
    @Binding var item: InvoiceItem
    var index: Int
    var isLast: Bool
    var focusedField: FocusState<NewInvoiceView.Field?>.Binding
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let placeholderColor = Color(hex: "#9CA3AF")
    let mutedTextColor = Color(hex: "#6B7280")
    let inputBorderColor = Color(hex: "#D1D5DB")
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Service Title
                Text(item.description)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(defaultTextColor)
                
                Spacer()
                
                // Unit price
                Text("$\(String(format: "%.2f", item.rate))")
                    .font(.system(size: 18))
                    .foregroundColor(defaultTextColor)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(inputBorderColor, lineWidth: 1)
            )
            
            if !isLast {
                Divider()
                    .padding(.vertical, 8)
            }
        }
    }
}

// Client information fields component
struct ClientInfoFields: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var propertyAddress: String
    
    // Additional address fields
    @State private var showAddressFields = false
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var state = "Select..."
    @State private var zipCode = ""
    @State private var country = "United States"
    
    // Focus state
    @FocusState private var focusedField: Field?
    
    // Focus fields enum
    enum Field: Hashable {
        case firstName
        case lastName
        case propertyAddress
        case addressLine2
        case city
        case zipCode
    }
    
    // State options
    let states = ["Select...", "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    // Country options
    let countries = ["United States", "Canada", "Mexico", "United Kingdom", "Australia", "Germany", "France", "Japan", "China", "Brazil", "Other"]
    
    // Colors
    let iconColor = Color(hex: "#6B7280")
    let defaultTextColor = Color(hex: "#0F1A2B")
    let inputBorderColor = Color(hex: "#D1D5DB")
    let placeholderColor = Color(hex: "#9CA3AF")
    
    var body: some View {
        VStack(spacing: 16) {
            // First name field
            HStack(spacing: 12) {
                Image(systemName: "person.crop.square")
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                TextField("First name", text: $firstName)
                    .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
                    .focused($focusedField, equals: .firstName)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(inputBorderColor, lineWidth: 1)
            )
            
            // Last name field
            HStack(spacing: 12) {
                Image(systemName: "person.crop.square")
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                TextField("Last name", text: $lastName)
                    .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
                    .focused($focusedField, equals: .lastName)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(inputBorderColor, lineWidth: 1)
            )
            
            // Property address field
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle")
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                TextField("Property address", text: $propertyAddress)
                    .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
                    .focused($focusedField, equals: .propertyAddress)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(inputBorderColor, lineWidth: 1)
            )
            .contentShape(Rectangle()) // Make the entire area tappable
            .onTapGesture {
                withAnimation {
                    showAddressFields = true
                    // Focus on the property address field
                    focusedField = .propertyAddress
                }
            }
            
            // Additional address fields (shown when property address is tapped)
            if showAddressFields {
                // Address line 2
                TextField("Address line 2", text: $addressLine2)
                    .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
                    .focused($focusedField, equals: .addressLine2)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(inputBorderColor, lineWidth: 1)
                    )
                
                // City
                TextField("City", text: $city)
                    .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
                    .focused($focusedField, equals: .city)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(inputBorderColor, lineWidth: 1)
                    )
                
                // State dropdown
                Menu {
                    ForEach(states, id: \.self) { stateOption in
                        Button(stateOption) {
                            state = stateOption
                        }
                    }
                } label: {
                    HStack {
                        Text(state)
                            .font(.system(size: 16))
                            .foregroundColor(state == "Select..." ? placeholderColor : defaultTextColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(iconColor)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(inputBorderColor, lineWidth: 1)
                    )
                }
                
                // Zip code
                TextField("Zip code", text: $zipCode)
                    .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
                    .focused($focusedField, equals: .zipCode)
                    .keyboardType(.numberPad)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(inputBorderColor, lineWidth: 1)
                    )
                
                // Country dropdown
                Menu {
                    ForEach(countries, id: \.self) { countryOption in
                        Button(countryOption) {
                            country = countryOption
                        }
                    }
                } label: {
                    HStack {
                        Text(country)
                            .font(.system(size: 16))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(iconColor)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(inputBorderColor, lineWidth: 1)
                    )
                }
            }
            
            // Phone number field
            Button(action: {
                // Action to add phone number
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "phone")
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                        .frame(width: 24)
                    
                    Text("Add Phone Number")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#2563EB"))
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(inputBorderColor, lineWidth: 1)
                )
            }
            
            // Email field
            Button(action: {
                // Action to add email
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                        .frame(width: 24)
                    
                    Text("Add Email")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#2563EB"))
                    
                    Spacer()
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(inputBorderColor, lineWidth: 1)
                )
            }
        }
        .padding(.top, 16)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    focusedField = nil
                }
                .foregroundColor(Color(hex: "#2563EB"))
            }
        }
    }
}

// Invoice summary component
struct InvoiceSummaryView: View {
    let totalAmount: Double
    @State private var showDiscountView = false
    @State private var discountAmount: Double = 0.0
    @State private var discountType: DiscountType = .fixed
    
    enum DiscountType {
        case percentage
        case fixed
    }
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let primaryColor = Color(hex: "#2563EB")
    
    var formattedDiscount: String {
        if discountAmount == 0 {
            return "$0.00"
        } else if discountType == .percentage {
            return "\(Int(discountAmount))% ($\(String(format: "%.2f", calculateDiscountValue())))"
        } else {
            return "$\(String(format: "%.2f", discountAmount))"
        }
    }
    
    var effectiveTotal: Double {
        return totalAmount - calculateDiscountValue()
    }
    
    func calculateDiscountValue() -> Double {
        if discountType == .percentage {
            return totalAmount * (discountAmount / 100.0)
        } else {
            return min(discountAmount, totalAmount) // Can't discount more than total
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Subtotal
            HStack {
                Text("Subtotal")
                    .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", totalAmount))")
                    .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
            }
            .padding(.vertical, 8)
            
            // Discount
            Button(action: {
                showDiscountView = true
            }) {
            HStack {
                Text("Discount")
                        .font(.system(size: 16))
                    .foregroundColor(defaultTextColor)
                
                Spacer()
                
                    Text(formattedDiscount)
                        .font(.system(size: 16))
                        .foregroundColor(primaryColor)
                }
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.vertical, 8)
                .background(Color(hex: "#F5F5F5"))
            
            // Total
            HStack {
                Text("Total")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(defaultTextColor)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", effectiveTotal))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(defaultTextColor)
            }
            .padding(.vertical, 8)
            .background(Color(hex: "#F5F5F5"))
        }
        .sheet(isPresented: $showDiscountView) {
            AddDiscountView(
                isPresented: $showDiscountView,
                discountAmount: $discountAmount,
                discountType: $discountType
            )
        }
    }
}

// Invoice details component
struct InvoiceDetailsView: View {
    @Binding var invoiceTitle: String
    @Binding var invoiceSubtitle: String
    @Binding var issueDateOption: String
    @Binding var showIssueDateOptions: Bool
    @Binding var showIssueDatePicker: Bool
    @Binding var issueDate: Date
    let status: String
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    let inputBorderColor = Color(hex: "#D1D5DB")
    let iconColor = Color(hex: "#6B7280")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Invoice Details")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(defaultTextColor)
                
                Spacer()
                
                // Status indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(InvoiceStatus.color(for: status))
                        .frame(width: 8, height: 8)
                    
                    Text(status)
                        .font(.system(size: 14))
                        .foregroundColor(InvoiceStatus.color(for: status))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(InvoiceStatus.color(for: status).opacity(0.1))
                .cornerRadius(16)
            }
            
            // Invoice title field
            VStack(alignment: .leading, spacing: 8) {
                Text("Invoice Title")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(mutedTextColor)
                
                VStack(alignment: .leading, spacing: 0) {
                    TextField("Invoice title", text: $invoiceTitle)
                        .font(.system(size: 18))
                        .foregroundColor(defaultTextColor)
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                    
                    TextField("For Services Rendered", text: $invoiceSubtitle)
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(inputBorderColor, lineWidth: 1)
                )
            }
            
            // Issue date section
            // Issued/Date sent dropdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Issued")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(mutedTextColor)
                
                Button(action: {
                    withAnimation {
                        showIssueDateOptions.toggle()
                        if showIssueDateOptions {
                            showIssueDatePicker = false
                        }
                    }
                }) {
                    HStack {
                        Text(issueDateOption == "Custom date" ? issueDate.formattedMediumDate() : issueDateOption)
                            .font(.system(size: 18))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(iconColor)
                            .rotationEffect(showIssueDateOptions ? .degrees(180) : .degrees(0))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(inputBorderColor, lineWidth: 1)
                    )
                }
            }
        }
    }
}

// Issue date options component
struct IssueDateOptionsView: View {
    @Binding var issueDateOption: String
    @Binding var showIssueDateOptions: Bool
    @Binding var showIssueDatePicker: Bool
    let issueDateOptions: [String]
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let primaryColor = Color(hex: "#2563EB")
    let inputBorderColor = Color(hex: "#D1D5DB")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(issueDateOptions, id: \.self) { option in
                Button(action: {
                    issueDateOption = option
                    showIssueDateOptions = false
                    
                    // Show date picker if "Custom date" is selected
                    if option == "Custom date" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                showIssueDatePicker = true
                            }
                        }
                    } else {
                        showIssueDatePicker = false
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(.system(size: 16))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        if issueDateOption == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14))
                                .foregroundColor(primaryColor)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                
                if option != issueDateOptions.last {
                    Divider()
                        .padding(.horizontal, 12)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(inputBorderColor, lineWidth: 1)
        )
        .padding(.top, -8)
    }
}

// Custom date picker component
struct CustomDatePickerView: View {
    @Binding var selectedMonth: Date
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Month and navigation
            HStack {
                Text(Date.monthYearFormatter.string(from: selectedMonth))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 24) {
                    Button(action: {
                        withAnimation {
                            selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        withAnimation {
                            selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            CalendarGridView(selectedMonth: selectedMonth, selectedDate: selectedDate, onDateSelected: { date in
                selectedDate = date
            })
            
            // Confirm button
            Button(action: {
                showDatePicker = false
            }) {
                Text("Confirm")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#246BFD"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            
            // Cancel button
            Button(action: {
                showDatePicker = false
            }) {
                Text("Cancel")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#246BFD"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
        }
        .background(Color.black)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// Payment due section component
struct PaymentDueSectionView: View {
    @Binding var paymentDueOption: String
    @Binding var showPaymentDueOptions: Bool
    @Binding var showDueDatePicker: Bool
    @Binding var showCustomDueDateField: Bool
    @Binding var dueDate: Date
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    let iconColor = Color(hex: "#6B7280")
    let inputBorderColor = Color(hex: "#D1D5DB")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payment due")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(mutedTextColor)
            
            Button(action: {
                withAnimation {
                    showPaymentDueOptions.toggle()
                    if showPaymentDueOptions {
                        showDueDatePicker = false
                        showCustomDueDateField = false
                    }
                }
            }) {
                HStack {
                    Text(paymentDueOption == "Custom" ? dueDate.formattedMediumDate() : paymentDueOption)
                        .font(.system(size: 18))
                        .foregroundColor(defaultTextColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                        .rotationEffect(showPaymentDueOptions ? .degrees(180) : .degrees(0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(inputBorderColor, lineWidth: 1)
                )
            }
        }
    }
}

// Payment due options component
struct PaymentDueOptionsView: View {
    @Binding var paymentDueOption: String
    @Binding var showPaymentDueOptions: Bool
    @Binding var showCustomDueDateField: Bool
    @Binding var showDueDatePicker: Bool
    @Binding var dueDate: Date
    @Binding var issueDate: Date
    let paymentDueOptions: [String]
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let primaryColor = Color(hex: "#2563EB")
    let inputBorderColor = Color(hex: "#D1D5DB")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(paymentDueOptions, id: \.self) { option in
                Button(action: {
                    paymentDueOption = option
                    showPaymentDueOptions = false
                    
                    // Show custom date field if "Custom" is selected
                    if option == "Custom" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                showCustomDueDateField = true
                            }
                        }
                    } else {
                        showCustomDueDateField = false
                        showDueDatePicker = false
                        
                        // Set due date based on option
                        switch option {
                        case "Net 30":
                            dueDate = Calendar.current.date(byAdding: .day, value: 30, to: issueDate) ?? dueDate
                        case "Net 15":
                            dueDate = Calendar.current.date(byAdding: .day, value: 15, to: issueDate) ?? dueDate
                        case "Net 7":
                            dueDate = Calendar.current.date(byAdding: .day, value: 7, to: issueDate) ?? dueDate
                        case "Due on receipt":
                            dueDate = issueDate
                        default:
                            break
                        }
                    }
                }) {
                    HStack {
                        Text(option)
                            .font(.system(size: 16))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        if paymentDueOption == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14))
                                .foregroundColor(primaryColor)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                
                if option != paymentDueOptions.last {
                    Divider()
                        .padding(.horizontal, 12)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(inputBorderColor, lineWidth: 1)
        )
        .padding(.top, -8)
    }
}

// Custom due date field component
struct CustomDueDateFieldView: View {
    @Binding var showDueDatePicker: Bool
    
    // Colors
    let iconColor = Color(hex: "#6B7280")
    let mutedTextColor = Color(hex: "#6B7280")
    let inputBorderColor = Color(hex: "#D1D5DB")
    
    var body: some View {
        Button(action: {
            withAnimation {
                showDueDatePicker = true
            }
        }) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                Text("Custom due date")
                    .font(.system(size: 16))
                    .foregroundColor(mutedTextColor)
                
                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(inputBorderColor, lineWidth: 1)
            )
        }
    }
}

// Add Discount View
struct AddDiscountView: View {
    @Binding var isPresented: Bool
    @Binding var discountAmount: Double
    @Binding var discountType: InvoiceSummaryView.DiscountType
    
    @State private var tempDiscountAmount: String = ""
    @FocusState private var isDiscountFieldFocused: Bool
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    let backgroundColor = Color(hex: "#F5F5F5")
    let primaryColor = Color(hex: "#2563EB")
    let successColor = Color(hex: "#22C55E")
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(defaultTextColor)
                }
                
                Spacer()
                
                Text("Add discount")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(defaultTextColor)
                
                Spacer()
                
                // Empty space to balance the layout
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
            
            // Discount type selector
            HStack(spacing: 0) {
                Button(action: {
                    discountType = .percentage
                    // Clear the field when switching types
                    tempDiscountAmount = ""
                }) {
                    Text("Percent (%)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(discountType == .percentage ? defaultTextColor : mutedTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            discountType == .percentage ? 
                                Color(hex: "#F5F5F5") : Color.white
                        )
                        .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                }
                
                Button(action: {
                    discountType = .fixed
                    // Clear the field when switching types
                    tempDiscountAmount = ""
                }) {
                    Text("Fixed ($)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(discountType == .fixed ? defaultTextColor : mutedTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            discountType == .fixed ? 
                                Color(hex: "#F5F5F5") : Color.white
                        )
                        .cornerRadius(12, corners: [.topRight, .bottomRight])
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#E5E7EB"), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            
            // Discount amount field
            TextField("Discount", text: $tempDiscountAmount)
                .font(.system(size: 16))
                .keyboardType(.decimalPad)
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#E5E7EB"), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .focused($isDiscountFieldFocused)
                .onAppear {
                    // Initialize the field with current value when view appears
                    if discountAmount > 0 {
                        tempDiscountAmount = "\(discountAmount)"
                    }
                    // Auto-focus the field
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isDiscountFieldFocused = true
                    }
                }
            
            Spacer()
            
            // Save button
            Button(action: {
                // Convert and save the discount amount
                if let amount = Double(tempDiscountAmount) {
                    discountAmount = amount
                }
                isPresented = false
            }) {
                Text("Save Discount")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(successColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(backgroundColor)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    isDiscountFieldFocused = false
                }
                .foregroundColor(primaryColor)
            }
        }
    }
}

// Extension for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Helper for formatted date
extension Date {
    func formattedMediumDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: self)
    }
    
    static var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

// Add Service View
struct AddServiceView: View {
    @Binding var isPresented: Bool
    @State private var searchText = ""
    var onServiceSelected: (Service) -> Void
    
    // Selection state
    @State private var selectedServices: Set<String> = []
    @State private var showServiceDetails = false
    @State private var selectedService: Service?
    
    // Keyboard focus state
    @FocusState private var searchFieldFocused: Bool
    
    // Service list state
    @State private var serviceList: [Service] = [
        Service(name: "Free Assessment", description: "Our experts will come to assess your cleaning needs", price: 0.0),
        Service(name: "Professional Deep Cleaning", description: "Comprehensive cleaning that covers all areas", price: 0.0),
        Service(name: "Window Cleaning", description: "Cleaning of all windows inside and outside", price: 0.0),
        Service(name: "Carpet Cleaning", description: "Professional carpet cleaning using steam extraction", price: 0.0)
    ]
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    let backgroundColor = Color(hex: "#F5F5F5")
    let inputBorderColor = Color(hex: "#D1D5DB")
    let primaryColor = Color(hex: "#2563EB")
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(defaultTextColor)
                }
                
                Spacer()
                
                Text("Add new service")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(defaultTextColor)
                
                Spacer()
                
                Button(action: {
                    // Add custom service with empty fields
                    let newService = Service(name: "", description: "", price: 0.0)
                    selectedService = newService
                    showServiceDetails = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18))
                        .foregroundColor(primaryColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(mutedTextColor)
                    .padding(.leading, 12)
                
                TextField("Search line items", text: $searchText)
                    .font(.system(size: 16))
                    .padding(.vertical, 12)
                    .focused($searchFieldFocused)
            }
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(inputBorderColor, lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Selection count and deselect button
            if !selectedServices.isEmpty {
                HStack {
                    Text("\(selectedServices.count) selected")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(defaultTextColor)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedServices.removeAll()
                    }) {
                        Text("Deselect All")
                            .font(.system(size: 16))
                            .foregroundColor(primaryColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            
            Divider()
            
            // Service list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredServices, id: \.name) { service in
                        Button(action: {
                            toggleSelection(service)
                        }) {
                            HStack {
                                if selectedServices.contains(service.name) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(primaryColor)
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .padding(.trailing, 8)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(service.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(defaultTextColor)
                                    
                                    Text(service.description)
                                        .font(.system(size: 14))
                                        .foregroundColor(mutedTextColor)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", service.price))")
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(selectedServices.contains(service.name) ? Color(hex: "#EBF5FF").opacity(0.3) : Color.white)
                        }
                        
                        Divider()
                    }
                }
            }
            
            // Add to Invoice button
            if !selectedServices.isEmpty {
                Button(action: {
                    if selectedServices.count == 1, let firstSelected = serviceList.first(where: { selectedServices.contains($0.name) }) {
                        // If only one service is selected, show service details
                        selectedService = firstSelected
                        showServiceDetails = true
                    } else {
                        // If multiple services are selected, add them directly to invoice and dismiss
                        for serviceName in selectedServices {
                            if let service = serviceList.first(where: { $0.name == serviceName }) {
                                onServiceSelected(service)
                            }
                        }
                        isPresented = false
                    }
                }) {
                    Text("Add to Invoice")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(primaryColor)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .background(backgroundColor)
        .sheet(isPresented: $showServiceDetails) {
            if let service = selectedService {
                ServiceDetailsView(isPresented: $showServiceDetails, service: service, onSave: { updatedService in
                    // Add the service to the list if it's new
                    if !serviceList.contains(where: { $0.name == updatedService.name }) && !updatedService.name.isEmpty {
                        serviceList.append(updatedService)
                    }
                    onServiceSelected(updatedService)
                    isPresented = false
                })
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    searchFieldFocused = false
                }
                .foregroundColor(primaryColor)
            }
        }
    }
    
    var filteredServices: [Service] {
        if searchText.isEmpty {
            return serviceList
        } else {
            return serviceList.filter { $0.name.lowercased().contains(searchText.lowercased()) || 
                                   $0.description.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private func toggleSelection(_ service: Service) {
        if selectedServices.contains(service.name) {
            selectedServices.remove(service.name)
        } else {
            selectedServices.insert(service.name)
        }
    }
}

// Service Details View
struct ServiceDetailsView: View {
    @Binding var isPresented: Bool
    @State var service: Service
    var onSave: (Service) -> Void
    
    @State private var name: String
    @State private var description: String
    @State private var price: Double
    @State private var quantity: Int = 1
    @State private var serviceDate: Date = Date()
    @State private var showDatePicker = false
    
    // Keyboard focus state
    @FocusState private var focusedField: Field?
    
    // Focus fields enum
    enum Field: Hashable {
        case name
        case description
        case price
        case quantity
    }
    
    // Colors
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    let backgroundColor = Color(hex: "#F5F5F5")
    let inputBorderColor = Color(hex: "#D1D5DB")
    let primaryColor = Color(hex: "#2563EB")
    let placeholderColor = Color(hex: "#9CA3AF")
    
    init(isPresented: Binding<Bool>, service: Service, onSave: @escaping (Service) -> Void) {
        self._isPresented = isPresented
        self.service = service
        self.onSave = onSave
        self._name = State(initialValue: service.name)
        self._description = State(initialValue: service.description)
        self._price = State(initialValue: service.price)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(defaultTextColor)
                }
                
                Spacer()
                
                Text("Service Details")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(defaultTextColor)
                
                Spacer()
                
                // Empty space to balance the layout
                Image(systemName: "xmark")
                    .font(.system(size: 18))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 16))
                            .foregroundColor(mutedTextColor)
                        
                        TextField("Enter service name", text: $name)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputBorderColor, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .name)
                    }
                    
                    // Description field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 16))
                            .foregroundColor(mutedTextColor)
                        
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Enter service description")
                                    .font(.system(size: 16))
                                    .foregroundColor(placeholderColor)
                                    .padding(.top, 12)
                                    .padding(.leading, 12)
                            }
                            
                            TextEditor(text: $description)
                                .font(.system(size: 16))
                                .padding(12)
                                .frame(height: 120)
                                .background(Color.white)
                                .opacity(description.isEmpty ? 0.25 : 1)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .description)
                    }
                    
                    // Unit Price field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unit Price")
                            .font(.system(size: 16))
                            .foregroundColor(mutedTextColor)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 16))
                                .foregroundColor(defaultTextColor)
                                .padding(.leading, 16)
                            
                            let priceFormatter: NumberFormatter = {
                                let formatter = NumberFormatter()
                                formatter.numberStyle = .decimal
                                formatter.minimumFractionDigits = 2
                                formatter.maximumFractionDigits = 2
                                return formatter
                            }()
                            
                            TextField("0.00", value: $price, formatter: priceFormatter)
                                .font(.system(size: 16))
                                .keyboardType(.decimalPad)
                                .padding(.vertical, 16)
                                .focused($focusedField, equals: .price)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                    }
                    
                    // Quantity field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.system(size: 16))
                            .foregroundColor(mutedTextColor)
                        
                        TextField("Enter quantity", value: $quantity, formatter: NumberFormatter())
                            .font(.system(size: 16))
                            .keyboardType(.numberPad)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputBorderColor, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .quantity)
                    }
                    
                    // Service Date field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Service date")
                            .font(.system(size: 16))
                            .foregroundColor(mutedTextColor)
                        
                        Button(action: {
                            showDatePicker = true
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(mutedTextColor)
                                    .padding(.trailing, 8)
                                
                                Text(serviceDate.formattedMediumDate())
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputBorderColor, lineWidth: 1)
                            )
                        }
                    }
                    
                    // Total section
                    HStack {
                        Text("Total")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        let totalFormatter: NumberFormatter = {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .currency
                            formatter.currencySymbol = "$"
                            formatter.minimumFractionDigits = 2
                            formatter.maximumFractionDigits = 2
                            return formatter
                        }()
                        
                        Text(totalFormatter.string(from: NSNumber(value: price * Double(quantity))) ?? "$0.00")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                    }
                    .padding(16)
                    .background(Color(hex: "#F9F9F9"))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            // Save button
            Button(action: {
                let updatedService = Service(
                    name: name,
                    description: description,
                    price: price,
                    quantity: quantity,
                    serviceDate: serviceDate
                )
                onSave(updatedService)
            }) {
                Text("Save Service")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(primaryColor)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(backgroundColor)
        .sheet(isPresented: $showDatePicker) {
            DatePickerView(selectedDate: $serviceDate, isPresented: $showDatePicker)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    focusedField = nil
                }
                .foregroundColor(primaryColor)
            }
        }
    }
}

// Date Picker View
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select a date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationBarTitle("Select Date", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

// Updated Service model
struct Service {
    let name: String
    let description: String
    let price: Double
    var quantity: Int = 1
    var serviceDate: Date? = nil
}

#Preview {
    NewInvoiceView()
} 
