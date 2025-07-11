//
//  EditContactDetailsView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import SwiftData

// Focus state enum for keyboard focus
enum ContactDetailsFocusField: Hashable {
    case phoneNumber
    case email
}

struct EditContactDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: ContactDetailsFocusField?
    
    // Client reference
    let client: Client
    
    // Form fields
    @State private var phoneNumber: String
    @State private var phoneLabel: String
    @State private var receivesTextMessages: Bool
    @State private var email: String
    
    // State for showing additional fields
    @State private var showAdditionalPhoneField = false
    @State private var additionalPhoneNumber = ""
    @State private var additionalPhoneLabel = "Mobile"
    @State private var additionalReceivesTextMessages = false
    
    @State private var showAdditionalEmailField = false
    @State private var additionalEmail = ""
    
    // Colors from design system
    let primaryColor = Color(hex: "#2563EB")
    let successColor = Color(hex: "#34D399")
    let inputBorderColor = Color(hex: "#D1D5DB")
    let placeholderColor = Color(hex: "#9CA3AF")
    let iconColor = Color(hex: "#6B7280")
    let defaultTextColor = Color(hex: "#0F1A2B")
    let mutedTextColor = Color(hex: "#6B7280")
    let greenColor = Color(hex: "#4CAF50")
    
    // Initialize with client data
    init(client: Client) {
        self.client = client
        
        // Initialize state variables with client data
        // Use empty string fallbacks for optional values
        _phoneNumber = State(initialValue: client.phoneNumber)
        _phoneLabel = State(initialValue: client.phoneLabel.isEmpty ? "Main" : client.phoneLabel)
        _receivesTextMessages = State(initialValue: client.receivesTextMessages)
        _email = State(initialValue: client.email)
        
        // Set showAdditionalFields based on whether data exists
        // This is just for preview purposes - in a real app you might have multiple phone numbers
        // stored in a different way
        _showAdditionalPhoneField = State(initialValue: false)
        _showAdditionalEmailField = State(initialValue: false)
    }
    
    // Save changes to client
    private func saveChanges() {
        // Update client with new values
        client.phoneNumber = phoneNumber
        client.phoneLabel = phoneLabel
        client.receivesTextMessages = receivesTextMessages
        client.email = email
        
        // Save changes to SwiftData
        try? modelContext.save()
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Default phone number section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#F59E0B"))
                            
                            Text("Default phone number")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(defaultTextColor)
                        }
                        
                        // Phone number field
                        HStack(spacing: 8) {
                            Image(systemName: "phone")
                                .font(.system(size: 18))
                                .foregroundColor(iconColor)
                                .frame(width: 24)
                            
                            TextField("", text: $phoneNumber)
                                .font(.system(size: 16))
                                .foregroundColor(defaultTextColor)
                                .focused($focusedField, equals: .phoneNumber)
                                .placeholderText(when: phoneNumber.isEmpty) {
                                    Text("Phone number")
                                        .foregroundColor(placeholderColor)
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
                    }
                    
                    // Additional phone number section
                    VStack(spacing: 16) {
                        if !showAdditionalPhoneField {
                            // Add another phone number button
                            Button(action: {
                                showAdditionalPhoneField = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(greenColor)
                                    
                                    Text("Additional phone number")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(greenColor)
                                    
                                    Spacer()
                                }
                            }
                        } else {
                            // Additional phone fields
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Additional phone number")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(defaultTextColor)
                                
                                // Phone number field
                                HStack(spacing: 8) {
                                    Image(systemName: "phone")
                                        .font(.system(size: 18))
                                        .foregroundColor(iconColor)
                                        .frame(width: 24)
                                    
                                    TextField("", text: $additionalPhoneNumber)
                                        .font(.system(size: 16))
                                        .foregroundColor(defaultTextColor)
                                        .placeholderText(when: additionalPhoneNumber.isEmpty) {
                                            Text("Phone number")
                                                .foregroundColor(placeholderColor)
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
                                        Button("Main") { additionalPhoneLabel = "Main" }
                                        Button("Mobile") { additionalPhoneLabel = "Mobile" }
                                        Button("Work") { additionalPhoneLabel = "Work" }
                                        Button("Home") { additionalPhoneLabel = "Home" }
                                        Button("Other") { additionalPhoneLabel = "Other" }
                                    } label: {
                                        HStack {
                                            Text(additionalPhoneLabel)
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
                                Toggle(isOn: $additionalReceivesTextMessages) {
                                    Text("Receives text messages")
                                        .font(.system(size: 15))
                                        .foregroundColor(defaultTextColor)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                                
                                // Remove button
                                Button(action: {
                                    showAdditionalPhoneField = false
                                    additionalPhoneNumber = ""
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16))
                                            .foregroundColor(.red)
                                        
                                        Text("Remove")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Default email section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#F59E0B"))
                            
                            Text("Default email address")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(defaultTextColor)
                        }
                        
                        // Email field
                        HStack(spacing: 8) {
                            Image(systemName: "envelope")
                                .font(.system(size: 18))
                                .foregroundColor(iconColor)
                                .frame(width: 24)
                            
                            TextField("", text: $email)
                                .font(.system(size: 16))
                                .foregroundColor(defaultTextColor)
                                .focused($focusedField, equals: .email)
                                .placeholderText(when: email.isEmpty) {
                                    Text("Email address")
                                        .foregroundColor(placeholderColor)
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
                        
                        // Label (always Main for email)
                        HStack {
                            Text("Label")
                                .font(.system(size: 15))
                                .foregroundColor(mutedTextColor)
                            
                            Spacer()
                            
                            Text("Main")
                                .font(.system(size: 15))
                                .foregroundColor(defaultTextColor)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Additional email section
                    VStack(spacing: 16) {
                        if !showAdditionalEmailField {
                            // Add another email button
                            Button(action: {
                                showAdditionalEmailField = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(greenColor)
                                    
                                    Text("Additional email address")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(greenColor)
                                    
                                    Spacer()
                                }
                            }
                        } else {
                            // Additional email fields
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Additional email address")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(defaultTextColor)
                                
                                // Email field
                                HStack(spacing: 8) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 18))
                                        .foregroundColor(iconColor)
                                        .frame(width: 24)
                                    
                                    TextField("", text: $additionalEmail)
                                        .font(.system(size: 16))
                                        .foregroundColor(defaultTextColor)
                                        .placeholderText(when: additionalEmail.isEmpty) {
                                            Text("Email address")
                                                .foregroundColor(placeholderColor)
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
                                
                                // Label (always Main for additional email)
                                HStack {
                                    Text("Label")
                                        .font(.system(size: 15))
                                        .foregroundColor(mutedTextColor)
                                    
                                    Spacer()
                                    
                                    Text("Other")
                                        .font(.system(size: 15))
                                        .foregroundColor(defaultTextColor)
                                }
                                .padding(.vertical, 8)
                                
                                // Remove button
                                Button(action: {
                                    showAdditionalEmailField = false
                                    additionalEmail = ""
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16))
                                            .foregroundColor(.red)
                                        
                                        Text("Remove")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        saveChanges()
                    }) {
                        Text("Save")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(successColor)
                            .cornerRadius(12)
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Edit contact details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(primaryColor)
                    }
                }
            }
        }
    }
}

#Preview {
    // Create a sample client for preview
    let client = Client(
        firstName: "John",
        lastName: "Doe",
        phoneNumber: "555-123-4567",
        email: "john.doe@example.com"
    )
    
    return EditContactDetailsView(client: client)
} 