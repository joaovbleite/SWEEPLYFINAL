//
//  SweeplyInfo.swift
//  SWEEPLYFINAL
//
//  Created by Joao Leite on 6/30/25.
//

import Foundation

/// This file contains information about Sweeply to provide context within the app
struct SweeplyInfo {
    
    // MARK: - App Information
    static let appName = "Sweeply"
    static let appDescription = "A comprehensive business management platform for service professionals"
    static let appVersion = "1.0.0"
    
    // MARK: - Company Information
    static let companyName = "Sweeply Inc."
    static let foundedYear = 2025
    static let website = "https://sweeply.com"
    
    // MARK: - App Features
    static let features = [
        Feature(
            id: "scheduling",
            name: "Smart Scheduling",
            description: "Efficiently manage appointments and job visits with an intuitive calendar interface",
            benefits: ["Reduce scheduling conflicts", "Optimize travel routes", "Send automatic reminders"]
        ),
        Feature(
            id: "client_management",
            name: "Client Management",
            description: "Maintain a comprehensive database of clients with contact information and service history",
            benefits: ["Build stronger client relationships", "Track client preferences", "Access history at a glance"]
        ),
        Feature(
            id: "invoicing",
            name: "Invoicing & Payments",
            description: "Create professional invoices and accept payments directly through the app",
            benefits: ["Get paid faster", "Maintain professional appearance", "Track payment status"]
        ),
        Feature(
            id: "business_insights",
            name: "Business Insights",
            description: "Gain valuable insights into your business performance with detailed analytics",
            benefits: ["Track revenue trends", "Identify growth opportunities", "Make data-driven decisions"]
        ),
        Feature(
            id: "quotes",
            name: "Quote Creation",
            description: "Create professional quotes for potential clients quickly and easily",
            benefits: ["Win more business", "Standardize pricing", "Track conversion rates"]
        )
    ]
    
    // MARK: - Target Industries
    static let targetIndustries = [
        "Cleaning Services",
        "Landscaping & Lawn Care",
        "Home Maintenance",
        "HVAC Services",
        "Plumbing",
        "Electrical Services",
        "Pest Control",
        "Pool Maintenance",
        "Carpet Cleaning",
        "Window Cleaning"
    ]
    
    // MARK: - App Sections
    static let appSections = [
        AppSection(
            id: "dashboard",
            name: "Dashboard",
            description: "Overview of your business at a glance",
            icon: "house.fill"
        ),
        AppSection(
            id: "schedule",
            name: "Schedule",
            description: "Manage appointments and job visits",
            icon: "calendar"
        ),
        AppSection(
            id: "clients",
            name: "Clients",
            description: "Manage your client database",
            icon: "person.2.fill"
        ),
        AppSection(
            id: "jobs",
            name: "Jobs",
            description: "Track and manage service jobs",
            icon: "briefcase.fill"
        ),
        AppSection(
            id: "invoices",
            name: "Invoices",
            description: "Create and manage invoices",
            icon: "doc.text.fill"
        ),
        AppSection(
            id: "settings",
            name: "Settings",
            description: "Configure app preferences",
            icon: "gear"
        )
    ]
    
    // MARK: - Business Health Metrics
    static let businessMetrics = [
        "Job Value",
        "Visits Scheduled",
        "Invoices Paid",
        "Average Job Value",
        "Monthly Revenue",
        "Total Jobs",
        "Year-to-Date Revenue",
        "Total Clients"
    ]
    
    // MARK: - Todo Items
    static let todoItems = [
        "Create a winning quote",
        "Add your first client",
        "Try Sweeply on desktop",
        "Complete your business profile",
        "Set up payment methods",
        "Create your first invoice",
        "Schedule your first job"
    ]
}

// MARK: - Supporting Models
struct Feature: Identifiable {
    let id: String
    let name: String
    let description: String
    let benefits: [String]
}

struct AppSection: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
} 