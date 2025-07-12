//
//  DashboardView.swift
//  SWEEPLYPRO
//
//  Created on 7/6/25.
//

import SwiftUI
import MapKit

struct DashboardView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    DashboardHeaderView()
                    
                    // Content sections
                    VStack(spacing: 16) {
                        // Map view section
                        DashboardMapView()
                            .padding(.top, 12)
                        
                        // Today's Schedule section
                        TodayScheduleView()
                        
                        // Daily Overview section
                        DailyOverviewView()
                        
                        // To Do List section
                        ToDoListView()
                        
                        // Business Health section
                        BusinessHealthView()
                        
                        // Discover section
                        DiscoverView()
                            .padding(.bottom, 120) // Reduced padding at the bottom
                    }
                    .padding(.horizontal, 8)
                }
                .background(Color(hex: "#F5F5F5"))
            }
            .background(Color(hex: "#F5F5F5"))
            .edgesIgnoringSafeArea(.bottom)
            
            // Tab Bar
            TabBarView(selectedTab: $selectedTab)
                .ignoresSafeArea(.all, edges: .bottom)
        }
        .background(Color(hex: "#F5F5F5"))
    }
}

// Daily Overview section
struct DailyOverviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            Text("Daily Overview")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#0A0A0A"))
                .padding(.horizontal, 8)
                .padding(.bottom, 2)
            
            // Overview cards
            VStack(spacing: 8) {
                // First row
                HStack(spacing: 8) {
                    // Jobs Completed card
                    CompactOverviewCard(
                        title: "Jobs Completed",
                        value: "3/8",
                        iconName: "checkmark.circle.fill",
                        gradient: [Color(hex: "#246BFD").opacity(0.8), Color(hex: "#246BFD")]
                    )
                    
                    // Hours Worked today card
                    CompactOverviewCard(
                        title: "Hours Worked",
                        value: "5.2 hrs",
                        iconName: "clock.fill",
                        gradient: [Color(hex: "#4CAF50").opacity(0.8), Color(hex: "#4CAF50")]
                    )
                }
                
                // Second row - 1 card
                CompactOverviewCard(
                    title: "Today's Priority",
                    value: "Complete project",
                    subtitle: "Due in 2 hours",
                    iconName: "star.fill",
                    gradient: [Color(hex: "#FF9800").opacity(0.8), Color(hex: "#FF9800")],
                    isWide: true
                )
            }
            .padding(.horizontal, 8)
        }
    }
}

// Compact Overview Card with modern design
struct CompactOverviewCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let iconName: String
    let gradient: [Color]
    var isWide: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Smaller icon with gradient background
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradient),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 26, height: 26)
                
                Image(systemName: iconName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.leading, 2)
            
            // Text content with more space
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#5D6A76"))
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#0A0A0A"))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#5D6A76"))
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .frame(maxWidth: .infinity)
        .frame(height: subtitle != nil ? 80 : 70)
    }
}

// Discover section view
struct DiscoverView: View {
    // Sample discover items
    let discoverItems: [DiscoverItem] = [
        DiscoverItem(
            title: "New Feature: Route Optimization",
            subtitle: "Save time and fuel with our new route planning tool.",
            iconName: "map",
            gradientColors: [Color(hex: "#34D399"), Color(hex: "#059669")],
            buttonLabel: "Learn More",
            buttonIcon: "arrow.right"
        ),
        DiscoverItem(
            title: "Tips for Growth",
            subtitle: "Read our latest guide on customer acquisition.",
            iconName: "chart.line.uptrend.xyaxis",
            gradientColors: [Color(hex: "#60A5FA"), Color(hex: "#2563EB")],
            buttonLabel: "Read Now",
            buttonIcon: "book"
        ),
        DiscoverItem(
            title: "Equipment Deals",
            subtitle: "Special offers on professional cleaning equipment.",
            iconName: "vacuum.fill",
            gradientColors: [Color(hex: "#F87171"), Color(hex: "#DC2626")],
            buttonLabel: "Shop Deals",
            buttonIcon: "tag"
        ),
        DiscoverItem(
            title: "Business Insurance",
            subtitle: "Protect your business with our partner offers.",
            iconName: "shield.fill",
            gradientColors: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")],
            buttonLabel: "Get Quote",
            buttonIcon: "shield"
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Discover")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#1A202C"))
                .padding(.horizontal, 8)
            
            // Carousel of cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(discoverItems) { item in
                        DiscoverCard(item: item)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
    }
}

// Discover card view
struct DiscoverCard: View {
    let item: DiscoverItem
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background with gradient
            LinearGradient(
                gradient: Gradient(colors: item.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: 280, height: 180)
            .cornerRadius(20)
            .overlay(
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.black.opacity(0.0),
                            Color.black.opacity(0.3)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(20)
            )
            
            // Icon
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: item.iconName)
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                }
                Spacer()
            }
            
            // Text overlay
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text(item.subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                Spacer()
                
                // Action button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // Button action
                    }) {
                        HStack(spacing: 4) {
                            Text(item.buttonLabel)
                                .font(.system(size: 14, weight: .medium))
                            
                            Image(systemName: item.buttonIcon)
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(16)
            .frame(width: 280, height: 180, alignment: .bottomLeading)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            
            // Reset after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
            }
        }
    }
}

// Discover item model
struct DiscoverItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let gradientColors: [Color]
    let buttonLabel: String
    let buttonIcon: String
}

#Preview {
    DashboardView()
} 