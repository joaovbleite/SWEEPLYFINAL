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
    @State private var items: [InvoiceItem] = [
        InvoiceItem(description: "", quantity: 1, rate: 0.0)
    ]
    @State private var notes = ""
    @State private var showClientFields = false
    @State private var showIssueDateOptions = false
    @State private var showPaymentDueOptions = false
    @State private var showIssueDatePicker = false
    @State private var showDueDatePicker = false
    @State private var selectedMonth = Date()
    @State private var showCustomDueDateField = false
    
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
            ScrollView {
                VStack(spacing: 24) {
                    // Header with back button and title
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
                    .padding(.bottom, 8)
                    
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
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                                
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
                                            .foregroundColor(Color(hex: "#4CAF50"))
                                        
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
                                            .foregroundColor(Color(hex: "#4CAF50"))
                                        
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
                        }
                    }
                    
                    // Invoice details
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
                                    Text(issueDateOption == "Custom date" ? formattedDate(issueDate) : issueDateOption)
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
                            
                            if showIssueDateOptions {
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
                            
                            // Custom Date Picker
                            if issueDateOption == "Custom date" && showIssueDatePicker {
                                VStack(spacing: 0) {
                                    // Month and navigation
                                    HStack {
                                        Text(monthYearFormatter.string(from: selectedMonth))
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
                                                    issueDate = date
                                                }) {
                                                    Text("\(Calendar.current.component(.day, from: date))")
                                                        .font(.system(size: 18, weight: .medium))
                                                        .foregroundColor(Calendar.current.isDate(date, inSameDayAs: issueDate) ? .white : .white)
                                                        .frame(width: 40, height: 40)
                                                        .background(
                                                            Circle()
                                                                .fill(Calendar.current.isDate(date, inSameDayAs: issueDate) ? Color(hex: "#246BFD") : Color.clear)
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
                                    
                                    // Confirm button
                                    Button(action: {
                                        showIssueDatePicker = false
                                    }) {
                                        Text("Confirm")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(Color(hex: "#246BFD"))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                    }
                                    
                                    // Cancel button
                                    Button(action: {
                                        showIssueDatePicker = false
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
                    }
                    
                    // Payment due section
                    // Payment due dropdown
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
                                Text(paymentDueOption == "Custom" ? formattedDate(dueDate) : paymentDueOption)
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
                        
                        if showPaymentDueOptions {
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
                        
                        // Custom Due Date Field
                        if paymentDueOption == "Custom" && showCustomDueDateField {
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
                        
                        // Custom Due Date Picker
                        if paymentDueOption == "Custom" && showDueDatePicker {
                            VStack(spacing: 0) {
                                // Month and navigation
                                HStack {
                                    Text(monthYearFormatter.string(from: selectedMonth))
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
                                                dueDate = date
                                            }) {
                                                Text("\(Calendar.current.component(.day, from: date))")
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(Calendar.current.isDate(date, inSameDayAs: dueDate) ? .white : .white)
                                                    .frame(width: 40, height: 40)
                                                    .background(
                                                        Circle()
                                                            .fill(Calendar.current.isDate(date, inSameDayAs: dueDate) ? Color(hex: "#246BFD") : Color.clear)
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
                                
                                // Confirm button
                                Button(action: {
                                    showDueDatePicker = false
                                }) {
                                    Text("Confirm")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(hex: "#246BFD"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                }
                                
                                // Cancel button
                                Button(action: {
                                    showDueDatePicker = false
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
                }
                
                // Line items
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Product / Service")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Line items")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        Button(action: {
                            items.append(InvoiceItem(description: "", quantity: 1, rate: 0.0))
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#4CAF50"))
                                .padding(8)
                        }
                    }
                    
                    // Line items
                    ForEach(0..<items.count, id: \.self) { index in
                        VStack(spacing: 0) {
                            HStack(spacing: 8) {
                                TextField("", text: $items[index].description)
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                    .focused($focusedField, equals: .itemDescription(index))
                                    .placeholderText(when: items[index].description.isEmpty) {
                                        Text("Item description")
                                            .foregroundColor(placeholderColor)
                                    }
                                
                                TextField("", value: $items[index].quantity, formatter: NumberFormatter())
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                    .focused($focusedField, equals: .itemQuantity(index))
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .placeholderText(when: items[index].quantity == 0) {
                                        Text("0")
                                            .foregroundColor(placeholderColor)
                                            .multilineTextAlignment(.center)
                                    }
                                
                                HStack(spacing: 0) {
                                    Text("$")
                                        .font(.system(size: 16))
                                        .foregroundColor(mutedTextColor)
                                    
                                    TextField("", value: Binding(
                                        get: { self.items[index].rate },
                                        set: { self.items[index].rate = $0 }
                                    ), formatter: NumberFormatter())
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 60)
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .itemRate(index))
                                }
                                .frame(width: 70)
                                
                                Text("$\(items[index].amount, specifier: "%.2f")")
                                    .font(.system(size: 16))
                                    .foregroundColor(defaultTextColor)
                                    .frame(width: 70, alignment: .trailing)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputBorderColor, lineWidth: 1)
                            )
                            
                            if index < items.count - 1 {
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Subtotal
                    HStack {
                        Text("Subtotal")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        Text("$\(totalAmount, specifier: "%.2f")")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                    }
                    .padding(.vertical, 8)
                    
                    // Discount
                    HStack {
                        Text("Discount")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        Text("$0.00")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "#4CAF50"))
                    }
                    .padding(.vertical, 8)
                    
                    // Tax
                    HStack {
                        Text("Tax")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        Text("$0.00")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "#4CAF50"))
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                        .padding(.vertical, 8)
                        .background(Color(hex: "#F5F5F5"))
                    
                    // Total
                    HStack {
                        Text("Total")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        Text("$\(totalAmount, specifier: "%.2f")")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                    }
                    .padding(.vertical, 8)
                    .background(Color(hex: "#F5F5F5"))
                    
                    Divider()
                        .padding(.vertical, 16)
                    
                    // Client message
                    HStack {
                        Text("Client message")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(defaultTextColor)
                        
                        Spacer()
                        
                        Button(action: {
                            // Add client message action
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#4CAF50"))
                                .padding(8)
                        }
                    }
                }
                
                // Save button
                Button(action: {
                    // Save invoice action
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
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 32)
            // Add tap gesture to dismiss keyboard
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
        }
        .background(backgroundColor)
        .navigationTitle("New Invoice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("New Invoice")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
            }
            
            // Add keyboard toolbar with done button
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    // Helper for formatted date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    // Month and year formatter
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
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

#Preview {
    NewInvoiceView()
} 