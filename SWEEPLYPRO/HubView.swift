//
//  HubView.swift
//  SWEEPLYPRO
//
//  Created on 7/10/25.
//

import SwiftUI
import SwiftData
import Charts

struct HubView: View {
    // State variables
    @State private var selectedPeriod = "This Month"
    @State private var showFinancialDetails = false
    @State private var showInvoiceList = false
    @State private var showPaymentHistory = false
    @State private var showExpenseTracker = false
    @State private var showTaxCalculator = false
    @State private var showReports = false
    @State private var showTeamManagement = false
    @State private var showTeamSchedule = false
    @State private var showTeamPerformance = false
    @State private var showTeamPayroll = false
    @State private var showAddTeamMember = false
    
    // Period options
    let periodOptions = ["This Week", "This Month", "This Quarter", "This Year", "All Time"]
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let positiveColor = Color(hex: "#4CAF50")
    let negativeColor = Color(hex: "#F44336")
    let cardBgColor = Color.white
    let borderColor = Color(hex: "#E5E5E5")
    
    // Mock financial data
    let revenue = 4250.00
    let expenses = 1275.50
    let profit = 2974.50
    let pendingPayments = 850.00
    let overduePayments = 350.00
    
    // Mock revenue data for chart
    let revenueData = [
        FinancialDataPoint(day: "Mon", amount: 450),
        FinancialDataPoint(day: "Tue", amount: 650),
        FinancialDataPoint(day: "Wed", amount: 850),
        FinancialDataPoint(day: "Thu", amount: 550),
        FinancialDataPoint(day: "Fri", amount: 950),
        FinancialDataPoint(day: "Sat", amount: 500),
        FinancialDataPoint(day: "Sun", amount: 300)
    ]
    
    // Mock expense categories
    let expenseCategories = [
        ExpenseCategory(name: "Supplies", amount: 450, color: Color(hex: "#246BFD")),
        ExpenseCategory(name: "Travel", amount: 325, color: Color(hex: "#FF9500")),
        ExpenseCategory(name: "Equipment", amount: 250, color: Color(hex: "#4CAF50")),
        ExpenseCategory(name: "Marketing", amount: 150, color: Color(hex: "#F44336")),
        ExpenseCategory(name: "Other", amount: 100.50, color: Color(hex: "#9C27B0"))
    ]
    
