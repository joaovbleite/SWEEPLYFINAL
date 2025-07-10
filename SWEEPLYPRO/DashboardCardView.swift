//
//  DashboardCardView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct DashboardCardView: View {
    let title: String
    let value: String
    let subtext: String
    let changePercentage: Double?
    let iconName: String
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#5E7380"))
                    .lineLimit(1)
                
                Spacer()
                
                // Icon circle
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(iconForegroundColor)
                }
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1A"))
            
            HStack {
                Text(subtext)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#8B99A6"))
                    .lineLimit(1)
                
                Spacer()
                
                if let changePercentage = changePercentage {
                    HStack(spacing: 2) {
                        Image(systemName: changePercentage >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12))
                            .foregroundColor(changePercentage >= 0 ? Color(hex: "#2ECC71") : Color(hex: "#FF3B30"))
                        
                        Text("\(abs(changePercentage), specifier: "%.0f")%")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(changePercentage >= 0 ? Color(hex: "#2ECC71") : Color(hex: "#FF3B30"))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 1, x: 0, y: 1)
        .frame(height: 120) // Fixed height for both cards
    }
}

struct JobsTodayCardView: View {
    var body: some View {
        DashboardCardView(
            title: "Jobs Today",
            value: "0",
            subtext: "1 last week",
            changePercentage: -14,
            iconName: "calendar",
            iconBackgroundColor: Color(hex: "#E6EEFF"),
            iconForegroundColor: Color(hex: "#3B82F6")
        )
    }
}

struct ActiveClientsCardView: View {
    var body: some View {
        DashboardCardView(
            title: "Active Clients",
            value: "4",
            subtext: "5 new this week",
            changePercentage: 5,
            iconName: "person.2.fill",
            iconBackgroundColor: Color(hex: "#E7F7EB"),
            iconForegroundColor: Color(hex: "#27AE60")
        )
    }
}

#Preview {
    VStack {
        JobsTodayCardView()
        ActiveClientsCardView()
    }
    .padding()
    .background(Color(hex: "#F5F5F5"))
} 