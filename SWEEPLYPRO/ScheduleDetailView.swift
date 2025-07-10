//
//  ScheduleDetailView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct ScheduleDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Calendar section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("July 2025")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#0A0A0A"))
                        
                        // Simple calendar grid placeholder
                        // In a real app, this would be a full calendar component
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(1..<32) { day in
                                Text("\(day)")
                                    .font(.system(size: 16))
                                    .frame(height: 40)
                                    .foregroundColor(day == 30 ? Color.white : Color(hex: "#0A0A0A"))
                                    .background(day == 30 ? Color(hex: "#246BFD") : Color.clear)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
                    
                    // Upcoming visits section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upcoming Visits")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#0A0A0A"))
                        
                        // Empty state
                        VStack {
                            Text("No upcoming visits")
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
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
                }
                .padding(16)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(hex: "#246BFD"))
                    }
                }
            }
        }
    }
}

#Preview {
    ScheduleDetailView()
} 