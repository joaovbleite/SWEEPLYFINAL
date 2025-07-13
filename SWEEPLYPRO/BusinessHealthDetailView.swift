//
//  BusinessHealthDetailView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

// MARK: - Filter Models
enum FilterPeriod: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisQuarter = "This Quarter"
    case thisYear = "This Year"
    case allTime = "All Time"
}

enum FilterMetricType: String, CaseIterable {
    case all = "All Metrics"
    case revenue = "Revenue"
    case jobs = "Jobs"
    case clients = "Clients"
    case performance = "Performance"
}

enum FilterCategory: String, CaseIterable {
    case all = "All Categories"
    case financial = "Financial"
    case operational = "Operational"
    case growth = "Growth"
}

struct BusinessHealthDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Filter states
    @State private var showFilterSheet = false
    @State private var selectedPeriod: FilterPeriod = .thisMonth
    @State private var selectedMetricType: FilterMetricType = .all
    @State private var selectedCategory: FilterCategory = .all
    @State private var showOnlyPositiveGrowth = false
    @State private var minimumValue: Double = 0
    
    // Sample data that will be filtered
    @State private var allMetrics: [BusinessMetric] = [
        BusinessMetric(title: "Revenue", value: "$1,250", category: .financial, type: .revenue, growth: 12, period: .thisMonth),
        BusinessMetric(title: "Completed Jobs", value: "8", category: .operational, type: .jobs, growth: 25, period: .thisMonth),
        BusinessMetric(title: "New Clients", value: "3", category: .growth, type: .clients, growth: 50, period: .thisMonth),
        BusinessMetric(title: "Average Job Value", value: "$156", category: .financial, type: .revenue, growth: -5, period: .thisMonth),
        BusinessMetric(title: "Client Retention", value: "95%", category: .operational, type: .performance, growth: 8, period: .thisMonth),
        BusinessMetric(title: "Monthly Recurring Revenue", value: "$890", category: .financial, type: .revenue, growth: 15, period: .thisMonth),
        BusinessMetric(title: "Job Completion Rate", value: "92%", category: .operational, type: .performance, growth: 3, period: .thisMonth),
        BusinessMetric(title: "Customer Satisfaction", value: "4.8", category: .growth, type: .performance, growth: 20, period: .thisMonth)
    ]
    
    // Computed property for filtered metrics
    var filteredMetrics: [BusinessMetric] {
        allMetrics.filter { metric in
            // Filter by period
            if selectedPeriod != .allTime && metric.period != selectedPeriod {
                return false
            }
            
            // Filter by metric type
            if selectedMetricType != .all && metric.type != selectedMetricType {
                return false
            }
            
            // Filter by category
            if selectedCategory != .all && metric.category != selectedCategory {
                return false
            }
            
            // Filter by positive growth only
            if showOnlyPositiveGrowth && metric.growth <= 0 {
                return false
            }
            
            return true
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Filter summary
                    if hasActiveFilters {
                        filterSummaryView
                    }
                    
                    // Filtered content
                    if filteredMetrics.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(filteredMetrics, id: \.title) { metric in
                            BusinessHealthDetailCard(metric: metric)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Business Health")
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFilterSheet = true
                    }) {
                        ZStack {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22))
                                .foregroundColor(hasActiveFilters ? Color(hex: "#246BFD") : Color(hex: "#5E7380"))
                            
                            // Active filter indicator
                            if hasActiveFilters {
                                Circle()
                                    .fill(Color(hex: "#FF4444"))
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
        }
    }
}
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(
                selectedPeriod: $selectedPeriod,
                selectedMetricType: $selectedMetricType,
                selectedCategory: $selectedCategory,
                showOnlyPositiveGrowth: $showOnlyPositiveGrowth,
                minimumValue: $minimumValue,
                onReset: resetFilters
            )
        }
    }
    
    // MARK: - Helper Properties
    private var hasActiveFilters: Bool {
        selectedPeriod != .thisMonth || 
        selectedMetricType != .all || 
        selectedCategory != .all || 
        showOnlyPositiveGrowth || 
        minimumValue > 0
    }
    
    // MARK: - Filter Summary View
    private var filterSummaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Filters")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#246BFD"))
                
                Spacer()
                
                Button("Clear All") {
                    resetFilters()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#246BFD"))
            }
            
            // Filter tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if selectedPeriod != .thisMonth {
                        FilterTag(text: selectedPeriod.rawValue) {
                            selectedPeriod = .thisMonth
                        }
                    }
                    
                    if selectedMetricType != .all {
                        FilterTag(text: selectedMetricType.rawValue) {
                            selectedMetricType = .all
                        }
                    }
                    
                    if selectedCategory != .all {
                        FilterTag(text: selectedCategory.rawValue) {
                            selectedCategory = .all
                        }
                    }
                    
                    if showOnlyPositiveGrowth {
                        FilterTag(text: "Positive Growth") {
                            showOnlyPositiveGrowth = false
                        }
                    }
                    
                    if minimumValue > 0 {
                        FilterTag(text: "Min Value: $\(Int(minimumValue))") {
                            minimumValue = 0
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "#E5E7EB"))
            
            Text("No metrics match your filters")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "#5E7380"))
            
            Text("Try adjusting your filter criteria to see more results")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#9CA3AF"))
                .multilineTextAlignment(.center)
            
            Button("Reset Filters") {
                resetFilters()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(hex: "#246BFD"))
            .cornerRadius(8)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Functions
    private func resetFilters() {
        selectedPeriod = .thisMonth
        selectedMetricType = .all
        selectedCategory = .all
        showOnlyPositiveGrowth = false
        minimumValue = 0
    }
}

