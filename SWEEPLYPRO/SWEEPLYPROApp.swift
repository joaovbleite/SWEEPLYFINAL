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
    var propertyAddress: String
    var billingAddress: String
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
        billingAddress: String = ""
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
        self.billingAddress = billingAddress
        self.createdAt = Date()
    }
    
    var fullName: String {
        if firstName.isEmpty && lastName.isEmpty {
            return companyName.isEmpty ? "Unnamed Client" : companyName
        }
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
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
        
        // Use persistent storage with default configuration
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
