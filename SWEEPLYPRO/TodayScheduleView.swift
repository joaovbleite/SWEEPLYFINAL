//
//  TodayScheduleView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct TodayScheduleView: View {
    // In a real app, this would be populated from a data source
    let hasScheduledVisits = false
    @State private var showScheduleDetail = false
    @State private var showNewJobForm = false // Add state for new job form
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header with "View all" link
            HStack {
                Text("Today's Schedule")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#0A0A0A"))
                
                Spacer()
                
                Button(action: {
                    showScheduleDetail = true
                }) {
                    HStack(spacing: 4) {
                        Text("View all")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#246BFD"))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#246BFD"))
                    }
                }
            }
            
            // Horizontal scrolling carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Empty state card
                    if !hasScheduledVisits {
                        VStack(alignment: .center) {
                            Spacer()
                            Text("No visits scheduled today")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: "#5D6A76"))
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .frame(width: 280, height: 80)
                        .background(Color(hex: "#F8F8F6"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                        )
                    } else {
                        // In a real app, we would display scheduled visits here
                        // This is just a placeholder for the implementation
                        Text("Scheduled visits would appear here")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#5D6A76"))
                            .frame(width: 280, height: 80)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    // Schedule a New Job card
                    Button(action: {
                        showNewJobForm = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "#4CAF50"))
                            
                            Text("Schedule a New Job")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#4CAF50"))
                        }
                        .frame(width: 280, height: 80)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#4CAF50"), lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 2)
            }
            .padding(.vertical, 2)
        }
        .padding(.horizontal, 8)
        .sheet(isPresented: $showScheduleDetail) {
            ScheduleDetailView()
        }
        // Add sheet for new job form when it's created
        .sheet(isPresented: $showNewJobForm) {
            // Replace with actual new job form view when available
            Text("New Job Form")
                .font(.largeTitle)
                .padding()
        }
    }
}

#Preview {
    TodayScheduleView()
        .padding(.vertical)
        .background(Color(hex: "#F5F5F5"))
} 