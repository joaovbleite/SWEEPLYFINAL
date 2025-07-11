//
//  NewQuoteView.swift
//  SWEEPLYPRO
//
//  Created on 7/10/25.
//

import SwiftUI
import UIKit


struct NewQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSelectClient = false
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var propertyAddress = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var state = "Select..."
    @State private var zipCode = ""
    @State private var country = "United States"
    @State private var showPhoneField = false
    @State private var showEmailField = false
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var showAddressFields = false
    @State private var selectedSalesperson = "Joao"
    @State private var showSalespersonPicker = false
    @State private var items: [QuoteItem] = [
        QuoteItem(description: "House Cleaning", quantity: 1, rate: 150.00),
        QuoteItem(description: "Window Cleaning", quantity: 2, rate: 75.00)
    ]
    @State private var showAddServiceView = false
    
    // Colors following the app's brand colors
    private let primaryColor = Color(hex: "#246BFD") // Blue
    private let iconColor = Color(hex: "#5E7380") // Grey
    private let backgroundColor = Color(hex: "#F5F5F5") // Light background
    private let textColor = Color(hex: "#1A1A1A")
    private let mutedTextColor = Color(hex: "#5E7380")
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case firstName, lastName, propertyAddress, addressLine2, city, zipCode, phone, email, itemDescription(Int), itemQuantity(Int), itemRate(Int)
    }
    
    // US States for dropdown
    let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    // Countries for dropdown
    let countries = ["United States", "Canada", "Mexico", "United Kingdom", "Australia", "Germany", "France", "Japan", "China", "Brazil", "India"]
    
    // Salespeople
    let salespeople = ["Joao", "Sarah", "Michael", "Emma", "David"]
    
    // Calculate total amount
    var totalAmount: Double {
        return items.reduce(0) { $0 + $1.amount }
    }
    
    // Function to dismiss the keyboard
    private func dismissKeyboard() {
        // Set focus to nil to dismiss the keyboard
        focusedField = nil
        
        // Additionally use UIKit to ensure keyboard dismissal
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Service for section
                        serviceForSection
                        
                        // Client selection button
                        selectClientButton
                        
                        // Client info fields
                        clientInfoSection
                        
                        // Property address field
                        propertyAddressSection
                        
                        // Optional fields section
                        optionalFieldsSection
                        
                        // Line items section
                        lineItemsSection
                        
                        // Pricing section
                        QuoteSummaryView(totalAmount: totalAmount)
                        
                        // Bottom spacing for scrolling
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                }
                .background(backgroundColor)
            }
            .background(backgroundColor)
            .sheet(isPresented: $showSelectClient) {
                // Placeholder for client selection view
                Text("Select Client View")
                    .font(.largeTitle)
                    .padding()
            }
            .sheet(isPresented: $showSalespersonPicker) {
                SalespersonPickerView(selectedSalesperson: $selectedSalesperson, salespeople: salespeople)
            }
            .sheet(isPresented: $showAddServiceView) {
                // Placeholder for add service view
                Text("Add Service View")
                    .font(.largeTitle)
                    .padding()
            }
            .toolbar {
                // Add "Done" button above keyboard
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#1A1A1A"))
            }
            
            Spacer()
            
            Text("New quote")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1A"))
            
            Spacer()
            
            // Invisible button for balance
            Button(action: {}) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.clear)
            }
            .disabled(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Service For Section
    private var serviceForSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service for")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "#5E7380"))
                .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Select Client Button
    private var selectClientButton: some View {
        Button(action: {
            showSelectClient = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(primaryColor)
                
                Text("Select Existing Client")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(primaryColor)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Client Info Section
    private var clientInfoSection: some View {
        VStack(spacing: 16) {
            // First name field
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "person")
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                        .frame(width: 20)
                    
                    TextField("First name", text: $firstName)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .focused($focusedField, equals: .firstName)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .firstName ? primaryColor : Color(hex: "#E5E5E5"), lineWidth: 1)
                )
            }
            
            // Last name field
            VStack(alignment: .leading, spacing: 8) {
                TextField("Last name", text: $lastName)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                    .focused($focusedField, equals: .lastName)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .lastName ? primaryColor : Color(hex: "#E5E5E5"), lineWidth: 1)
                    )
            }
        }
    }
    
    // MARK: - Property Address Section
    private var propertyAddressSection: some View {
        VStack(spacing: 16) {
            // Section title
            HStack {
                Text("Property Address")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#5E7380"))
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // Street address field
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "location")
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                        .frame(width: 20)
                    
                    TextField("Street address", text: $propertyAddress)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .focused($focusedField, equals: .propertyAddress)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .propertyAddress ? primaryColor : Color(hex: "#E5E5E5"), lineWidth: 1)
                )
                .makeTappable {
                    withAnimation {
                        showAddressFields = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focusedField = .propertyAddress
                    }
                }
            }
            
            if showAddressFields {
                // Address line 2 field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Address line 2 (optional)", text: $addressLine2)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .focused($focusedField, equals: .addressLine2)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .addressLine2 ? primaryColor : Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                }
                
                // City field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("City", text: $city)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .focused($focusedField, equals: .city)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .city ? primaryColor : Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                }
                
                // State dropdown
                VStack(alignment: .leading, spacing: 8) {
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
                                .foregroundColor(state == "Select..." ? Color(hex: "#9CA3AF") : Color(hex: "#1A1A1A"))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                    }
                }
                
                // Zip code field
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Zip code", text: $zipCode)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .focused($focusedField, equals: .zipCode)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .zipCode ? primaryColor : Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                }
                
                // Country dropdown
                VStack(alignment: .leading, spacing: 8) {
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
                                .foregroundColor(Color(hex: "#1A1A1A"))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Optional Fields Section
    private var optionalFieldsSection: some View {
        VStack(spacing: 16) {
            // Phone number section
            VStack(spacing: 16) {
                if !showPhoneField {
                    // Add phone button
                    Button(action: {
                        showPhoneField = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusedField = .phone
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(primaryColor)
                            
                            Text("Add phone number")
                                .font(.system(size: 16))
                                .foregroundColor(primaryColor)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                } else {
                    // Phone number field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "phone")
                                .font(.system(size: 16))
                                .foregroundColor(iconColor)
                                .frame(width: 20)
                            
                            TextField("Phone number", text: $phoneNumber)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#1A1A1A"))
                                .keyboardType(.phonePad)
                                .focused($focusedField, equals: .phone)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .phone ? primaryColor : Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                    }
                }
            }
            
            // Email section
            VStack(spacing: 16) {
                if !showEmailField {
                    // Add email button
                    Button(action: {
                        showEmailField = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusedField = .email
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(primaryColor)
                            
                            Text("Add email")
                                .font(.system(size: 16))
                                .foregroundColor(primaryColor)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                } else {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 16))
                                .foregroundColor(iconColor)
                                .frame(width: 20)
                            
                            TextField("Email", text: $email)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#1A1A1A"))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($focusedField, equals: .email)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .email ? primaryColor : Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                    }
                }
            }
            
            // Salesperson section
            VStack(alignment: .leading, spacing: 8) {
                Text("Salesperson")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#5E7380"))
                    .padding(.horizontal, 4)
                
                Button(action: {
                    showSalespersonPicker = true
                    dismissKeyboard()
                }) {
                    HStack {
                        Text(selectedSalesperson)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#5E7380"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Line Items Section
    private var lineItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Product / Service")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(mutedTextColor)
                
                Spacer()
            }
            
            // List of line items
            ForEach(items.indices, id: \.self) { index in
                lineItemRow(for: index)
            }
            
            // Add line item button
            Button(action: {
                showAddServiceView = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(primaryColor)
                    
                    Text("Add line item")
                        .font(.system(size: 16))
                        .foregroundColor(primaryColor)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                )
            }
        }
    }
    
    // Line item row
    private func lineItemRow(for index: Int) -> some View {
        VStack(spacing: 12) {
            // Description field
            TextField("Description", text: $items[index].description)
                .font(.system(size: 16))
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                )
                .focused($focusedField, equals: .itemDescription(index))
            
            HStack(spacing: 12) {
                // Quantity field
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quantity")
                        .font(.system(size: 12))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("0", value: $items[index].quantity, formatter: NumberFormatter())
                        .font(.system(size: 16))
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                        )
                        .focused($focusedField, equals: .itemQuantity(index))
                }
                .frame(width: 80)
                
                // Rate field
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rate")
                        .font(.system(size: 12))
                        .foregroundColor(mutedTextColor)
                    
                    HStack(spacing: 4) {
                        Text("$")
                            .font(.system(size: 16))
                            .foregroundColor(mutedTextColor)
                        
                        TextField("0.00", value: $items[index].rate, formatter: NumberFormatter())
                            .font(.system(size: 16))
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .itemRate(index))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                    )
                }
                
                Spacer()
                
                // Amount
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Amount")
                        .font(.system(size: 12))
                        .foregroundColor(mutedTextColor)
                    
                    Text("$\(String(format: "%.2f", items[index].amount))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                }
            }
            
            // Delete button
            Button(action: {
                items.remove(at: index)
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#F44336"))
                    
                    Text("Remove")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#F44336"))
                }
            }
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Quote Item Model
struct QuoteItem: Identifiable {
    let id = UUID()
    var description: String = ""
    var quantity: Int = 1
    var rate: Double = 0.0
    
    var amount: Double {
        return Double(quantity) * rate
    }
}

// MARK: - Quote Summary View
struct QuoteSummaryView: View {
    let totalAmount: Double
    @State private var showDiscountView = false
    @State private var discountAmount: Double = 0.0
    @State private var discountType: DiscountType = .fixed
    @State private var taxRate: Double = 0.0
    @State private var depositPercentage: Double = 0.0
    
    // Colors
    private let primaryColor = Color(hex: "#246BFD")
    private let textColor = Color(hex: "#1A1A1A")
    private let mutedTextColor = Color(hex: "#5E7380")
    private let backgroundColor = Color(hex: "#F5F5F5")
    private let borderColor = Color(hex: "#E5E5E5")
    
    enum DiscountType {
        case percentage
        case fixed
    }
    
    var formattedDiscount: String {
        if discountAmount == 0 {
            return "$0.00"
        } else if discountType == .percentage {
            return "\(Int(discountAmount))% ($\(String(format: "%.2f", calculateDiscountValue())))"
        } else {
            return "$\(String(format: "%.2f", discountAmount))"
        }
    }
    
    var subtotalAfterDiscount: Double {
        return totalAmount - calculateDiscountValue()
    }
    
    var taxAmount: Double {
        return subtotalAfterDiscount * (taxRate / 100.0)
    }
    
    var finalTotal: Double {
        return subtotalAfterDiscount + taxAmount
    }
    
    var depositAmount: Double {
        return finalTotal * (depositPercentage / 100.0)
    }
    
    func calculateDiscountValue() -> Double {
        if discountType == .percentage {
            return totalAmount * (discountAmount / 100.0)
        } else {
            return min(discountAmount, totalAmount) // Can't discount more than total
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Line items header
            HStack {
                Text("Line items")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(primaryColor)
            }
            .padding(.bottom, 16)
            
            // Gray divider
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 8)
                .padding(.horizontal, -16)
            
            // Subtotal
            HStack {
                Text("Subtotal")
                    .font(.system(size: 16))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", totalAmount))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
            }
            .padding(.vertical, 16)
            
            // Discount
            HStack {
                Button(action: {
                    showDiscountView = true
                }) {
                    HStack(spacing: 4) {
                        Text("Discount")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                        
                        if discountAmount == 0 {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 14))
                                .foregroundColor(primaryColor)
                        }
                    }
                }
                
                Spacer()
                
                Text(formattedDiscount)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
            }
            .padding(.vertical, 16)
            
            // Tax
            HStack {
                Button(action: {
                    // Show tax input
                }) {
                    HStack(spacing: 4) {
                        Text("Tax")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                        
                        if taxRate == 0 {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 14))
                                .foregroundColor(primaryColor)
                        }
                    }
                }
                
                Spacer()
                
                if taxRate > 0 {
                    Text("\(Int(taxRate))% ($\(String(format: "%.2f", taxAmount)))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                } else {
                    Text("$0.00")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                }
            }
            .padding(.vertical, 16)
            
            // Gray background for total
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 8)
                .padding(.horizontal, -16)
            
            // Total
            HStack {
                Text("Total")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", finalTotal))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
            }
            .padding(.vertical, 16)
            
            // Gray background for deposit
            Rectangle()
                .fill(backgroundColor)
                .frame(height: 8)
                .padding(.horizontal, -16)
            
            // Required deposit
            HStack {
                Button(action: {
                    // Show deposit input
                }) {
                    HStack(spacing: 4) {
                        Text("Required deposit")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                        
                        if depositPercentage == 0 {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 14))
                                .foregroundColor(primaryColor)
                        }
                    }
                }
                
                Spacer()
                
                if depositPercentage > 0 {
                    Text("\(Int(depositPercentage))% ($\(String(format: "%.2f", depositAmount)))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#4CAF50")) // Green color for deposit
                } else {
                    Text("$0.00")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                }
            }
            .padding(.vertical, 16)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showDiscountView) {
            AddDiscountView(
                isPresented: $showDiscountView,
                discountAmount: $discountAmount,
                discountType: $discountType
            )
        }
    }
}

