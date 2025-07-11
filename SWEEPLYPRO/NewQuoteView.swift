//
//  NewQuoteView.swift
//  SWEEPLYPRO
//
//  Created on 7/10/25.
//

import SwiftUI

struct NewQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSelectClient = false
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var propertyAddress = ""
    @State private var showPhoneField = false
    @State private var showEmailField = false
    @State private var phoneNumber = ""
    @State private var email = ""
    
    // Colors following the app's brand colors
    private let primaryColor = Color(hex: "#246BFD") // Blue
    private let iconColor = Color(hex: "#5E7380") // Grey
    private let backgroundColor = Color(hex: "#F5F5F5") // Light background
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, propertyAddress, phone, email
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
                    .frame(width: 20)
                
                TextField("Property address", text: $propertyAddress)
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