//
//  ContentView.swift
//  SWEEPLYPRO
//
//  Created by Joao Leite on 7/2/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var selectedTab = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Simple stack of views with no swipe behavior
                ZStack {
                    // Dashboard View (Home)
                    DashboardView()
                        .opacity(selectedTab == 0 ? 1 : 0)
                        .zIndex(selectedTab == 0 ? 1 : 0)
                    
                    // Schedule View
                    TodayScheduleView()
                        .opacity(selectedTab == 1 ? 1 : 0)
                        .zIndex(selectedTab == 1 ? 1 : 0)
                    
                    // ToDo List View (Hub)
                    ToDoListView()
                        .opacity(selectedTab == 3 ? 1 : 0)
                        .zIndex(selectedTab == 3 ? 1 : 0)
                    
                    // More View
                    MoreView()
                        .opacity(selectedTab == 4 ? 1 : 0)
                        .zIndex(selectedTab == 4 ? 1 : 0)
                }
                .padding(.top, geometry.safeAreaInsets.top) // Add padding for status bar
                
                TabBarView(selectedTab: $selectedTab)
                
                // Status bar blur overlay
                VStack {
                    // Use the actual safe area inset height
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    
                    Spacer()
                }
                .zIndex(999) // Ensure it's above everything
            }
            .background(Color(hex: "#F5F5F5"))
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
