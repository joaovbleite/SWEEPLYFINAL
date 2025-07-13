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
    @State private var selectedTab = "Overview" // Add tab state
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
    @State private var showClientManagement = false
    @State private var showNewInvoice = false
    
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
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Tab selector section
                        tabSelectorSection
                            .padding(.horizontal, 16)
                        
                        // Conditional content based on selected tab
                        if selectedTab == "Overview" {
                            // Overview content
                            VStack(spacing: 20) {
                                // Overview cards
                                overviewCardsSection
                            .padding(.horizontal, 16)
                        
                                // Quick actions (moved from Finance tab)
                                quickActionsView
                                    .padding(.horizontal, 16)
                            }
                        } else {
                            // Finance content
                            VStack(spacing: 20) {
                        // Revenue chart
                        revenueChartView
                            .padding(.horizontal, 16)
                        
                        // Financial management sections
                        financialManagementView
                            .padding(.horizontal, 16)
                            }
                        }
                        
                        // Team management section (always visible)
                        teamManagementView
                            .padding(.horizontal, 16)
                        
                        // Spacer at bottom for tab bar
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showFinancialDetails) {
            FinancialDetailsView()
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
            TeamManagementView()
        }
        .sheet(isPresented: $showTeamSchedule) {
            TeamScheduleView()
        }
        .sheet(isPresented: $showTeamPerformance) {
            TeamPerformanceView()
        }
        .sheet(isPresented: $showTeamPayroll) {
            TeamPayrollView()
        }
        .sheet(isPresented: $showAddTeamMember) {
            AddTeamMemberView { newMember in
                // This closure is not used in the current HubView,
                // but it's passed to AddTeamMemberView.
                // If you want to update the teamMembers list in HubView,
                // you would need to manage the state here.
            }
        }
        .sheet(isPresented: $showClientManagement) {
            ClientManagementView()
        }
        .sheet(isPresented: $showNewInvoice) {
            NewInvoiceView()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top row with title and actions
            HStack {
                // Title and subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text("Financial Hub")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Manage your business finances")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Notification button
                Button(action: {
                    // Action for notifications
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        // Notification indicator
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(primaryColor, lineWidth: 1)
                            )
                            .offset(x: 8, y: -8)
                    }
                }
                .padding(.trailing, 8)
                
                // Profile button
                Button(action: {
                    // Action for profile
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Search and period selector row
            HStack(spacing: 12) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                    
                    Text("Search transactions, invoices...")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                
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
                            .foregroundColor(.white)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            
            // Business summary row
            HStack(spacing: 20) {
                // Revenue summary
                VStack(alignment: .leading, spacing: 4) {
                    Text("Revenue")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("$\(String(format: "%.2f", revenue))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1, height: 30)
                
                // Profit summary
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profit")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("$\(String(format: "%.2f", profit))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Growth indicator
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    
                    Text("+18%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
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
                    action: { showNewInvoice = true }
                )
                
                // Record Expense
                quickActionButton(
                    icon: "person.2.fill",
                    title: "Manage Clients",
                    color: Color(hex: "#FF9500"),
                    action: { showClientManagement = true }
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
            
            // Single row for scheduled jobs (centered)
            HStack {
                Spacer()
                
                // Scheduled jobs card
                teamOverviewCard(
                    title: "Scheduled Jobs",
                    value: "12",
                    icon: "calendar",
                    color: Color(hex: "#5856D6")
                )
                .frame(maxWidth: .infinity)
                
                Spacer()
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
    
    // MARK: - Tab Selector Section
    private var tabSelectorSection: some View {
        VStack(spacing: 16) {
            // Section tabs
            HStack(spacing: 0) {
                // Overview tab
                Button(action: {
                    selectedTab = "Overview"
                }) {
                    Text("Overview")
                        .font(.system(size: 16, weight: selectedTab == "Overview" ? .semibold : .medium))
                        .foregroundColor(selectedTab == "Overview" ? .white : mutedTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == "Overview" ? primaryColor : Color.white)
                        .cornerRadius(12)
                }
                
                // Finance tab
                Button(action: {
                    selectedTab = "Finance"
                }) {
                    Text("Finance")
                        .font(.system(size: 16, weight: selectedTab == "Finance" ? .semibold : .medium))
                        .foregroundColor(selectedTab == "Finance" ? .white : mutedTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == "Finance" ? primaryColor : Color.white)
                        .cornerRadius(12)
                }
            }
            .padding(4)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Overview Cards Section
    private var overviewCardsSection: some View {
        VStack(spacing: 12) {
            // Top row - Clients and Chats
            HStack(spacing: 12) {
                // Clients card
                overviewCard(
                    title: "Clients",
                    mainValue: "40",
                    details: [
                        ("One Time", "0"),
                        ("Recurring", "30")
                    ],
                    icon: "person.3.fill",
                    isPrimary: true
                )
                
                // Chats card
                overviewCard(
                    title: "Chats",
                    mainValue: "0",
                    details: [
                        ("unread", "")
                    ],
                    icon: "message.fill",
                    isPrimary: true
                )
            }
            
            // Bottom row - Jobs only (centered)
            HStack {
                Spacer()
                
                // Jobs card
                overviewCard(
                    title: "Jobs",
                    mainValue: "10",
                    subtitle: "This Week",
                    details: [
                        ("One Time", "0"),
                        ("Recurring", "10")
                    ],
                    icon: "hand.sparkles.fill",
                    isPrimary: true
                )
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Overview Card Helper
    private func overviewCard(
        title: String,
        mainValue: String,
        subtitle: String? = nil,
        details: [(String, String)],
        icon: String,
        isPrimary: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with icon and title
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(isPrimary ? 0.2 : 0.1))
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isPrimary ? .white : primaryColor)
                }
                
                Spacer()
            }
            
            // Title
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isPrimary ? .white.opacity(0.9) : mutedTextColor)
            
            // Main value and subtitle
            VStack(alignment: .leading, spacing: 1) {
                Text(mainValue)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isPrimary ? .white : textColor)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(isPrimary ? .white.opacity(0.7) : mutedTextColor)
                }
            }
            
            // Details
            VStack(alignment: .trailing, spacing: 1) {
                ForEach(details.indices, id: \.self) { index in
                    let detail = details[index]
                    HStack {
                        Text(detail.0)
                            .font(.system(size: 10))
                            .foregroundColor(isPrimary ? .white.opacity(0.8) : mutedTextColor)
                        
                        Spacer()
                        
                        if !detail.1.isEmpty {
                            Text(detail.1)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(isPrimary ? .white : textColor)
                        }
                    }
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 85)
        .background(
            isPrimary ? 
            LinearGradient(
                gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(isPrimary ? 0.1 : 0.05), radius: isPrimary ? 4 : 1, x: 0, y: isPrimary ? 2 : 1)
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

// MARK: - Team Management Views

// Team Management View
struct TeamManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddTeamMember = false
    @State private var showTeamMemberDetail = false
    @State private var selectedTeamMember: TeamMemberData?
    @State private var teamMembers: [TeamMemberData] = []
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let positiveColor = Color(hex: "#4CAF50")
    let negativeColor = Color(hex: "#F44336")
    let cardBgColor = Color.white
    
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Team overview cards
                            teamOverviewSection
                            
                            // Team members list
                            teamMembersSection
                            
                            // Spacer at bottom
                            Spacer()
                                .frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddTeamMember) {
            AddTeamMemberView { newMember in
                teamMembers.append(newMember)
            }
        }
        .sheet(isPresented: $showTeamMemberDetail) {
            if let member = selectedTeamMember {
                TeamMemberDetailView(member: member) { updatedMember in
                    if let index = teamMembers.firstIndex(where: { $0.id == updatedMember.id }) {
                        teamMembers[index] = updatedMember
                    }
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textColor)
            }
            
            Spacer()
            
            Text("Team Management")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
            
            Button(action: {
                showAddTeamMember = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(primaryColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Team Overview Section
    private var teamOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Overview")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            HStack(spacing: 12) {
                // Total members
                overviewCard(
                    title: "Total Members",
                    value: "\(teamMembers.count)",
                    icon: "person.3.fill",
                    color: primaryColor
                )
                
                // Active members
                overviewCard(
                    title: "Active",
                    value: "\(teamMembers.filter { $0.isActive }.count)",
                    icon: "checkmark.circle.fill",
                    color: positiveColor
                )
            }
            
            HStack(spacing: 12) {
                // Total jobs completed
                overviewCard(
                    title: "Jobs Completed",
                    value: "\(teamMembers.reduce(0) { $0 + $1.jobsCompleted })",
                    icon: "checkmark.square.fill",
                    color: Color(hex: "#5856D6")
                )
                
                // Spacer to maintain layout
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Team Members Section
    private var teamMembersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Team Members")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text("\(teamMembers.count) members")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            
            if teamMembers.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.2")
                        .font(.system(size: 48))
                        .foregroundColor(mutedTextColor.opacity(0.5))
                    
                    Text("No team members yet")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(textColor)
                    
                    Text("Add your first team member to get started")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showAddTeamMember = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                            
                            Text("Add Team Member")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(primaryColor)
                        .cornerRadius(8)
                    }
                }
                .padding(40)
                .frame(maxWidth: .infinity)
                .background(cardBgColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(teamMembers) { member in
                        teamMemberCard(member: member)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func overviewCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
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
    
    private func teamMemberCard(member: TeamMemberData) -> some View {
        Button(action: {
            selectedTeamMember = member
            showTeamMemberDetail = true
        }) {
            VStack(spacing: 16) {
                // Top row with profile and basic info
                HStack(spacing: 12) {
                    // Profile image placeholder
                    ZStack {
                        Circle()
                            .fill(primaryColor.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Text(member.name.prefix(1))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(primaryColor)
                    }
                    
                    // Name and role
                    VStack(alignment: .leading, spacing: 4) {
                        Text(member.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        Text(member.role)
                            .font(.system(size: 14))
                            .foregroundColor(mutedTextColor)
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(member.isActive ? positiveColor : negativeColor)
                            .frame(width: 8, height: 8)
                        
                        Text(member.isActive ? "Active" : "Inactive")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(member.isActive ? positiveColor : negativeColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((member.isActive ? positiveColor : negativeColor).opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Stats row
                HStack(spacing: 20) {
                    // Jobs completed
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(member.jobsCompleted)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        Text("Jobs")
                            .font(.system(size: 12))
                            .foregroundColor(mutedTextColor)
                    }
                    
                    // Rating
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#FF9500"))
                            
                            Text(String(format: "%.1f", member.rating))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(textColor)
                        }
                        
                        Text("Rating")
                            .font(.system(size: 12))
                            .foregroundColor(mutedTextColor)
                    }
                    
                    // Hourly rate
                    VStack(alignment: .leading, spacing: 2) {
                        Text("$\(String(format: "%.2f", member.hourlyRate))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        Text("Per Hour")
                            .font(.system(size: 12))
                            .foregroundColor(mutedTextColor)
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Enhanced Team Member Data Model
struct TeamMemberData: Identifiable {
    let id = UUID()
    var name: String
    var role: String
    var email: String
    var phone: String
    var jobsCompleted: Int
    var rating: Double
    var hourlyRate: Double
    var isActive: Bool
    var joinDate: Date
    var skills: [String]
    var profileImage: String?
    
    // Computed properties
    var initials: String {
        let components = name.components(separatedBy: " ")
        return components.compactMap { $0.first }.map { String($0) }.joined()
    }
}

// Add Team Member View
struct AddTeamMemberView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (TeamMemberData) -> Void
    
    @State private var name = ""
    @State private var role = "Cleaner"
    @State private var email = ""
    @State private var phone = ""
    @State private var hourlyRate = ""
    @State private var selectedSkills: Set<String> = []
    @State private var isActive = true
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, email, phone, hourlyRate
    }
    
    let roles = ["Cleaner", "Senior Cleaner", "Team Lead", "Supervisor", "Manager"]
    let availableSkills = [
        "Residential Cleaning",
        "Office Cleaning",
        "Deep Cleaning",
        "Window Cleaning",
        "Carpet Cleaning",
        "Floor Care",
        "Bathroom Sanitization",
        "Kitchen Cleaning",
        "Move-in/Move-out Cleaning",
        "Post-Construction Cleanup"
    ]
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let positiveColor = Color(hex: "#4CAF50")
    let inputBorderColor = Color(hex: "#E5E5E5")
    let cardBgColor = Color.white
    
    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty && !hourlyRate.isEmpty && Double(hourlyRate) != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Profile section
                            profileSection
                            
                            // Contact information
                            contactSection
                            
                            // Role and rate
                            roleAndRateSection
                            
                            // Status section
                            statusSection
                            
                            // Spacer at bottom
                            Spacer()
                                .frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    focusedField = nil
                }
                .foregroundColor(primaryColor)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textColor)
            }
            
            Spacer()
            
            Text("Add Team Member")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
            
            Button(action: {
                saveTeamMember()
            }) {
                Text("Save")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFormValid ? primaryColor : mutedTextColor)
            }
            .disabled(!isFormValid)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 16) {
                // Profile image placeholder
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    if name.isEmpty {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(primaryColor.opacity(0.5))
                    } else {
                        Text(name.prefix(1))
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(primaryColor)
                    }
                }
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("Enter full name", text: $name)
                        .font(.system(size: 16))
                        .padding(12)
                        .background(cardBgColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .name)
                }
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 16) {
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("Enter email address", text: $email)
                        .font(.system(size: 16))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(cardBgColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .email)
                }
                
                // Phone field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("Enter phone number", text: $phone)
                        .font(.system(size: 16))
                        .keyboardType(.phonePad)
                        .padding(12)
                        .background(cardBgColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .phone)
                }
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Role and Rate Section
    private var roleAndRateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Role & Compensation")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 16) {
                // Role picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Role")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    Menu {
                        ForEach(roles, id: \.self) { roleOption in
                            Button(action: {
                                role = roleOption
                            }) {
                                HStack {
                                    Text(roleOption)
                                    if role == roleOption {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(role)
                                .font(.system(size: 16))
                                .foregroundColor(textColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(mutedTextColor)
                        }
                        .padding(12)
                        .background(cardBgColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                    }
                }
                
                // Hourly rate field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hourly Rate")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    HStack {
                        Text("$")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                            .padding(.leading, 12)
                        
                        TextField("0.00", text: $hourlyRate)
                            .font(.system(size: 16))
                            .keyboardType(.decimalPad)
                            .padding(.vertical, 12)
                            .focused($focusedField, equals: .hourlyRate)
                    }
                    .background(cardBgColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(inputBorderColor, lineWidth: 1)
                    )
                }
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $isActive) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active Team Member")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(textColor)
                        
                        Text("This team member is actively working and available for scheduling")
                            .font(.system(size: 14))
                            .foregroundColor(mutedTextColor)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Helper Views
    private func skillTag(skill: String) -> some View {
        Button(action: {
            if selectedSkills.contains(skill) {
                selectedSkills.remove(skill)
            } else {
                selectedSkills.insert(skill)
            }
        }) {
            Text(skill)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedSkills.contains(skill) ? .white : textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selectedSkills.contains(skill) ? primaryColor : Color.gray.opacity(0.1))
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Actions
    private func saveTeamMember() {
        guard isFormValid,
              let rate = Double(hourlyRate) else { return }
        
        let newMember = TeamMemberData(
            name: name,
            role: role,
            email: email,
            phone: phone,
            jobsCompleted: 0,
            rating: 5.0,
            hourlyRate: rate,
            isActive: isActive,
            joinDate: Date(),
            skills: Array(selectedSkills),
            profileImage: nil
        )
        
        onSave(newMember)
        dismiss()
    }
}

// Edit Team Member View
struct EditTeamMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State var member: TeamMemberData
    var onSave: (TeamMemberData) -> Void
    
    @State private var name: String
    @State private var role: String
    @State private var email: String
    @State private var phone: String
    @State private var hourlyRate: String
    @State private var isActive: Bool
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, email, phone, hourlyRate
    }
    
    let roles = ["Cleaner", "Senior Cleaner", "Team Lead", "Supervisor", "Manager"]
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let positiveColor = Color(hex: "#4CAF50")
    let inputBorderColor = Color(hex: "#E5E5E5")
    let cardBgColor = Color.white
    
    init(member: TeamMemberData, onSave: @escaping (TeamMemberData) -> Void) {
        self.member = member
        self.onSave = onSave
        self._name = State(initialValue: member.name)
        self._role = State(initialValue: member.role)
        self._email = State(initialValue: member.email)
        self._phone = State(initialValue: member.phone)
        self._hourlyRate = State(initialValue: String(format: "%.2f", member.hourlyRate))
        self._isActive = State(initialValue: member.isActive)
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty && !hourlyRate.isEmpty && Double(hourlyRate) != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Profile section
                            profileSection
                            
                            // Contact information
                            contactSection
                            
                            // Role and rate
                            roleAndRateSection
                            
                            // Status section
                            statusSection
                            
                            // Spacer at bottom
                            Spacer()
                                .frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    focusedField = nil
                }
                .foregroundColor(primaryColor)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textColor)
            }
            
            Spacer()
            
            Text("Edit Team Member")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
            
            Button(action: {
                saveTeamMember()
            }) {
                Text("Save")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFormValid ? primaryColor : mutedTextColor)
            }
            .disabled(!isFormValid)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 16) {
                // Profile image placeholder
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    if name.isEmpty {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(primaryColor.opacity(0.5))
                    } else {
                        Text(name.prefix(1))
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(primaryColor)
                    }
                }
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("Enter full name", text: $name)
                        .font(.system(size: 16))
                        .padding(12)
                        .background(cardBgColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .name)
                }
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 16) {
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("Enter email address", text: $email)
                        .font(.system(size: 16))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(cardBgColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .email)
                }
                
                // Phone field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("Enter phone number", text: $phone)
                        .font(.system(size: 16))
                        .keyboardType(.phonePad)
                        .padding(12)
                        .background(cardBgColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                        .focused($focusedField, equals: .phone)
                }
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Role and Rate Section
    private var roleAndRateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Role & Compensation")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 16) {
                // Role picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Role")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    Menu {
                        ForEach(roles, id: \.self) { roleOption in
                            Button(action: {
                                role = roleOption
                            }) {
                                HStack {
                                    Text(roleOption)
                                    if role == roleOption {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(role)
                                .font(.system(size: 16))
                                .foregroundColor(textColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(mutedTextColor)
                        }
                        .padding(12)
                        .background(cardBgColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(inputBorderColor, lineWidth: 1)
                        )
                    }
                }
                
                // Hourly rate field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hourly Rate")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(mutedTextColor)
                    
                    HStack {
                        Text("$")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                            .padding(.leading, 12)
                        
                        TextField("0.00", text: $hourlyRate)
                            .font(.system(size: 16))
                            .keyboardType(.decimalPad)
                            .padding(.vertical, 12)
                            .focused($focusedField, equals: .hourlyRate)
                    }
                    .background(cardBgColor)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(inputBorderColor, lineWidth: 1)
                    )
                }
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $isActive) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active Team Member")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(textColor)
                        
                        Text("This team member is actively working and available for scheduling")
                            .font(.system(size: 14))
                            .foregroundColor(mutedTextColor)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
            }
            .padding(16)
            .background(cardBgColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Actions
    private func saveTeamMember() {
        guard isFormValid,
              let rate = Double(hourlyRate) else { return }
        
        var updatedMember = member
        updatedMember.name = name
        updatedMember.role = role
        updatedMember.email = email
        updatedMember.phone = phone
        updatedMember.hourlyRate = rate
        updatedMember.isActive = isActive
        
        onSave(updatedMember)
        dismiss()
    }
}

// Team Member Detail View
struct TeamMemberDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var member: TeamMemberData
    var onSave: (TeamMemberData) -> Void
    
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let positiveColor = Color(hex: "#4CAF50")
    let negativeColor = Color(hex: "#F44336")
    let cardBgColor = Color.white
    
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Profile section
                            profileSection
                            
                            // Contact section
                            contactSection
                            
                            // Jobs completed section (smaller)
                            jobsCompletedSection
                            
                            // Actions section
                            actionsSection
                            
                            // Spacer at bottom
                            Spacer()
                                .frame(height: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isEditing) {
            EditTeamMemberView(member: member) { updatedMember in
                member = updatedMember
                onSave(updatedMember)
            }
        }
        .alert("Delete Team Member", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this team member? This action cannot be undone.")
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textColor)
            }
            
            Spacer()
            
            Text("Team Member")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
            
            Button(action: {
                isEditing = true
            }) {
                Text("Edit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(spacing: 16) {
            // Profile image and basic info
            HStack(spacing: 16) {
                // Profile image placeholder
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Text(member.name.prefix(1))
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(member.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(textColor)
                    
                    Text(member.role)
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                    
                    // Status indicator
                    HStack(spacing: 6) {
                        Circle()
                            .fill(member.isActive ? positiveColor : negativeColor)
                            .frame(width: 8, height: 8)
                        
                        Text(member.isActive ? "Active" : "Inactive")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(member.isActive ? positiveColor : negativeColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((member.isActive ? positiveColor : negativeColor).opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            
            // Join date
            HStack {
                Text("Joined")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
                
                Spacer()
                
                Text(member.joinDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 12) {
                // Email
                HStack {
                    Image(systemName: "envelope")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                        .frame(width: 24)
                    
                    Text("Email")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                    
                    Spacer()
                    
                    Text(member.email)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor)
                }
                
                Divider()
                
                // Phone
                HStack {
                    Image(systemName: "phone")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                        .frame(width: 24)
                    
                    Text("Phone")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                    
                    Spacer()
                    
                    Text(member.phone)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor)
                }
                
                Divider()
                
                // Hourly rate
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                        .frame(width: 24)
                    
                    Text("Hourly Rate")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", member.hourlyRate))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor)
                }
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Jobs Completed Section (smaller)
    private var jobsCompletedSection: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(positiveColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(positiveColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Jobs Completed")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                    
                    Text("\(member.jobsCompleted) jobs")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Schedule button
            Button(action: {
                // Navigate to schedule
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(primaryColor)
                    
                    Text("View Schedule")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(primaryColor)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                }
                .padding(16)
                .background(cardBgColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            
            // Delete button
            Button(action: {
                showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(negativeColor)
                    
                    Text("Delete Team Member")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(negativeColor)
                    
                    Spacer()
                }
                .padding(16)
                .background(cardBgColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }
}

// Team Schedule View
struct TeamScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var selectedView = ScheduleViewType.day
    @State private var showAddShift = false
    
    enum ScheduleViewType: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }
    
    // Mock schedule data
    @State private var scheduleItems: [ScheduleItem] = [
        ScheduleItem(
            id: UUID(),
            teamMember: "John Smith",
            client: "Johnson Residence",
            startTime: Calendar.current.date(byAdding: .hour, value: 9, to: Calendar.current.startOfDay(for: Date())) ?? Date(),
            endTime: Calendar.current.date(byAdding: .hour, value: 12, to: Calendar.current.startOfDay(for: Date())) ?? Date(),
            address: "123 Main St, Anytown, USA",
            status: .scheduled
        ),
        ScheduleItem(
            id: UUID(),
            teamMember: "Sarah Johnson",
            client: "Office Complex A",
            startTime: Calendar.current.date(byAdding: .hour, value: 14, to: Calendar.current.startOfDay(for: Date())) ?? Date(),
            endTime: Calendar.current.date(byAdding: .hour, value: 17, to: Calendar.current.startOfDay(for: Date())) ?? Date(),
            address: "456 Business Ave, Anytown, USA",
            status: .inProgress
        ),
        ScheduleItem(
            id: UUID(),
            teamMember: "Mike Davis",
            client: "Smith House",
            startTime: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.date(byAdding: .hour, value: 10, to: Calendar.current.startOfDay(for: Date())) ?? Date()) ?? Date(),
            endTime: Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.date(byAdding: .hour, value: 13, to: Calendar.current.startOfDay(for: Date())) ?? Date()) ?? Date(),
            address: "789 Oak St, Anytown, USA",
            status: .scheduled
        )
    ]
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let positiveColor = Color(hex: "#4CAF50")
    let warningColor = Color(hex: "#FF9500")
    let cardBgColor = Color.white
    
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // View selector
                    viewSelector
                    
                    // Date selector
                    dateSelector
                    
                    // Schedule content
                    scheduleContent
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddShift) {
            AddShiftView { newShift in
                scheduleItems.append(newShift)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textColor)
            }
            
            Spacer()
            
            Text("Team Schedule")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
            
            Button(action: {
                showAddShift = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(primaryColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - View Selector
    private var viewSelector: some View {
        HStack(spacing: 0) {
            ForEach(ScheduleViewType.allCases, id: \.self) { viewType in
                Button(action: {
                    selectedView = viewType
                }) {
                    Text(viewType.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedView == viewType ? .white : textColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedView == viewType ? primaryColor : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Date Selector
    private var dateSelector: some View {
        HStack {
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(primaryColor)
            }
            
            Spacer()
            
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
            
            Button(action: {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(primaryColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    // MARK: - Schedule Content
    private var scheduleContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Schedule summary
                scheduleStats
                
                // Schedule items
                scheduleItemsList
                
                // Spacer at bottom
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
    
    // MARK: - Schedule Stats
    private var scheduleStats: some View {
        HStack(spacing: 12) {
            // Total jobs
            statCard(
                title: "Total Jobs",
                value: "\(scheduleItems.count)",
                icon: "calendar",
                color: primaryColor
            )
            
            // Completed
            statCard(
                title: "Completed",
                value: "\(scheduleItems.filter { $0.status == .completed }.count)",
                icon: "checkmark.circle.fill",
                color: positiveColor
            )
        }
    }
    
    // MARK: - Schedule Items List
    private var scheduleItemsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Schedule")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            if scheduleItems.isEmpty {
                Text("No scheduled jobs for today")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(cardBgColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(scheduleItems) { item in
                        scheduleItemCard(item: item)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
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
    
    private func scheduleItemCard(item: ScheduleItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with team member and status
            HStack {
                Text(item.teamMember)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                // Status badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(item.status.color)
                        .frame(width: 8, height: 8)
                    
                    Text(item.status.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(item.status.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(item.status.color.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Client and time
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "building.2")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                        .frame(width: 20)
                    
                    Text(item.client)
                        .font(.system(size: 14))
                        .foregroundColor(textColor)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                        .frame(width: 20)
                    
                    Text("\(item.startTime.formatted(date: .omitted, time: .shortened)) - \(item.endTime.formatted(date: .omitted, time: .shortened))")
                        .font(.system(size: 14))
                        .foregroundColor(textColor)
                }
                
                HStack {
                    Image(systemName: "location")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                        .frame(width: 20)
                    
                    Text(item.address)
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Schedule Models
struct ScheduleItem: Identifiable {
    let id: UUID
    let teamMember: String
    let client: String
    let startTime: Date
    let endTime: Date
    let address: String
    let status: ScheduleStatus
}

enum ScheduleStatus: String, CaseIterable {
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .scheduled:
            return Color(hex: "#246BFD")
        case .inProgress:
            return Color(hex: "#FF9500")
        case .completed:
            return Color(hex: "#4CAF50")
        case .cancelled:
            return Color(hex: "#F44336")
        }
    }
}

// Add Shift View (placeholder for now)
struct AddShiftView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (ScheduleItem) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Shift")
                    .font(.title)
                    .padding()
                
                Button("Cancel") {
                    dismiss()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

// Team Performance View (placeholder)
struct TeamPerformanceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Team Performance")
                    .font(.title)
                    .padding()
                
                Button("Close") {
                    dismiss()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

// Team Payroll View (placeholder)
struct TeamPayrollView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Team Payroll")
                    .font(.title)
                    .padding()
                
                Button("Close") {
                    dismiss()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Data Models

#Preview {
    HubView()
}

// MARK: - Financial Details View
struct FinancialDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod = "This Month"
    @State private var selectedMetric = "Revenue"
    
    let periods = ["This Week", "This Month", "This Quarter", "This Year"]
    let metrics = ["Revenue", "Expenses", "Profit", "Team Costs"]
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let positiveColor = Color(hex: "#4CAF50")
    let negativeColor = Color(hex: "#F44336")
    let cardBgColor = Color.white
    
    // Mock financial data
    let monthlyRevenue = [
        FinancialDataPoint(day: "Jan", amount: 3200),
        FinancialDataPoint(day: "Feb", amount: 3800),
        FinancialDataPoint(day: "Mar", amount: 4200),
        FinancialDataPoint(day: "Apr", amount: 3900),
        FinancialDataPoint(day: "May", amount: 4500),
        FinancialDataPoint(day: "Jun", amount: 4250)
    ]
    
    let teamPayments = [
        TeamPayment(name: "John Smith", role: "Cleaner", hoursWorked: 40, hourlyRate: 25.0, totalPay: 1000.0),
        TeamPayment(name: "Sarah Johnson", role: "Senior Cleaner", hoursWorked: 35, hourlyRate: 30.0, totalPay: 1050.0),
        TeamPayment(name: "Mike Davis", role: "Team Lead", hoursWorked: 30, hourlyRate: 35.0, totalPay: 1050.0)
    ]
    
    let expenseBreakdown = [
        ExpenseItem(category: "Team Salaries", amount: 3100.0, percentage: 72.9, color: Color(hex: "#246BFD")),
        ExpenseItem(category: "Equipment", amount: 450.0, percentage: 10.6, color: Color(hex: "#FF9500")),
        ExpenseItem(category: "Transportation", amount: 325.0, percentage: 7.6, color: Color(hex: "#4CAF50")),
        ExpenseItem(category: "Marketing", amount: 200.0, percentage: 4.7, color: Color(hex: "#F44336")),
        ExpenseItem(category: "Other", amount: 175.0, percentage: 4.1, color: Color(hex: "#9C27B0"))
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with period selector
                        headerSection
                        
                        // Key metrics cards
                        keyMetricsSection
                        
                        // Revenue trend chart
                        revenueTrendSection
                        
                        // Expense breakdown
                        expenseBreakdownSection
                        
                        // Team payments
                        teamPaymentsSection
                        
                        // Profit analysis
                        profitAnalysisSection
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Title and close button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Financial Details")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(textColor)
                    
                    Text("Comprehensive financial overview")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(mutedTextColor)
                    }
                }
            }
            
            // Period selector
            HStack {
                ForEach(periods, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                    }) {
                        Text(period)
                            .font(.system(size: 14, weight: selectedPeriod == period ? .semibold : .medium))
                            .foregroundColor(selectedPeriod == period ? .white : mutedTextColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? primaryColor : Color.clear)
                            .cornerRadius(20)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(cardBgColor)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Key Metrics Section
    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    metricCard(title: "Total Revenue", value: "$4,250", change: "+12%", isPositive: true, icon: "arrow.up.right")
                    metricCard(title: "Total Expenses", value: "$4,250", change: "-5%", isPositive: true, icon: "arrow.down.left")
                }
                
                HStack(spacing: 12) {
                    metricCard(title: "Net Profit", value: "$975", change: "+18%", isPositive: true, icon: "chart.line.uptrend.xyaxis")
                    metricCard(title: "Profit Margin", value: "22.9%", change: "+3%", isPositive: true, icon: "percent")
                }
            }
        }
    }
    
    // MARK: - Revenue Trend Section
    private var revenueTrendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Revenue Trend")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                // Metric selector
                Menu {
                    ForEach(metrics, id: \.self) { metric in
                        Button(metric) {
                            selectedMetric = metric
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedMetric)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(primaryColor)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(primaryColor)
                    }
                }
            }
            
            // Chart
            Chart {
                ForEach(monthlyRevenue) { dataPoint in
                    LineMark(
                        x: .value("Month", dataPoint.day),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor, primaryColor.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Month", dataPoint.day),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [primaryColor.opacity(0.3), primaryColor.opacity(0.1)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("$\(intValue/1000)K")
                                .font(.system(size: 12))
                                .foregroundColor(mutedTextColor)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(.system(size: 12))
                                .foregroundColor(mutedTextColor)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(cardBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Expense Breakdown Section
    private var expenseBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expense Breakdown")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 12) {
                ForEach(expenseBreakdown, id: \.category) { expense in
                    expenseRow(expense: expense)
                }
            }
        }
        .padding(20)
        .background(cardBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Team Payments Section
    private var teamPaymentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Team Payments")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text("Total: $3,100")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryColor)
            }
            
            VStack(spacing: 12) {
                ForEach(teamPayments, id: \.name) { payment in
                    teamPaymentRow(payment: payment)
                }
            }
        }
        .padding(20)
        .background(cardBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Profit Analysis Section
    private var profitAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profit Analysis")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 16) {
                // Profit breakdown
                VStack(spacing: 8) {
                    profitRow(title: "Gross Revenue", amount: 4250.0, color: primaryColor)
                    profitRow(title: "Team Costs", amount: -3100.0, color: negativeColor)
                    profitRow(title: "Operating Expenses", amount: -175.0, color: negativeColor)
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    profitRow(title: "Net Profit", amount: 975.0, color: positiveColor, isTotal: true)
                }
                
                // Profit margin indicator
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Profit Margin")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(mutedTextColor)
                        
                        Spacer()
                        
                        Text("22.9%")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(positiveColor)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [positiveColor, positiveColor.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * 0.229, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(20)
        .background(cardBgColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Views
    private func metricCard(title: String, value: String, change: String, isPositive: Bool, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(primaryColor)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isPositive ? positiveColor : negativeColor)
                    
                    Text(change)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isPositive ? positiveColor : negativeColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((isPositive ? positiveColor : negativeColor).opacity(0.1))
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(mutedTextColor)
                
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func expenseRow(expense: ExpenseItem) -> some View {
        HStack(spacing: 12) {
            // Color indicator
            Circle()
                .fill(expense.color)
                .frame(width: 12, height: 12)
            
            // Category and amount
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                
                Text("$\(String(format: "%.0f", expense.amount))")
                    .font(.system(size: 12))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            // Percentage
            Text("\(String(format: "%.1f", expense.percentage))%")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(textColor)
        }
        .padding(.vertical, 4)
    }
    
    private func teamPaymentRow(payment: TeamPayment) -> some View {
        HStack(spacing: 12) {
            // Profile circle
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text(String(payment.name.prefix(1)))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryColor)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(payment.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                
                Text("\(payment.role) • \(payment.hoursWorked)h @ $\(String(format: "%.0f", payment.hourlyRate))/h")
                    .font(.system(size: 12))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            // Total pay
            Text("$\(String(format: "%.0f", payment.totalPay))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(textColor)
        }
        .padding(.vertical, 4)
    }
    
    private func profitRow(title: String, amount: Double, color: Color, isTotal: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(size: isTotal ? 16 : 14, weight: isTotal ? .semibold : .medium))
                .foregroundColor(isTotal ? textColor : mutedTextColor)
            
            Spacer()
            
            Text(amount >= 0 ? "$\(String(format: "%.0f", amount))" : "-$\(String(format: "%.0f", abs(amount)))")
                .font(.system(size: isTotal ? 18 : 16, weight: isTotal ? .bold : .semibold))
                .foregroundColor(color)
        }
        .padding(.vertical, isTotal ? 8 : 4)
    }
}

// MARK: - Financial Models
struct TeamPayment: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let hoursWorked: Int
    let hourlyRate: Double
    let totalPay: Double
}

struct ExpenseItem: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color
}

// MARK: - Data Models

#Preview {
    HubView()
} 