//
//  BusinessHealthView.swift
//  SWEEPLYFINAL
//
//  Created by Joao Leite on 6/30/25.
//

import SwiftUI

struct BusinessHealthView: View {
    // Sample data for business health metrics
    private let currentWeekData = [
        BusinessMetric(title: "Job value", value: "$200", subtitle: "This week (Jun 29 - Jul 5)", trend: "+100%", isPositive: true),
        BusinessMetric(title: "Visits scheduled", value: "2", subtitle: "This week (Jun 29 - Jul 5)", trend: "+100%", isPositive: true),
        BusinessMetric(title: "Invoices paid", value: "$0", subtitle: "This week (Jun 29 - Jul 5)", trend: "0%", isPositive: false),
        BusinessMetric(title: "Average job value", value: "$100", subtitle: "This week (Jun 29 - Jul 5)", trend: "+25%", isPositive: true)
    ]
    
    private let monthlyData = [
        BusinessMetric(title: "Monthly revenue", value: "$800", subtitle: "June 2025", trend: "+15%", isPositive: true),
        BusinessMetric(title: "Total jobs", value: "8", subtitle: "June 2025", trend: "+33%", isPositive: true)
    ]
    
    private let yearlyData = [
        BusinessMetric(title: "Year-to-date revenue", value: "$4,200", subtitle: "2025", trend: "+22%", isPositive: true),
        BusinessMetric(title: "Total clients", value: "12", subtitle: "Active in 2025", trend: "+50%", isPositive: true)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) { // section_gap from design system
                    // Weekly metrics section
                    sectionView(title: "This week", metrics: currentWeekData)
                    
                    // Monthly metrics section
                    sectionView(title: "Monthly overview", metrics: monthlyData)
                    
                    // Yearly metrics section
                    sectionView(title: "Year-to-date", metrics: yearlyData)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(hex: "#FFFFFF"))
            }
            .navigationTitle("Business Health")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Section View
    private func sectionView(title: String, metrics: [BusinessMetric]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A1A"))
            
            // Metrics
            VStack(spacing: 12) {
                ForEach(metrics) { metric in
                    metricRow(metric: metric)
                    
                    if metric.id != metrics.last?.id {
                        Divider()
                            .background(Color(hex: "#E5E7EB"))
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Metric Row
    private func metricRow(metric: BusinessMetric) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                // Title
                Text(metric.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#4B5563"))
                
                Spacer()
                
                // Value
                Text(metric.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#111827"))
            }
            
            HStack(alignment: .center) {
                // Subtitle
                Text(metric.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#6B7280"))
                
                Spacer()
                
                // Trend badge
                if metric.isPositive {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12))
                        Text(metric.trend)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#E6EEFF"))
                    .foregroundColor(Color(hex: "#3B82F6"))
                    .cornerRadius(16)
                } else {
                    Text(metric.trend)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#F3F4F6"))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                        .cornerRadius(16)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Business Metric Model
struct BusinessMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let trend: String
    let isPositive: Bool
}

// MARK: - Preview
struct BusinessHealthView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessHealthView()
    }
} 