//
//  DashboardView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    DashboardHeaderView()
                    
                    // Content sections
                    VStack(spacing: 24) {
                        // Today's Schedule section
                        TodayScheduleView()
                            .padding(.top, 16)
                        
                        // To Do List section
                        ToDoListView()
                        
                        // Business Health section
                        BusinessHealthView()
                        
                        // Discover section
                        DiscoverView()
                            .padding(.bottom, 150) // Added padding at the bottom
                    }
                    .padding(.horizontal, 8) // Reduced from 12 to 8
                }
                .background(Color(hex: "#F5F5F5"))
            }
            .background(Color(hex: "#F5F5F5")) // Keep background color for ScrollView
            .edgesIgnoringSafeArea(.bottom) // Only ignore safe area at the bottom
            
            // Tab Bar
            TabBarView(selectedTab: $selectedTab)
                .ignoresSafeArea(.all, edges: .bottom)
        }
        .background(Color(hex: "#F5F5F5")) // Keep background color for entire view
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