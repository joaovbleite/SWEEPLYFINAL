//
//  NewClientView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import SwiftData
import UIKit

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
    
    // Toggle states for showing fields
    @State private var showCompanyField = false
    @State private var showPhoneField = false
    @State private var showEmailField = false
    @State private var showLeadSourceField = false
    @State private var showAddressFields = false
    
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
            propertyAddress: fullAddress
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Add from contacts button
                    Button(action: {
                        // Action to add from contacts
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
                        // Property address field
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
                                .onTapGesture {
                                    withAnimation {
                                        showAddressFields = true
                                    }
                                }
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                        .onTapGesture {
                            withAnimation {
                                showAddressFields = true
                                // Focus on the property address field
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
                        }
                    }
                    
                    Spacer()
                    
                    // Save button - only show when there's content
                    if hasContent {
                        Button(action: {
                            saveClient()
                        }) {
                            Text("Save")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isFormValid ? successColor : Color.gray.opacity(0.5))
                                .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color.white)
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(primaryColor)
                    }
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
    }
}

#Preview {
    NewClientView()
} 
