//
//  ClientDetailView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct ClientDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let client: Client
    
    // State variables
    @State private var selectedTab = 0
    @State private var isEditContactDetailsPresented = false
    
    // Computed property to check if billing address is the same as property address
    private var isBillingSameAsProperty: Bool {
        return client.billingAddress.isEmpty || client.billingAddress == client.propertyAddress
    }
    
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
        .sheet(isPresented: $isEditContactDetailsPresented) {
            EditContactDetailsView(client: client)
        }
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
            
            // Property section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(isBillingSameAsProperty ? "Property and Billing address" : "Property")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        // Action to add property
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(greenColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                if !client.propertyAddress.isEmpty {
                    propertyCard
                } else {
                    Text("No properties added")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }
            }
            
            Divider()
            
            // Billing address section - only show if different from property address
            if !isBillingSameAsProperty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Billing address")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        Spacer()
                        
                        Button(action: {
                            // Action to edit billing address
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20))
                                .foregroundColor(greenColor)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Show billing address if it exists
                    if !client.billingAddress.isEmpty {
                        billingAddressCard
                    } else {
                        Text("No billing address added")
                            .font(.system(size: 16))
                            .foregroundColor(mutedTextColor)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
                
                Divider()
            }
            
            // Contact details section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Contact details")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        // Navigate to edit contact details
                        openEditContactDetails()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(greenColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                contactDetailsCard
            }
        }
    }
    
    // Property card
    var propertyCard: some View {
        Button(action: {
            // Action when property is tapped
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.propertyAddress)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                }
                
                Button(action: {
                    openMapsWithAddress(client.propertyAddress)
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 14))
                        Text("Get Directions")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // Billing address card
    var billingAddressCard: some View {
        Button(action: {
            // Action when billing address is tapped
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.billingAddress)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                }
                
                Button(action: {
                    openMapsWithAddress(client.billingAddress)
                }) {
                    HStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 14))
                        Text("Get Directions")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // Contact details card
    var contactDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Show phone number if available
            if !client.phoneNumber.isEmpty {
                Button(action: {
                    // Action when phone is tapped
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(client.phoneNumber)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(textColor)
                            
                            Text(client.phoneLabel)
                                .font(.system(size: 14))
                                .foregroundColor(mutedTextColor)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16))
                            .foregroundColor(greenColor)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 16)
            }
            
            // Show email if available
            if !client.email.isEmpty {
                Button(action: {
                    // Action when email is tapped
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(client.email)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(textColor)
                            
                            Text("Email")
                                .font(.system(size: 14))
                                .foregroundColor(mutedTextColor)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 16))
                            .foregroundColor(greenColor)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 16)
            }
            
            // If no contact details available
            if client.phoneNumber.isEmpty && client.email.isEmpty {
                Text("No contact details added")
                    .font(.system(size: 16))
                    .foregroundColor(mutedTextColor)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .padding(.bottom, 16)
    }
    
    // Function to open Maps app with the address
    func openMapsWithAddress(_ address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                mapItem.name = "Client Property"
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            } else {
                // If geocoding fails, try to open Maps with the address as a search query
                if let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: "http://maps.apple.com/?q=\(encodedAddress)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    // Function to open edit contact details
    func openEditContactDetails() {
        isEditContactDetailsPresented = true
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
        firstName: "Joao",
        lastName: "Leite",
        propertyAddress: "103 Fairway Drive\nAcworth, Georgia 30101"
    )
    
    return ClientDetailView(client: client)
} 