//
//  SweeplyWidgetViews.swift
//  WIDGETS
//
//  Created for Sweeply Pro
//

import SwiftUI
import WidgetKit

// Helper extension for Color from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Small widget view
struct SweeplySmallWidgetView: View {
    var entry: SweeplyWidgetEntry
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: entry.configuration.colorTheme.secondaryColor)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Header with logo
                HStack {
                    Text("SWEEPLY PRO")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                    
                    Spacer()
                    
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                }
                
                Spacer()
                
                // Content based on what we're showing
                if entry.showCustomers {
                    // Customers view
                    VStack(spacing: 4) {
                        Text("\(entry.customersToday)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                        
                        Text(entry.customersToday == 1 ? "Customer" : "Customers")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.secondary)
                        
                        Text("Today")
                            .font(.system(size: 14))
                            .foregroundColor(Color.secondary)
                    }
                } else {
                    // Tasks view
                    VStack(spacing: 4) {
                        Text("\(entry.tasksDueToday)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                        
                        Text(entry.tasksDueToday == 1 ? "Task" : "Tasks")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.secondary)
                        
                        Text("Due Today")
                            .font(.system(size: 14))
                            .foregroundColor(Color.secondary)
                    }
                }
                
                Spacer()
                
                // Footer with date
                Text(formattedDate(from: entry.date))
                    .font(.system(size: 12))
                    .foregroundColor(Color.secondary)
            }
            .padding()
        }
    }
    
    // Format date to "MMM d, yyyy" (e.g., "Jul 7, 2025")
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// Medium widget view
struct SweeplyMediumWidgetView: View {
    var entry: SweeplyWidgetEntry
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: entry.configuration.colorTheme.secondaryColor)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Header with logo
                HStack {
                    Text("SWEEPLY PRO")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                    
                    Spacer()
                    
                    Text("Business Dashboard")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                    
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                }
                
                Spacer()
                
                // Content with both metrics
                HStack(spacing: 20) {
                    // Customers metric
                    VStack(spacing: 4) {
                        Text("\(entry.customersToday)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                        
                        Text(entry.customersToday == 1 ? "Customer" : "Customers")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.secondary)
                        
                        Text("Today")
                            .font(.system(size: 14))
                            .foregroundColor(Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(12)
                    
                    // Tasks metric
                    VStack(spacing: 4) {
                        Text("\(entry.tasksDueToday)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                        
                        Text(entry.tasksDueToday == 1 ? "Task" : "Tasks")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.secondary)
                        
                        Text("Due Today")
                            .font(.system(size: 14))
                            .foregroundColor(Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Footer with date and time
                HStack {
                    Text(formattedDate(from: entry.date))
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                    
                    Spacer()
                    
                    Text(formattedTime(from: entry.date))
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                }
            }
            .padding()
        }
    }
    
    // Format date to "MMM d, yyyy" (e.g., "Jul 7, 2025")
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    // Format time to "h:mm a" (e.g., "3:30 PM")
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// Large widget view
struct SweeplyLargeWidgetView: View {
    var entry: SweeplyWidgetEntry
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: entry.configuration.colorTheme.secondaryColor)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header with logo
                HStack {
                    Text("SWEEPLY PRO")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                    
                    Spacer()
                    
                    Text("Business Dashboard")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondary)
                    
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                }
                
                // Main metrics section
                HStack(spacing: 20) {
                    // Customers metric
                    VStack(spacing: 8) {
                        Text("\(entry.customersToday)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                        
                        Text(entry.customersToday == 1 ? "Customer" : "Customers")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.secondary)
                        
                        Text("Today")
                            .font(.system(size: 16))
                            .foregroundColor(Color.secondary)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(16)
                    
                    // Tasks metric
                    VStack(spacing: 8) {
                        Text("\(entry.tasksDueToday)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                        
                        Text(entry.tasksDueToday == 1 ? "Task" : "Tasks")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.secondary)
                        
                        Text("Due Today")
                            .font(.system(size: 16))
                            .foregroundColor(Color.secondary)
                        
                        Image(systemName: "checklist")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(16)
                }
                
                // Additional business metrics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Business Health")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: entry.configuration.colorTheme.primaryColor))
                    
                    HStack(spacing: 16) {
                        // Revenue metric
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Revenue")
                                .font(.system(size: 14))
                                .foregroundColor(Color.secondary)
                            
                            Text("$\(formattedRevenue(entry.totalRevenue))")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "#4CAF50"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Invoices metric
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Invoices")
                                .font(.system(size: 14))
                                .foregroundColor(Color.secondary)
                            
                            Text("\(entry.pendingInvoices) pending")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "#F59E0B"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Overdue tasks
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Overdue")
                                .font(.system(size: 14))
                                .foregroundColor(Color.secondary)
                            
                            Text("\(entry.overdueTasks) tasks")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(entry.overdueTasks > 0 ? Color(hex: "#EF4444") : Color(hex: "#4CAF50"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.6))
                .cornerRadius(16)
                
                Spacer()
                
                // Footer with date and time
                HStack {
                    Text(formattedDate(from: entry.date))
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondary)
                    
                    Spacer()
                    
                    Text("Last updated: \(formattedTime(from: entry.date))")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondary)
                }
            }
            .padding()
        }
    }
    
    // Format date to "MMM d, yyyy" (e.g., "Jul 7, 2025")
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    // Format time to "h:mm a" (e.g., "3:30 PM")
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    // Format revenue with commas and no decimal places
    private func formattedRevenue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
} 