//
//  DashboardView.swift
//  SWEEPLYFINAL
//
//  Created by Joao Leite on 6/30/25.
//

import SwiftUI

struct DashboardView: View {
    // Current date
    @State private var currentDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with date and icons
                headerView
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Stats cards
                        HStack(spacing: 12) {
                            DashboardOverviewCard(
                                title: "Jobs Today",
                                value: "0",
                                subtitleText: "1 last week",
                                changeValue: "-14%",
                                changeDirection: .down,
                                iconName: "calendar",
                                iconBackgroundColor: Color(hex: "#E6EEFF"),
                                iconForegroundColor: Color(hex: "#3B82F6")
                            )
                            
                            DashboardOverviewCard(
                                title: "Active Clients",
                                value: "4",
                                subtitleText: "5 new this week",
                                changeValue: "+5",
                                changeDirection: .up,
                                iconName: "person.2.fill",
                                iconBackgroundColor: Color(hex: "#E7F7EB"),
                                iconForegroundColor: Color(hex: "#27AE60")
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Additional dashboard content would go here
                    }
                }
            }
            .background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text(dateString)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "#5E7380"))
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    // Star plus action
                }) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }
                
                ZStack(alignment: .topTrailing) {
                    Button(action: {
                        // Notification action
                    }) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                    
                    // Notification badge
                    Text("9")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color(hex: "#FF3B30"))
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - Helper Properties
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let dateStr = formatter.string(from: currentDate)
        
        // Add the ordinal suffix (st, nd, rd, th)
        let day = Calendar.current.component(.day, from: currentDate)
        let suffix = ordinalSuffix(for: day)
        
        return dateStr.replacingOccurrences(of: " \(day)", with: " \(day)\(suffix)")
    }
    
    // Function to get the ordinal suffix for a number
    private func ordinalSuffix(for number: Int) -> String {
        let j = number % 10
        let k = number % 100
        
        if j == 1 && k != 11 {
            return "st"
        }
        if j == 2 && k != 12 {
            return "nd"
        }
        if j == 3 && k != 13 {
            return "rd"
        }
        return "th"
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
} 