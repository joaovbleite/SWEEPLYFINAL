//
//  DashboardOverviewCard.swift
//  SWEEPLYFINAL
//
//  Created by Joao Leite on 6/30/25.
//

import SwiftUI

struct DashboardOverviewCard: View {
    enum ChangeDirection {
        case up, down, none
    }
    
    let title: String
    let value: String
    let subtitleText: String
    let changeValue: String
    let changeDirection: ChangeDirection
    let iconName: String
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(iconForegroundColor)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "#5E7380"))
                    .lineLimit(1)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1A"))
            
            HStack(spacing: 6) {
                Text(subtitleText)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#8B99A6"))
                    .lineLimit(1)
                
                Spacer()
                
                if changeDirection != .none {
                    HStack(spacing: 2) {
                        Image(systemName: changeDirection == .up ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12))
                        Text(changeValue)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(changeDirection == .up ? Color(hex: "#2ECC71") : Color(hex: "#FF3B30"))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
        .frame(maxWidth: .infinity)
    }
}

struct DashboardOverviewCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
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
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 