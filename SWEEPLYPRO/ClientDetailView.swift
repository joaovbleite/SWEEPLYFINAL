//
//  ClientDetailView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import SwiftData

struct ClientDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let client: Client
    
    // State variables
    @State private var selectedTab = 0
    
    // Tab options
    let tabs = ["Client", "Work", "Notes"]
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#153B3F")
    let mutedTextColor = Color(hex: "#6B7280")
    let borderColor = Color(hex: "#E5E7EB")
    let greenColor = Color(hex: "#4CAF50")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                .padding(.horizontal, 16)
                
                // Client name
                Text(client.fullName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.horizontal, 16)
                
                // Client balance
                HStack {
                    Text("Client balance")
                        .font(.system(size: 18))
                        .foregroundColor(mutedTextColor)
                    
                    Spacer()
                    
                    Text("$0.00")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(textColor)
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                // Create button
                Button(action: {
                    // Action for create button
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                        
                        Text("Create")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(greenColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
                
                // Tab selector
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            VStack(spacing: 8) {
                                Text(tabs[index])
                                    .font(.system(size: 16, weight: selectedTab == index ? .semibold : .regular))
                                    .foregroundColor(selectedTab == index ? textColor : mutedTextColor)
                                
                                // Indicator bar
                                Rectangle()
                                    .fill(selectedTab == index ? textColor : Color.clear)
                                    .frame(height: 3)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.top, 24)
                
                // Divider
                Rectangle()
                    .fill(borderColor)
                    .frame(height: 1)
                
                // Tab content
                VStack(alignment: .leading, spacing: 0) {
                    if selectedTab == 0 {
                        clientTabContent
                    } else if selectedTab == 1 {
                        workTabContent
                    } else {
                        notesTabContent
                    }
                }
                .padding(.top, 8)
            }
        }
        .background(backgroundColor)
        .navigationBarHidden(true)
    }
    
    // Client tab content
    var clientTabContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Client name row
            HStack {
                Text(client.fullName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(mutedTextColor)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            
            Divider()
            
            // Lead source section
            VStack(alignment: .leading, spacing: 8) {
                Text("Lead source")
                    .font(.system(size: 16))
                    .foregroundColor(mutedTextColor)
                
                Text(client.leadSource.isEmpty ? "—" : client.leadSource)
                    .font(.system(size: 18))
                    .foregroundColor(textColor)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            
            Divider()
            
            // Property and address sections
            if !client.propertyAddress.isEmpty {
                propertyCard
            } else {
                // Empty property state
                VStack(alignment: .leading, spacing: 16) {
                    Text("Property")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    Text("No properties added")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }
        }
    }
    
    // Property card
    var propertyCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Property header
            Text("Property")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(textColor)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            
            // Property address card
            Button(action: {
                // Action when property is tapped
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        // Display formatted property address
                        Text(client.formattedPropertyAddress)
                            .font(.system(size: 20))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(greenColor)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            
            // Billing address section
            VStack(alignment: .leading, spacing: 0) {
                Text("Billing address")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                Button(action: {
                    // Action when billing address is tapped
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            // Display formatted billing address
                            Text(client.formattedBillingAddress)
                                .font(.system(size: 20))
                                .foregroundColor(textColor)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(greenColor)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
            }
            
            // Contact details section
            VStack(alignment: .leading, spacing: 0) {
                Text("Contact details")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                
                Button(action: {
                    // Action when contact details are tapped
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(greenColor)
                        
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(backgroundColor)
    }
    
    // Work tab content (placeholder)
    var workTabContent: some View {
        VStack {
            Text("No work history")
                .font(.system(size: 16))
                .foregroundColor(mutedTextColor)
                .padding(24)
        }
        .frame(maxWidth: .infinity)
    }
    
    // Notes tab content (placeholder)
    var notesTabContent: some View {
        VStack {
            Text("No notes")
                .font(.system(size: 16))
                .foregroundColor(mutedTextColor)
                .padding(24)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    // Create a sample client for preview
    let client = Client(
        firstName: "John",
        lastName: "Smith",
        companyName: "Smith Landscaping",
        phoneNumber: "555-123-4567",
        email: "john@example.com",
        leadSource: "Website",
        propertyAddress: "103 Fairway Drive",
        propertyCity: "Acworth",
        propertyState: "Georgia",
        propertyZipCode: "30101"
    )
    return ClientDetailView(client: client)
} 