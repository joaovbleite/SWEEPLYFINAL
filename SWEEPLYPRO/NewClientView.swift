//
//  NewClientView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import SwiftData
import UIKit
import Contacts
import ContactsUI

// Focus state enum for keyboard focus
enum FocusField: Hashable {
    case companyName
    case phoneNumber
    case email
    case leadSource
    case propertyAddress
    case addressLine2
    case city
    case zipCode
    case billingAddress
    case billingAddressLine2
    case billingCity
    case billingZipCode
}

struct NewClientView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @State private var showSavedAlert = false
    @FocusState private var focusedField: FocusField?
    
    // Form fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var companyName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var leadSource = ""
    @State private var propertyAddress = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var state = "Select..."
    @State private var zipCode = ""
    @State private var country = "United States"
    @State private var billingAddressMatchesProperty = true
    
    // Billing address fields
    @State private var billingAddress = ""
    @State private var billingAddressLine2 = ""
    @State private var billingCity = ""
    @State private var billingState = "Select..."
    @State private var billingZipCode = ""
    @State private var billingCountry = "United States"
    
    // Toggle states for showing fields
    @State private var showCompanyField = false
    @State private var showPhoneField = false
    @State private var showEmailField = false
    @State private var showLeadSourceField = false
    @State private var showAddressFields = false
    @State private var showContactPicker = false
    @State private var showContactsAlert = false
    @State private var contactsAlertMessage = ""
    
    // Phone label options
    @State private var phoneLabel = "Main"
    @State private var receivesTextMessages = false
    
    // Colors from design system
    let primaryColor = Color(hex: "#2563EB")
    let successColor = Color(hex: "#34D399")
    let inputBorderColor = Color(hex: "#D1D5DB")
    let placeholderColor = Color(hex: "#9CA3AF")
    let iconColor = Color(hex: "#6B7280")
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    
    // US States for dropdown
    let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    // Countries for dropdown
    let countries = ["United States", "Canada", "Mexico", "United Kingdom", "Australia", "Germany", "France", "Japan", "China", "Brazil", "India"]
    
    // Check if any content has been added
    private var hasContent: Bool {
        return !firstName.isEmpty || 
               !lastName.isEmpty || 
               !companyName.isEmpty || 
               !phoneNumber.isEmpty || 
               !email.isEmpty || 
               !leadSource.isEmpty || 
               !propertyAddress.isEmpty ||
               showCompanyField ||
               showPhoneField ||
               showEmailField ||
               showLeadSourceField ||
               showAddressFields
    }
    
    // Check if the form is valid for saving
    private var isFormValid: Bool {
        return !firstName.isEmpty || !lastName.isEmpty || !companyName.isEmpty
    }
    
    // Function to save the client
    private func saveClient() {
        guard isFormValid else {
            // Show validation error
            return
        }
        
        // Format the full address
        var fullAddress = propertyAddress
        if !addressLine2.isEmpty {
            fullAddress += "\n\(addressLine2)"
        }
        if !city.isEmpty {
            fullAddress += "\n\(city)"
        }
        if state != "Select..." {
            fullAddress += ", \(state)"
        }
        if !zipCode.isEmpty {
            fullAddress += " \(zipCode)"
        }
        if country != "United States" {
            fullAddress += "\n\(country)"
        }
        
        // Format the billing address if different from property address
        var fullBillingAddress = ""
        if !billingAddressMatchesProperty {
            fullBillingAddress = billingAddress
            if !billingAddressLine2.isEmpty {
                fullBillingAddress += "\n\(billingAddressLine2)"
            }
            if !billingCity.isEmpty {
                fullBillingAddress += "\n\(billingCity)"
            }
            if billingState != "Select..." {
                fullBillingAddress += ", \(billingState)"
            }
            if !billingZipCode.isEmpty {
                fullBillingAddress += " \(billingZipCode)"
            }
            if billingCountry != "United States" {
                fullBillingAddress += "\n\(billingCountry)"
            }
        }
        
        // Create a new client
        let client = Client(
            firstName: firstName,
            lastName: lastName,
            companyName: companyName,
            phoneNumber: phoneNumber,
            phoneLabel: phoneLabel,
            receivesTextMessages: receivesTextMessages,
            email: email,
            leadSource: leadSource,
            propertyAddress: fullAddress,
            billingAddress: billingAddressMatchesProperty ? fullAddress : fullBillingAddress
        )
        
        // Save to SwiftData
        modelContext.insert(client)
        
        // Show saved confirmation
        showSavedAlert = true
        
        // Dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // Function to dismiss the keyboard
    private func dismissKeyboard() {
        // Set focus to nil to dismiss the keyboard
        focusedField = nil
        
        // Additionally use UIKit to ensure keyboard dismissal
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Function to request contacts access and show picker
    private func requestContactsAccess() {
        let contactStore = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            // Already authorized, show picker
            DispatchQueue.main.async {
                self.showContactPicker = true
            }
        case .denied, .restricted:
            // Alert the user that they need to enable access in Settings
            contactsAlertMessage = "Sweeply needs access to your contacts to import client information. Please enable access in Settings."
            showContactsAlert = true
        case .notDetermined:
            // Request access
            contactStore.requestAccess(for: .contacts) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        self.showContactPicker = true
                    } else {
                        self.contactsAlertMessage = "Contacts access was denied. To import contacts, please enable access in Settings."
                        self.showContactsAlert = true
                    }
                }
            }
        case .limited:
            // Handle limited access (show picker with limited contacts)
            DispatchQueue.main.async {
                self.showContactPicker = true
            }
        @unknown default:
            break
        }
    }
    
    // Function to open app settings
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with back button and title - similar to NewTaskView
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(primaryColor)
                    }
                    
                    Spacer()
                    
                    Text("New Client")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(defaultTextColor)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        if isFormValid {
                            saveClient()
                        }
                    }) {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isFormValid ? primaryColor : Color.gray)
                    }
                    .disabled(!isFormValid)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                .zIndex(1) // Ensure header stays on top
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Add from contacts button
                        Button(action: {
                            requestContactsAccess()
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(primaryColor)
                                
                                Text("Add From Contacts")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(primaryColor)
                                
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
                        .opacity(0) // Hide the button
                        .disabled(true) // Disable the button
                        
                        // Name fields
                        VStack(spacing: 16) {
                            // First name field
                            HStack(spacing: 8) {
                                Image(systemName: "person")
                                    .font(.system(size: 18))
                                    .foregroundColor(iconColor)
                                    .frame(width: 24)
                                
                                TextField("", text: $firstName)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#0F1A2B"))
                                    .placeholderText(when: firstName.isEmpty) {
                                        Text("Enter first name")
                                            .foregroundColor(Color(hex: "#9CA3AF"))
                                    }
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputBorderColor, lineWidth: 1)
                            )
                            
                            // Last name field
                            TextField("", text: $lastName)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#0F1A2B"))
                                .placeholderText(when: lastName.isEmpty) {
                                    Text("Enter last name")
                                        .foregroundColor(Color(hex: "#9CA3AF"))
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(inputBorderColor, lineWidth: 1)
                                )
                        }
                        
                        // Company name section
                        VStack(spacing: 16) {
                            if !showCompanyField {
                                // Company name button
                                Button(action: {
                                    showCompanyField = true
                                    // Focus on the company name field after a short delay to allow animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        focusedField = .companyName
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "building.2")
                                            .font(.system(size: 18))
                                            .foregroundColor(iconColor)
                                            .frame(width: 24)
                                        
                                        Text("Add Company Name")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(primaryColor)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                }
                            } else {
                                // Company name field
                                VStack(spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "building.2")
                                            .font(.system(size: 18))
                                            .foregroundColor(iconColor)
                                            .frame(width: 24)
                                        
                                        TextField("", text: $companyName)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#0F1A2B"))
                                            .focused($focusedField, equals: .companyName)
                                            .placeholderText(when: companyName.isEmpty) {
                                                Text("Enter company name")
                                                    .foregroundColor(Color(hex: "#9CA3AF"))
                                            }
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(inputBorderColor, lineWidth: 1)
                                    )
                                    
                                    // Use company name as client name toggle
                                    Toggle(isOn: .constant(false)) {
                                        Text("Use company name as client name")
                                            .font(.system(size: 15))
                                            .foregroundColor(defaultTextColor)
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                                }
                            }
                        }
                        .padding(.top, -8)
                        
                        Divider()
                        
                        // Phone number section
                        VStack(spacing: 16) {
                            if !showPhoneField {
                                // Phone number button
                                Button(action: {
                                    showPhoneField = true
                                    // Focus on the phone number field after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        focusedField = .phoneNumber
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "phone")
                                            .font(.system(size: 18))
                                            .foregroundColor(iconColor)
                                            .frame(width: 24)
                                        
                                        Text("Add Phone Number")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(primaryColor)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                }
                            } else {
                                // Phone number field and options
                                VStack(spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "phone")
                                            .font(.system(size: 18))
                                            .foregroundColor(iconColor)
                                            .frame(width: 24)
                                        
                                        TextField("", text: $phoneNumber)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#0F1A2B"))
                                            .focused($focusedField, equals: .phoneNumber)
                                            .placeholderText(when: phoneNumber.isEmpty) {
                                                Text("Enter phone number")
                                                    .foregroundColor(Color(hex: "#9CA3AF"))
                                            }
                                            .keyboardType(.phonePad)
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(inputBorderColor, lineWidth: 1)
                                    )
                                    
                                    // Label dropdown
                                    HStack {
                                        Text("Label")
                                            .font(.system(size: 15))
                                            .foregroundColor(mutedTextColor)
                                        
                                        Spacer()
                                        
                                        Menu {
                                            Button("Main") { phoneLabel = "Main" }
                                            Button("Mobile") { phoneLabel = "Mobile" }
                                            Button("Work") { phoneLabel = "Work" }
                                            Button("Home") { phoneLabel = "Home" }
                                            Button("Other") { phoneLabel = "Other" }
                                        } label: {
                                            HStack {
                                                Text(phoneLabel)
                                                    .font(.system(size: 15))
                                                    .foregroundColor(defaultTextColor)
                                                
                                                Image(systemName: "chevron.down")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(iconColor)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    
                                    // Receives text messages toggle
                                    Toggle(isOn: $receivesTextMessages) {
                                        Text("Receives text messages")
                                            .font(.system(size: 15))
                                            .foregroundColor(defaultTextColor)
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                                    
                                    // Add another phone number button
                                    Button(action: {
                                        // Action to add another phone number
                                    }) {
                                        Text("Add Another Phone Number")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color(hex: "#4ADE80"))
                                    }
                                    .padding(.top, 8)
                                }
                            }
                        }
                        .padding(.top, -8)
                        
                        Divider()
                        
                        // Email section
                        VStack(spacing: 16) {
                            if !showEmailField {
                                // Email button
                                Button(action: {
                                    showEmailField = true
                                    // Focus on the email field after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        focusedField = .email
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "envelope")
                                            .font(.system(size: 18))
                                            .foregroundColor(iconColor)
                                            .frame(width: 24)
                                        
                                        Text("Add Email")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(primaryColor)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                }
                            } else {
                                // Email field
                                HStack(spacing: 8) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 18))
                                        .foregroundColor(iconColor)
                                        .frame(width: 24)
                                    
                                    TextField("", text: $email)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#0F1A2B"))
                                        .focused($focusedField, equals: .email)
                                        .placeholderText(when: email.isEmpty) {
                                            Text("Enter email address")
                                                .foregroundColor(Color(hex: "#9CA3AF"))
                                        }
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
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
                        .padding(.top, -8)
                        
                        Divider()
                        
                        // Lead source section
                        VStack(spacing: 16) {
                            if !showLeadSourceField {
                                // Lead source button
                                Button(action: {
                                    showLeadSourceField = true
                                    // Focus on the lead source field after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        focusedField = .leadSource
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "list.bullet")
                                            .font(.system(size: 18))
                                            .foregroundColor(iconColor)
                                            .frame(width: 24)
                                        
                                        Text("Add Lead Source")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(primaryColor)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                }
                            } else {
                                // Lead source field
                                HStack(spacing: 8) {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 18))
                                        .foregroundColor(iconColor)
                                        .frame(width: 24)
                                    
                                    TextField("", text: $leadSource)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#0F1A2B"))
                                        .focused($focusedField, equals: .leadSource)
                                        .placeholderText(when: leadSource.isEmpty) {
                                            Text("How did they find you?")
                                                .foregroundColor(Color(hex: "#9CA3AF"))
                                        }
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
                        .padding(.top, -8)
                        
                        Divider()
                        
                        // Property address section
                        VStack(spacing: 16) {
                            // Property address field with custom tap handler
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 18))
                                    .foregroundColor(iconColor)
                                    .frame(width: 24)
                                
                                TextField("", text: $propertyAddress)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#0F1A2B"))
                                    .focused($focusedField, equals: .propertyAddress)
                                    .placeholderText(when: propertyAddress.isEmpty) {
                                        Text("Property address")
                                            .foregroundColor(Color(hex: "#9CA3AF"))
                                    }
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputBorderColor, lineWidth: 1)
                            )
                            .makeTappable {
                                withAnimation {
                                    showAddressFields = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    focusedField = .propertyAddress
                                }
                            }
                            
                            if showAddressFields {
                                // Address line 2
                                TextField("", text: $addressLine2)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#0F1A2B"))
                                    .focused($focusedField, equals: .addressLine2)
                                    .placeholderText(when: addressLine2.isEmpty) {
                                        Text("Address line 2")
                                            .foregroundColor(Color(hex: "#9CA3AF"))
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(inputBorderColor, lineWidth: 1)
                                    )
                                
                                // City
                                TextField("", text: $city)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#0F1A2B"))
                                    .focused($focusedField, equals: .city)
                                    .placeholderText(when: city.isEmpty) {
                                        Text("City")
                                            .foregroundColor(Color(hex: "#9CA3AF"))
                                    }
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
                                        VStack(alignment: .leading) {
                                            Text("State")
                                                .font(.system(size: 16))
                                                .foregroundColor(state == "Select..." ? Color(hex: "#9CA3AF") : Color(hex: "#0F1A2B"))
                                                
                                            Text(state)
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(hex: "#0F1A2B"))
                                                .opacity(state == "Select..." ? 0 : 1)
                                        }
                                        
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
                                TextField("", text: $zipCode)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#0F1A2B"))
                                    .focused($focusedField, equals: .zipCode)
                                    .placeholderText(when: zipCode.isEmpty) {
                                        Text("Zip code")
                                            .foregroundColor(Color(hex: "#9CA3AF"))
                                    }
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
                                        VStack(alignment: .leading) {
                                            Text("Country")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(hex: "#9CA3AF"))
                                                
                                            Text(country)
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(hex: "#0F1A2B"))
                                        }
                                        
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
                                
                                // Billing address toggle
                                Toggle(isOn: $billingAddressMatchesProperty) {
                                    Text("Billing address matches property")
                                        .font(.system(size: 15))
                                        .foregroundColor(defaultTextColor)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#4CAF50")))
                                .padding(.vertical, 8)
                                
                                // Billing address fields (shown when toggle is off)
                                if !billingAddressMatchesProperty {
                                    // Billing address section title
                                    Text("Billing Address")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(defaultTextColor)
                                        .padding(.top, 16)
                                        .padding(.bottom, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Billing address field
                                    HStack(spacing: 8) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.system(size: 18))
                                            .foregroundColor(iconColor)
                                            .frame(width: 24)
                                        
                                        TextField("", text: $billingAddress)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#0F1A2B"))
                                            .focused($focusedField, equals: .billingAddress)
                                            .placeholderText(when: billingAddress.isEmpty) {
                                                Text("Billing address")
                                                    .foregroundColor(Color(hex: "#9CA3AF"))
                                            }
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(inputBorderColor, lineWidth: 1)
                                    )
                                    
                                    // Billing address line 2
                                    TextField("", text: $billingAddressLine2)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#0F1A2B"))
                                        .focused($focusedField, equals: .billingAddressLine2)
                                        .placeholderText(when: billingAddressLine2.isEmpty) {
                                            Text("Address line 2")
                                                .foregroundColor(Color(hex: "#9CA3AF"))
                                        }
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(inputBorderColor, lineWidth: 1)
                                        )
                                    
                                    // Billing city
                                    TextField("", text: $billingCity)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#0F1A2B"))
                                        .focused($focusedField, equals: .billingCity)
                                        .placeholderText(when: billingCity.isEmpty) {
                                            Text("City")
                                                .foregroundColor(Color(hex: "#9CA3AF"))
                                        }
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(inputBorderColor, lineWidth: 1)
                                        )
                                    
                                    // Billing state dropdown
                                    Menu {
                                        ForEach(states, id: \.self) { stateOption in
                                            Button(stateOption) {
                                                billingState = stateOption
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("State")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(billingState == "Select..." ? Color(hex: "#9CA3AF") : Color(hex: "#0F1A2B"))
                                                    
                                                Text(billingState)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(hex: "#0F1A2B"))
                                                    .opacity(billingState == "Select..." ? 0 : 1)
                                            }
                                            
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
                                    
                                    // Billing zip code
                                    TextField("", text: $billingZipCode)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "#0F1A2B"))
                                        .focused($focusedField, equals: .billingZipCode)
                                        .placeholderText(when: billingZipCode.isEmpty) {
                                            Text("Zip code")
                                                .foregroundColor(Color(hex: "#9CA3AF"))
                                        }
                                        .keyboardType(.numberPad)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(inputBorderColor, lineWidth: 1)
                                        )
                                    
                                    // Billing country dropdown
                                    Menu {
                                        ForEach(countries, id: \.self) { countryOption in
                                            Button(countryOption) {
                                                billingCountry = countryOption
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Country")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(hex: "#9CA3AF"))
                                                    
                                                Text(billingCountry)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(Color(hex: "#0F1A2B"))
                                            }
                                            
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
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .toolbar {
                // Add "Done" button above keyboard
                ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            dismissKeyboard()
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
            }
            .alert(isPresented: $showSavedAlert) {
                Alert(
                    title: Text("Client Saved"),
                    message: Text("The client has been saved successfully."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .sheet(isPresented: $showContactPicker, onDismiss: nil) {
            ContactPicker(
                firstName: $firstName,
                lastName: $lastName,
                companyName: $companyName,
                phoneNumber: $phoneNumber,
                email: $email,
                propertyAddress: $propertyAddress,
                addressLine2: $addressLine2,
                city: $city,
                state: $state,
                zipCode: $zipCode,
                showPhoneField: $showPhoneField,
                showEmailField: $showEmailField,
                showCompanyField: $showCompanyField,
                showAddressFields: $showAddressFields,
                isPresented: $showContactPicker
            )
            .interactiveDismissDisabled(true)
        }
        .alert(isPresented: $showContactsAlert) {
            Alert(
                title: Text("Contacts Access Required"),
                message: Text(contactsAlertMessage),
                primaryButton: .default(Text("Open Settings")) {
                    openAppSettings()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}

#Preview {
    NewClientView()
}

// MARK: - Contact Picker Implementation
struct ContactPicker: UIViewControllerRepresentable {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var companyName: String
    @Binding var phoneNumber: String
    @Binding var email: String
    @Binding var propertyAddress: String
    @Binding var addressLine2: String
    @Binding var city: String
    @Binding var state: String
    @Binding var zipCode: String
    @Binding var showPhoneField: Bool
    @Binding var showEmailField: Bool
    @Binding var showCompanyField: Bool
    @Binding var showAddressFields: Bool
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        
        // Prevent the picker from dismissing the entire view hierarchy
        picker.modalPresentationStyle = .overFullScreen
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPicker
        
        init(_ parent: ContactPicker) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            // Process contact data on the main thread to ensure UI updates properly
            DispatchQueue.main.async {
            // Extract name
                self.parent.firstName = contact.givenName
                self.parent.lastName = contact.familyName
            
            // Extract company name if available
            if !contact.organizationName.isEmpty {
                    self.parent.companyName = contact.organizationName
                    self.parent.showCompanyField = true
            }
            
            // Extract phone number if available
            if !contact.phoneNumbers.isEmpty {
                // Get the first phone number for now
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                        self.parent.phoneNumber = phoneNumber
                        self.parent.showPhoneField = true
                }
            }
            
            // Extract email if available
            if !contact.emailAddresses.isEmpty {
                // Get the first email for now
                if let email = contact.emailAddresses.first?.value as String? {
                        self.parent.email = email
                        self.parent.showEmailField = true
                }
            }
            
            // Extract postal address if available
            if !contact.postalAddresses.isEmpty {
                // Get the first address for now
                if let postalAddress = contact.postalAddresses.first?.value {
                    // Format address components
                        self.parent.propertyAddress = postalAddress.street
                    
                    // Split street into address line 1 and 2 if it contains a newline
                    let streetComponents = postalAddress.street.components(separatedBy: "\n")
                    if streetComponents.count > 1 {
                            self.parent.propertyAddress = streetComponents[0]
                            self.parent.addressLine2 = streetComponents[1]
                    }
                    
                        self.parent.city = postalAddress.city
                    
                    // Only set state if it's in the US states list
                    let usStates = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
                    
                    if usStates.contains(postalAddress.state) {
                            self.parent.state = postalAddress.state
                    }
                    
                        self.parent.zipCode = postalAddress.postalCode
                        self.parent.showAddressFields = true
                }
            }
            
                // Dismiss only the contact picker, not the entire view
                self.parent.isPresented = false
            }
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            // Handle cancellation on the main thread
            DispatchQueue.main.async {
                self.parent.isPresented = false
            }
        }
    }
} 
