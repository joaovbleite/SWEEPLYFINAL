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
    @EnvironmentObject private var authManager: SupabaseAuthManager

    var body: some View {
        ZStack(alignment: .bottom) {
            // Simple stack of views with no swipe behavior
            ZStack {
                // Dashboard View (Home)
                DashboardView()
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .zIndex(selectedTab == 0 ? 1 : 0)
                
                // Schedule View
                ScheduleView()
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .zIndex(selectedTab == 1 ? 1 : 0)
                
                // Hub View (replacing ToDoListView)
                HubView()
                    .opacity(selectedTab == 3 ? 1 : 0)
                    .zIndex(selectedTab == 3 ? 1 : 0)
                
                // More View
                MoreView()
                    .environmentObject(authManager)
                    .opacity(selectedTab == 4 ? 1 : 0)
                    .zIndex(selectedTab == 4 ? 1 : 0)
            }
            
            TabBarView(selectedTab: $selectedTab)
        }
        .background(Color(hex: "#F5F5F5"))
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, Client.self, Task.self], inMemory: true)
}