    // Mock team members
    let teamMembers = [
        TeamMember(name: "John Smith", role: "Cleaner", jobsCompleted: 24, rating: 4.8),
        TeamMember(name: "Sarah Johnson", role: "Cleaner", jobsCompleted: 18, rating: 4.9),
        TeamMember(name: "Mike Davis", role: "Cleaner", jobsCompleted: 15, rating: 4.7)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerView
                    
                    // Financial summary cards
                    financialSummaryView
                    
                    // Revenue chart
                    revenueChartView
                    
                    // Quick actions
                    quickActionsView
                    
                    // Financial management sections
                    financialManagementView
                    
                    // Team management section
                    teamManagementView
                    
                    // Spacer at bottom for tab bar
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(secondaryColor)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showFinancialDetails) {
            Text("Financial Details View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showExpenseTracker) {
            ExpenseTrackerView()
        }
        .sheet(isPresented: $showInvoiceList) {
            Text("Invoice List View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showPaymentHistory) {
            Text("Payment History View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showTaxCalculator) {
            Text("Tax Calculator View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showReports) {
            Text("Financial Reports View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showTeamManagement) {
            Text("Team Management View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showTeamSchedule) {
            Text("Team Schedule View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showTeamPerformance) {
            Text("Team Performance View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showTeamPayroll) {
            Text("Team Payroll View")
                .font(.title)
                .padding()
        }
        .sheet(isPresented: $showAddTeamMember) {
            Text("Add Team Member View")
                .font(.title)
                .padding()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Financial Hub")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
                
                Text("Manage your business finances")
                    .font(.system(size: 16))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            // Period selector
            Menu {
                ForEach(periodOptions, id: \.self) { period in
                    Button(period) {
                        selectedPeriod = period
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedPeriod)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(primaryColor)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(primaryColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(primaryColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Financial Summary View
    private var financialSummaryView: some View {
        VStack(spacing: 12) {
            // Revenue, Expenses, Profit row
            HStack(spacing: 12) {
                // Revenue card
                financialCard(
                    title: "Revenue",
                    amount: revenue,
                    trend: "+12%",
                    trendPositive: true,
                    icon: "arrow.up.right",
                    iconBgColor: positiveColor.opacity(0.1),
                    iconColor: positiveColor
                )
                
                // Expenses card
                financialCard(
                    title: "Expenses",
                    amount: expenses,
                    trend: "-5%",
                    trendPositive: true,
                    icon: "arrow.down.left",
                    iconBgColor: negativeColor.opacity(0.1),
                    iconColor: negativeColor
                )
            }
            
            // Profit card (full width)
            financialCard(
                title: "Net Profit",
                amount: profit,
                trend: "+18%",
                trendPositive: true,
                icon: "chart.line.uptrend.xyaxis",
                iconBgColor: positiveColor.opacity(0.1),
                iconColor: positiveColor,
                fullWidth: true
            )
            
            // Pending and Overdue payments row
            HStack(spacing: 12) {
                // Pending payments card
                financialCard(
                    title: "Pending",
                    amount: pendingPayments,
                    trend: "\(2) invoices",
                    trendPositive: nil,
                    icon: "hourglass",
                    iconBgColor: primaryColor.opacity(0.1),
                    iconColor: primaryColor
                )
                
                // Overdue payments card
                financialCard(
                    title: "Overdue",
                    amount: overduePayments,
                    trend: "\(1) invoice",
                    trendPositive: false,
                    icon: "exclamationmark.triangle",
                    iconBgColor: negativeColor.opacity(0.1),
                    iconColor: negativeColor
                )
            }
        }
    }
    
    // MARK: - Revenue Chart View
    private var revenueChartView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Revenue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Button(action: {
                    showFinancialDetails = true
                }) {
                    Text("Details")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(primaryColor)
                }
            }
            
            // Revenue chart
            Chart {
                ForEach(revenueData) { dataPoint in
                    BarMark(
                        x: .value("Day", dataPoint.day),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(6)
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Quick Actions View
    private var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            HStack(spacing: 12) {
                // Create Invoice
                quickActionButton(
                    icon: "doc.text.fill",
                    title: "Create Invoice",
                    color: Color(hex: "#246BFD"),
                    action: { showInvoiceList = true }
                )
                
                // Record Expense
                quickActionButton(
                    icon: "creditcard.fill",
                    title: "Record Expense",
                    color: Color(hex: "#FF9500"),
                    action: { showExpenseTracker = true }
                )
                
                // View Reports
                quickActionButton(
                    icon: "chart.bar.fill",
                    title: "View Reports",
                    color: Color(hex: "#4CAF50"),
                    action: { showReports = true }
                )
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Financial Management View
    private var financialManagementView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Management")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            // Invoices
            financialManagementItem(
                icon: "doc.text.fill",
                title: "Invoices",
                subtitle: "Manage all client invoices",
                action: { showInvoiceList = true }
            )
            
            // Payment History
            financialManagementItem(
                icon: "creditcard.fill",
                title: "Payment History",
                subtitle: "Track all incoming payments",
                action: { showPaymentHistory = true }
            )
            
            // Expense Tracker
            financialManagementItem(
                icon: "arrow.down.circle.fill",
                title: "Expense Tracker",
                subtitle: "Monitor your business expenses",
                action: { showExpenseTracker = true }
            )
            
            // Tax Calculator
            financialManagementItem(
                icon: "percent",
                title: "Tax Calculator",
                subtitle: "Estimate your tax obligations",
                action: { showTaxCalculator = true }
            )
            
            // Financial Reports
            financialManagementItem(
                icon: "chart.bar.fill",
                title: "Financial Reports",
                subtitle: "Generate detailed business reports",
                action: { showReports = true }
            )
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Team Management View
    private var teamManagementView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Management")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            // Team overview
            teamOverviewView
            
            // Team Members
            financialManagementItem(
                icon: "person.2.fill",
                title: "Team Members",
                subtitle: "Manage your cleaning staff",
                action: { showTeamManagement = true }
            )
            
            // Team Schedule
            financialManagementItem(
                icon: "calendar",
                title: "Team Schedule",
                subtitle: "View and assign work schedules",
                action: { showTeamSchedule = true }
            )
            
            // Performance Tracking
            financialManagementItem(
                icon: "chart.bar.xaxis",
                title: "Performance Tracking",
                subtitle: "Monitor team productivity and ratings",
                action: { showTeamPerformance = true }
            )
            
            // Payroll Management
            financialManagementItem(
                icon: "dollarsign.square.fill",
                title: "Payroll Management",
                subtitle: "Handle team member payments",
                action: { showTeamPayroll = true }
            )
            
            // Add Team Member button
            Button(action: { showAddTeamMember = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(primaryColor)
                    
                    Text("Add New Team Member")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(primaryColor)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(primaryColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Team overview cards
    private var teamOverviewView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Team size card
                teamOverviewCard(
                    title: "Team Size",
                    value: "\(teamMembers.count)",
                    icon: "person.3.fill",
                    color: primaryColor
                )
                
                // Jobs completed card
                let totalJobs = teamMembers.reduce(0) { $0 + $1.jobsCompleted }
                teamOverviewCard(
                    title: "Jobs Completed",
                    value: "\(totalJobs)",
                    icon: "checkmark.circle.fill",
                    color: positiveColor
                )
            }
            
            HStack(spacing: 12) {
                // Average rating card
                let avgRating = teamMembers.reduce(0.0) { $0 + $1.rating } / Double(teamMembers.count)
                teamOverviewCard(
                    title: "Avg. Rating",
                    value: String(format: "%.1f", avgRating),
                    icon: "star.fill",
                    color: Color(hex: "#FF9500")
                )
                
                // Scheduled jobs card
                teamOverviewCard(
                    title: "Scheduled Jobs",
                    value: "12",
                    icon: "calendar",
                    color: Color(hex: "#5856D6")
                )
            }
        }
    }
    
    // Team overview card
    private func teamOverviewCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and title
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(mutedTextColor)
            }
            
            // Value
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(textColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Views
    
    // Financial card view
    private func financialCard(title: String, amount: Double, trend: String, trendPositive: Bool?, icon: String, iconBgColor: Color, iconColor: Color, fullWidth: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and icon
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(mutedTextColor)
                
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBgColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(iconColor)
                }
            }
            
            // Amount
            Text("$\(String(format: "%.2f", amount))")
                .font(.system(size: fullWidth ? 24 : 20, weight: .bold))
                .foregroundColor(textColor)
            
            // Trend
            HStack(spacing: 4) {
                if let isPositive = trendPositive {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12))
                        .foregroundColor(isPositive ? positiveColor : negativeColor)
                }
                
                Text(trend)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(trendPositive == nil ? mutedTextColor : (trendPositive! ? positiveColor : negativeColor))
            }
        }
        .padding(16)
        .frame(maxWidth: fullWidth ? .infinity : nil)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Quick action button
    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // Financial management item
    private func financialManagementItem(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(primaryColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(mutedTextColor)
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Data Models

// Financial data point for chart
struct FinancialDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let amount: Double
}

// Expense category model
struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

// Team member model
struct TeamMember: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let jobsCompleted: Int
    let rating: Double
}

#Preview {
    HubView()
} 