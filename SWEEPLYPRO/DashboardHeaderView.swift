//
//  DashboardHeaderView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct DashboardHeaderView: View {
    @State private var currentDate = Date()
    @State private var notificationCount = 9
    @State private var showNotifications = false
    @State private var showAIChat = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(formattedDate())
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#5E7380"))
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Star plus icon
                    Button(action: {
                        showAIChat = true
                    }) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                    
                    // Notification bell with badge
                    Button(action: {
                        showNotifications = true
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#1A1A1A"))
                            
                            if notificationCount > 0 {
                                Text("\(notificationCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color(hex: "#FF3B30"))
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
            
            // Divider line
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(hex: "#E5E5E5"))
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(Color(hex: "#F5F5F5"))
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $showAIChat) {
            AIChatView()
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d'th'"
        return formatter.string(from: currentDate)
    }
}

#Preview {
    DashboardHeaderView()
} 