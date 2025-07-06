//
//  SWEEPLYPROApp.swift
//  SWEEPLYPRO
//
//  Created by Joao Leite on 7/2/25.
//

import SwiftUI
import SwiftData

// Define Client model for SwiftData
@Model
final class Client {
    var firstName: String
    var lastName: String
    var companyName: String
    var phoneNumber: String
    var phoneLabel: String
    var receivesTextMessages: Bool
    var email: String
    var leadSource: String
    
    // Property address fields
    var propertyAddress: String
    var propertyAddressLine2: String
    var propertyCity: String
    var propertyState: String
    var propertyZipCode: String
    var propertyCountry: String
    
    // Billing address fields
    var billingAddressSameAsProperty: Bool
    var billingAddress: String
    var billingAddressLine2: String
    var billingCity: String
    var billingState: String
    var billingZipCode: String
    var billingCountry: String
    
    var createdAt: Date
    
    init(
        firstName: String,
        lastName: String,
        companyName: String = "",
        phoneNumber: String = "",
        phoneLabel: String = "Main",
        receivesTextMessages: Bool = false,
        email: String = "",
        leadSource: String = "",
        propertyAddress: String = "",
        propertyAddressLine2: String = "",
        propertyCity: String = "",
        propertyState: String = "",
        propertyZipCode: String = "",
        propertyCountry: String = "United States",
        billingAddressSameAsProperty: Bool = true,
        billingAddress: String = "",
        billingAddressLine2: String = "",
        billingCity: String = "",
        billingState: String = "",
        billingZipCode: String = "",
        billingCountry: String = "United States"
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.companyName = companyName
        self.phoneNumber = phoneNumber
        self.phoneLabel = phoneLabel
        self.receivesTextMessages = receivesTextMessages
        self.email = email
        self.leadSource = leadSource
        
        self.propertyAddress = propertyAddress
        self.propertyAddressLine2 = propertyAddressLine2
        self.propertyCity = propertyCity
        self.propertyState = propertyState
        self.propertyZipCode = propertyZipCode
        self.propertyCountry = propertyCountry
        
        self.billingAddressSameAsProperty = billingAddressSameAsProperty
        self.billingAddress = billingAddressSameAsProperty ? propertyAddress : billingAddress
        self.billingAddressLine2 = billingAddressSameAsProperty ? propertyAddressLine2 : billingAddressLine2
        self.billingCity = billingAddressSameAsProperty ? propertyCity : billingCity
        self.billingState = billingAddressSameAsProperty ? propertyState : billingState
        self.billingZipCode = billingAddressSameAsProperty ? propertyZipCode : billingZipCode
        self.billingCountry = billingAddressSameAsProperty ? propertyCountry : billingCountry
        
        self.createdAt = Date()
    }
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return companyName.isEmpty ? "Unnamed Client" : companyName
        }
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var formattedPropertyAddress: String {
        var components = [propertyAddress]
        
        if !propertyAddressLine2.isEmpty {
            components.append(propertyAddressLine2)
        }
        
        let cityStateZip = [propertyCity, propertyState, propertyZipCode]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        if !cityStateZip.isEmpty {
            components.append(cityStateZip)
        }
        
        return components.joined(separator: "\n")
    }
    
    var formattedBillingAddress: String {
        if billingAddressSameAsProperty {
            return formattedPropertyAddress
        }
        
        var components = [billingAddress]
        
        if !billingAddressLine2.isEmpty {
            components.append(billingAddressLine2)
        }
        
        let cityStateZip = [billingCity, billingState, billingZipCode]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        if !cityStateZip.isEmpty {
            components.append(cityStateZip)
        }
        
        return components.joined(separator: "\n")
    }
}

@main
struct SWEEPLYPROApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Client.self,
            Task.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Set the appearance for UINavigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(hex: "#F5F5F5"))
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set background color for the entire app
        UITabBar.appearance().backgroundColor = UIColor(Color(hex: "#F5F5F5"))
        
        // Set the background color for the status bar area
        if #available(iOS 15.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.backgroundColor = UIColor(Color(hex: "#F5F5F5"))
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
