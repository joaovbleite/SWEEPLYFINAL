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
    
    // Colors following the app's brand colors
    private let primaryColor = Color(hex: "#246BFD") // Blue
    private let iconColor = Color(hex: "#5E7380") // Grey
    private let backgroundColor = Color(hex: "#F5F5F5") // Light background
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, propertyAddress, addressLine2, city, zipCode, phone, email
    }
    
    // US States for dropdown
    let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    // Countries for dropdown
    let countries = ["United States", "Canada", "Mexico", "United Kingdom", "Australia", "Germany", "France", "Japan", "China", "Brazil", "India"]
    
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
                        HStack(spacing: 12) {
                            Image(systemName: "phone")
                                .font(.system(size: 16))
                                .foregroundColor(iconColor)
                                .frame(width: 20)
                            
                            Text("Add Phone Number")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(primaryColor)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                } else {
                    // Phone number field
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
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 16))
                                .foregroundColor(iconColor)
                                .frame(width: 20)
                            
                            Text("Add Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(primaryColor)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                } else {
                    // Email field
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .font(.system(size: 16))
                            .foregroundColor(iconColor)
                            .frame(width: 20)
                        
                        TextField("Email address", text: $email)
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
    }
}

#Preview {
    NewQuoteView()
} 