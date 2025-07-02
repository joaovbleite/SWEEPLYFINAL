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
    @State private var showBusinessHealth = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with date and icons
                headerView
                
                ScrollView {
                    VStack(spacing: 24) { // Using section_gap from design system
                        // Stats cards
                        GeometryReader { geometry in
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
                                .frame(width: (geometry.size.width - 44) / 2)  // 44 = horizontal padding (16*2) + spacing (12)
                                
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
                                .frame(width: (geometry.size.width - 44) / 2)  // 44 = horizontal padding (16*2) + spacing (12)
                            }
                            .padding(.horizontal, 16)
                        }
                        .frame(height: 130)  // Set a fixed height for the cards
                        .padding(.top, 16)
                        
                        // Today's Schedule Section
                        VStack(spacing: 12) {
                            HStack {
                                Text("Today's Schedule")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "#0A0A0A"))
                                
                                Spacer()
                                
                                Button(action: {
                                    // View all action
                                }) {
                                    HStack(spacing: 4) {
                                        Text("View all")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "#246BFD"))
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(hex: "#246BFD"))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Empty state for schedule
                            VStack {
                                Text("No visits scheduled today")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#5D6A76"))
                                    .padding(20)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                        }
                        
                        // To Do List Section
                        VStack(spacing: 12) {
                            HStack {
                                Text("To do")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "#0A0A0A"))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            
                            // To do items
                            VStack(spacing: 0) {
                                // Item 1
                                todoItem(
                                    icon: "doc.text",
                                    title: "Create a winning quote",
                                    subtitle: "Boost your revenue with custom quotes"
                                )
                                
                                Divider()
                                    .background(Color(hex: "#E0E0E0"))
                                    .padding(.leading, 60)
                                
                                // Item 2
                                todoItem(
                                    icon: "person.badge.plus",
                                    title: "Add your first client",
                                    subtitle: "Start building your customer database"
                                )
                                
                                Divider()
                                    .background(Color(hex: "#E0E0E0"))
                                    .padding(.leading, 60)
                                
                                // Item 3
                                todoItem(
                                    icon: "desktopcomputer",
                                    title: "Try Sweeply on desktop",
                                    subtitle: "Check out the full suite of time-saving features"
                                )
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                            .padding(.horizontal, 16)
                        }
                        
                        // Business Health Section
                        VStack(spacing: 12) {
                            HStack {
                                Text("Business health")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "#0A0A0A"))
                                
                                Spacer()
                                
                                NavigationLink(destination: BusinessHealthView(), isActive: $showBusinessHealth) {
                                    EmptyView()
                                }
                                
                                Button(action: {
                                    showBusinessHealth = true
                                }) {
                                    HStack(spacing: 4) {
                                        Text("View all")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "#246BFD"))
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(hex: "#246BFD"))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Business health stats
                            VStack(spacing: 0) {
                                // Job value stat
                                businessStatItem(
                                    title: "Job value",
                                    subtitle: "This week (Jun 29 - Jul 5)",
                                    value: "$200",
                                    percentage: "100%"
                                )
                                
                                Divider()
                                    .background(Color(hex: "#E0E0E0"))
                                    .padding(.horizontal, 16)
                                
                                // Visits scheduled stat
                                businessStatItem(
                                    title: "Visits scheduled",
                                    subtitle: "This week (Jun 29 - Jul 5)",
                                    value: "2",
                                    percentage: "100%"
                                )
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                            .padding(.horizontal, 16)
                        }
                        
                        // Add spacing at the bottom to account for tab bar
                        Spacer()
                            .frame(height: 80)
                    }
                }
            }
            .background(Color(hex: "#f2f2f2"))
            .navigationBarHidden(true)
            .overlay(
                tabBar,
                alignment: .bottom
            )
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
    
    // MARK: - To Do Item
    private func todoItem(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "#EAF0FF"))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#246BFD"))
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#5D6A76"))
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#8D9BA8"))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Business Stat Item
    private func businessStatItem(title: String, subtitle: String, value: String, percentage: String) -> some View {
        HStack {
            // Title and subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#7D8A99"))
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#7D8A99"))
            }
            
            Spacer()
            
            // Value and percentage
            HStack(spacing: 12) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 12))
                    Text(percentage)
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "#E6F0FF"))
                .foregroundColor(Color(hex: "#246BFD"))
                .cornerRadius(12)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Tab Bar
    private var tabBar: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // Home tab
            VStack(spacing: 4) {
                Image(systemName: "house.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#001E2B"))
                
                Text("Home")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#001E2B"))
            }
            .frame(maxWidth: .infinity)
            
            // Schedule tab
            VStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#8D9BA8"))
                
                Text("Schedule")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8D9BA8"))
            }
            .frame(maxWidth: .infinity)
            
            // Center add button
            ZStack {
                Circle()
                    .fill(Color(hex: "#052017"))
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .offset(y: -15)
            .frame(maxWidth: .infinity)
            
            // Hub tab
            VStack(spacing: 4) {
                Image(systemName: "person")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#8D9BA8"))
                
                Text("Hub")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8D9BA8"))
            }
            .frame(maxWidth: .infinity)
            
            // More tab
            VStack(spacing: 4) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#8D9BA8"))
                
                Text("More")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8D9BA8"))
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 24) // Add extra padding for safe area
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
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