// MARK: - Add Discount View
struct AddDiscountView: View {
    @Binding var isPresented: Bool
    @Binding var discountAmount: Double
    @Binding var discountType: QuoteSummaryView.DiscountType
    
    @State private var tempDiscountAmount: String = ""
    @FocusState private var isDiscountFieldFocused: Bool
    
    // Colors
    private let primaryColor = Color(hex: "#246BFD")
    private let textColor = Color(hex: "#1A1A1A")
    private let mutedTextColor = Color(hex: "#5E7380")
    private let backgroundColor = Color(hex: "#F5F5F5")
    private let defaultTextColor = Color(hex: "#1A1A1A")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header text
                VStack(spacing: 8) {
                    Text("Add discount")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(textColor)
                    
                    Text("Add a discount as a percentage or fixed amount")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                // Discount type selector
                HStack(spacing: 16) {
                    // Percentage option
                    Button(action: {
                        discountType = .percentage
                        // Clear the field when switching types
                        tempDiscountAmount = ""
                    }) {
                        Text("Percentage")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(discountType == .percentage ? defaultTextColor : mutedTextColor)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                discountType == .percentage ?
                                RoundedRectangle(cornerRadius: 8).fill(Color.white) :
                                RoundedRectangle(cornerRadius: 8).fill(Color.clear)
                            )
                    }
                    
                    // Fixed amount option
                    Button(action: {
                        discountType = .fixed
                        // Clear the field when switching types
                        tempDiscountAmount = ""
                    }) {
                        Text("Fixed Amount")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(discountType == .fixed ? defaultTextColor : mutedTextColor)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                discountType == .fixed ?
                                RoundedRectangle(cornerRadius: 8).fill(Color.white) :
                                RoundedRectangle(cornerRadius: 8).fill(Color.clear)
                            )
                    }
                }
                .padding(4)
                .background(backgroundColor)
                .cornerRadius(12)
                
                // Discount amount field
                HStack {
                    if discountType == .percentage {
                        TextField("Percentage", text: $tempDiscountAmount)
                            .font(.system(size: 16))
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                            )
                            .focused($isDiscountFieldFocused)
                        
                        Text("%")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                            .padding(.leading, 8)
                    } else {
                        Text("$")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                            .padding(.trailing, 8)
                        
                        TextField("Amount", text: $tempDiscountAmount)
                            .font(.system(size: 16))
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                            )
                            .focused($isDiscountFieldFocused)
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(primaryColor)
                        .cornerRadius(12)
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(textColor)
                }
            )
            .onAppear {
                // Set the initial value if there's already a discount
                if discountAmount > 0 {
                    tempDiscountAmount = "\(discountAmount)"
                }
                
                // Focus the field automatically
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isDiscountFieldFocused = true
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NewQuoteView()
} 

// MARK: - Salesperson Picker View
struct SalespersonPickerView: View {
    @Binding var selectedSalesperson: String
    let salespeople: [String]
    @Environment(\.dismiss) private var dismiss
    
    // Colors
    private let primaryColor = Color(hex: "#246BFD")
    private let textColor = Color(hex: "#1A1A1A")
    private let mutedTextColor = Color(hex: "#5E7380")
    private let backgroundColor = Color(hex: "#F5F5F5")
    
    var body: some View {
        NavigationView {
            List {
                ForEach(salespeople, id: \.self) { person in
                    Button(action: {
                        selectedSalesperson = person
                        dismiss()
                    }) {
                        HStack {
                            Text(person)
                                .font(.system(size: 16))
                                .foregroundColor(textColor)
                            
                            Spacer()
                            
                            if selectedSalesperson == person {
                                Image(systemName: "checkmark")
                                    .foregroundColor(primaryColor)
                            }
                        }
                    }
                    .listRowBackground(Color.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Select Salesperson")
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(primaryColor)
                }
            )
            .background(backgroundColor)
            .listStyle(PlainListStyle())
        }
    }
} 