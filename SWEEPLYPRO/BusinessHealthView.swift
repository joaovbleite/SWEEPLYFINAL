//
//  BusinessHealthView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct BusinessHealthStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let timeframe: String
    let percentageChange: Int
}

struct BusinessHealthView: View {
    @State private var showBusinessHealthDetail = false
    
    let businessStats = [
        BusinessHealthStat(
            title: "Job value",
            value: "$200",
            timeframe: "This week (Jun 29 - Jul 5)",
            percentageChange: 100
        ),
        BusinessHealthStat(
            title: "Visits scheduled",
            value: "2",
            timeframe: "This week (Jun 29 - Jul 5)",
            percentageChange: 100
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header with "View all" link
            HStack {
                Text("Business health")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#0A0A0A"))
                
                Spacer()
                
                Button(action: {
                    showBusinessHealthDetail = true
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
            
            // Business stats
            VStack(spacing: 0) {
                ForEach(businessStats) { stat in
                    BusinessStatItemView(stat: stat)
                    
                    // Add divider between items (except after the last one)
                    if stat.id != businessStats.last?.id {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 8)
        .sheet(isPresented: $showBusinessHealthDetail) {
            BusinessHealthDetailView()
        }
    }
}

struct BusinessStatItemView: View {
    let stat: BusinessHealthStat
    
    var body: some View {
        HStack(alignment: .center) {
            // Left side - title and timeframe
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#0A0A0A"))
                
                Text(stat.timeframe)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#7D8A99"))
            }
            
            Spacer()
            
            // Right side - value and percentage badge
            HStack(spacing: 12) {
                Text(stat.value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                // Percentage badge
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#246BFD"))
                    
                    Text("\(stat.percentageChange)%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#246BFD"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "#E6F0FF"))
                .cornerRadius(16)
            }
        }
        .padding(16)
    }
}

#Preview {
    BusinessHealthView()
        .padding(.vertical)
        .background(Color(hex: "#F5F5F5"))
} 