// MARK: - Filter Tag Component
struct FilterTag: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#246BFD"))
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "#246BFD"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(hex: "#E6F0FF"))
        .cornerRadius(16)
    }
}

// MARK: - Enhanced Business Metric Model
struct BusinessMetric {
    let title: String
    let value: String
    let category: FilterCategory
    let type: FilterMetricType
    let growth: Double
    let period: FilterPeriod
}

// MARK: - Enhanced Business Health Detail Card
struct BusinessHealthDetailCard: View {
    let metric: BusinessMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header with category badge
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(metric.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#0A0A0A"))
            
                    Text(metric.category.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#7D8A99"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#F5F5F5"))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Growth indicator
                HStack(spacing: 2) {
                    Image(systemName: metric.growth >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12))
                        .foregroundColor(metric.growth >= 0 ? Color(hex: "#4CAF50") : Color(hex: "#F44336"))
                    
                    Text("\(abs(Int(metric.growth)))%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(metric.growth >= 0 ? Color(hex: "#4CAF50") : Color(hex: "#F44336"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(metric.growth >= 0 ? Color(hex: "#E8F5E8") : Color(hex: "#FFEBEE"))
                .cornerRadius(16)
            }
            
            // Main value
            HStack {
                Text(metric.value)
                    .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                
                Spacer()
                
                Text(metric.period.rawValue)
                        .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#7D8A99"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Filter Sheet View
struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedPeriod: FilterPeriod
    @Binding var selectedMetricType: FilterMetricType
    @Binding var selectedCategory: FilterCategory
    @Binding var showOnlyPositiveGrowth: Bool
    @Binding var minimumValue: Double
    
    let onReset: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Period Filter
                    FilterSection(title: "Time Period") {
                        ForEach(FilterPeriod.allCases, id: \.self) { period in
                            FilterOption(
                                title: period.rawValue,
                                isSelected: selectedPeriod == period
                            ) {
                                selectedPeriod = period
                            }
                        }
                    }
                    
                    // Metric Type Filter
                    FilterSection(title: "Metric Type") {
                        ForEach(FilterMetricType.allCases, id: \.self) { type in
                            FilterOption(
                                title: type.rawValue,
                                isSelected: selectedMetricType == type
                            ) {
                                selectedMetricType = type
                            }
                        }
                    }
                    
                    // Category Filter
                    FilterSection(title: "Category") {
                        ForEach(FilterCategory.allCases, id: \.self) { category in
                            FilterOption(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    
                    // Advanced Filters
                    FilterSection(title: "Advanced") {
                        // Positive Growth Toggle
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Show only positive growth")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#1A1A1A"))
                                
                                Text("Filter metrics with positive trends only")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#7D8A99"))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $showOnlyPositiveGrowth)
                                .tint(Color(hex: "#246BFD"))
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Minimum Value Slider
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Minimum Value")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "#1A1A1A"))
                                
                                Spacer()
                                
                                Text("$\(Int(minimumValue))")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#246BFD"))
                            }
                            
                            Slider(value: $minimumValue, in: 0...5000, step: 50)
                                .tint(Color(hex: "#246BFD"))
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Filter Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        onReset()
                    }
                    .foregroundColor(Color(hex: "#F44336"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#246BFD"))
                    .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - Filter Section Component
struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A1A"))
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Filter Option Component
struct FilterOption: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#1A1A1A"))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#246BFD"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "#E6F0FF") : Color.clear)
        }
    }
}

#Preview {
    BusinessHealthDetailView()
} 