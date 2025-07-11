//
//  TabBarView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI
import UIKit

// Haptic feedback utility class
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

struct TabBarView: View {
    @Binding var selectedTab: Int
    @State private var showActionMenu = false
    @State private var showNewTaskView = false
    @State private var showNewClientView = false
    @State private var showNewInvoiceView = false
    @State private var showNewQuoteView = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent background overlay when menu is shown
            if showActionMenu {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showActionMenu = false
                        }
                    }
            }
            
            // Action menu items (visible when showActionMenu is true)
            if showActionMenu {
                VStack(spacing: 12) {
                    Spacer()
                    
                    // Task button
                    ActionButton(
                        label: "Task",
                        icon: "checkmark.square",
                        iconColor: Color(hex: "#246BFD")
                    ) {
                        // Handle Task action
                        showActionMenu = false
                        showNewTaskView = true
                    }
                    
                    // Invoice button
                    ActionButton(
                        label: "Invoice",
                        icon: "doc.text.fill",
                        iconColor: Color(hex: "#246BFD")
                    ) {
                        // Handle Invoice action
                        showActionMenu = false
                        showNewInvoiceView = true
                    }
                    
                    // Quote button
                    ActionButton(
                        label: "Quote",
                        icon: "doc.badge.gearshape.fill",
                        iconColor: Color(hex: "#246BFD")
                    ) {
                        // Handle Quote action
                        showActionMenu = false
                        showNewQuoteView = true
                    }
                    
                    // Client button
                    ActionButton(
                        label: "Client",
                        icon: "person.fill",
                        iconColor: Color(hex: "#5E7380")
                    ) {
                        // Handle Client action
                        showActionMenu = false
                        showNewClientView = true
                    }
                    
                    // Job button
                    ActionButton(
                        label: "Job",
                        icon: "briefcase.fill",
                        iconColor: Color(hex: "#4CAF50")
                    ) {
                        // Handle Job action
                        showActionMenu = false
                    }
                    
                    // Space for the FAB and tab bar
                    Spacer().frame(height: 90)
                }
                .padding(.horizontal, 40) // Increased horizontal padding to reduce width
                .frame(maxWidth: .infinity)
                .zIndex(2) // Ensure menu is above the overlay
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Tab bar container - always visible
            ZStack {
                // Main tab bar
                HStack {
                    Spacer()
                    
                    // Home tab
                    TabBarButton(
                        icon: "house.fill",
                        label: "Home",
                        isSelected: selectedTab == 0
                    ) {
                        if selectedTab != 0 {
                            HapticManager.shared.impact(style: .light)
                            selectedTab = 0
                        }
                    }
                    
                    Spacer()
                    
                    // Schedule tab
                    TabBarButton(
                        icon: "calendar",
                        label: "Schedule",
                        isSelected: selectedTab == 1
                    ) {
                        if selectedTab != 1 {
                            HapticManager.shared.impact(style: .light)
                            selectedTab = 1
                        }
                    }
                    
                    // Spacer for center button
                    Spacer()
                        .frame(width: 70)
                    
                    // Hub tab
                    TabBarButton(
                        icon: "dollarsign.circle.fill",
                        label: "Hub",
                        isSelected: selectedTab == 3
                    ) {
                        if selectedTab != 3 {
                            HapticManager.shared.impact(style: .light)
                            selectedTab = 3
                        }
                    }
                    
                    Spacer()
                    
                    // More tab
                    TabBarButton(
                        icon: "ellipsis",
                        label: "More",
                        isSelected: selectedTab == 4
                    ) {
                        if selectedTab != 4 {
                            HapticManager.shared.impact(style: .light)
                            selectedTab = 4
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 32) // Increased bottom padding even more
                .background(
                    Color.white
                        .edgesIgnoringSafeArea(.bottom)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: -2)
                
                // Center floating action button
                Button(action: {
                    HapticManager.shared.impact(style: .medium)
                    withAnimation(.spring()) {
                        showActionMenu.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#052017"))
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
                        
                        Image(systemName: showActionMenu ? "xmark" : "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -15) // Move up to overlap the tab bar
                .zIndex(3) // Ensure FAB is above everything
            }
            .zIndex(2) // Ensure tab bar is above the overlay but below the menu
        }
        .sheet(isPresented: $showNewTaskView) {
            NewTaskView()
        }
        .sheet(isPresented: $showNewClientView) {
            NewClientView()
        }
        .sheet(isPresented: $showNewInvoiceView) {
            NewInvoiceView()
        }
        .sheet(isPresented: $showNewQuoteView) {
            NewQuoteView()
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
    }
}

struct ActionButton: View {
    let label: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            action()
        }) {
            HStack {
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(iconColor)
                    .cornerRadius(16)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.white)
            .cornerRadius(100)
            .shadow(color: Color.black.opacity(0.08), radius: 3, y: 1)
            .frame(maxWidth: 300) // Limit the maximum width of buttons
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color(hex: "#001E2B") : Color(hex: "#8D9BA8"))
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color(hex: "#001E2B") : Color(hex: "#8D9BA8"))
            }
        }
    }
}

#Preview {
    TabBarView(selectedTab: .constant(0))
} 