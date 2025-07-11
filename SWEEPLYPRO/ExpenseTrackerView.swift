//
//  ExpenseTrackerView.swift
//  SWEEPLYPRO
//
//  Created on 7/11/25.
//

import SwiftUI
import Charts

struct ExpenseTrackerView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var expenses: [Expense] = []
    @State private var showAddExpense = false
    @State private var selectedPeriod = "This Month"
    @State private var selectedCategory: ExpenseTrackerCategory? = nil
    @State private var searchText = ""
    
    // Period options
    let periodOptions = ["This Week", "This Month", "This Quarter", "This Year", "All Time"]
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let cardBgColor = Color.white
    let borderColor = Color(hex: "#E5E5E5")
    
    // Expense categories
    let expenseCategories = [
        ExpenseTrackerCategory(name: "Supplies", color: Color(hex: "#246BFD")),
        ExpenseTrackerCategory(name: "Travel", color: Color(hex: "#FF9500")),
        ExpenseTrackerCategory(name: "Equipment", color: Color(hex: "#4CAF50")),
        ExpenseTrackerCategory(name: "Marketing", color: Color(hex: "#F44336")),
        ExpenseTrackerCategory(name: "Staff", color: Color(hex: "#9C27B0")),
        ExpenseTrackerCategory(name: "Utilities", color: Color(hex: "#2196F3")),
        ExpenseTrackerCategory(name: "Rent", color: Color(hex: "#795548")),
        ExpenseTrackerCategory(name: "Other", color: Color(hex: "#607D8B"))
    ]
    
    // Computed properties
    var filteredExpenses: [Expense] {
        var result = expenses
        
        // Filter by category if selected
        if let category = selectedCategory {
            result = result.filter { $0.category == category.name }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.category.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Sort by date (most recent first)
        return result.sorted(by: { $0.date > $1.date })
    }
    
    var totalExpenses: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var expensesByCategory: [CategorySum] {
        var categorySums: [String: Double] = [:]
        
        // Sum expenses by category
        for expense in filteredExpenses {
            categorySums[expense.category, default: 0] += expense.amount
        }
        
        // Convert to array of CategorySum
        return categorySums.map { category, sum in
            let categoryColor = expenseCategories.first(where: { $0.name == category })?.color ?? Color.gray
            return CategorySum(category: category, sum: sum, color: categoryColor)
        }.sorted(by: { $0.sum > $1.sum })
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Summary cards
                            summaryCardsView
                            
                            // Category breakdown
                            categoryBreakdownView
                            
                            // Category filter chips
                            categoryFilterView
                            
                            // Expense list
                            expenseListView
                            
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
            .onAppear {
                // Load sample data when view appears
                if expenses.isEmpty {
                    expenses = sampleExpenses
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(
                    expenseCategories: expenseCategories,
                    onSave: { newExpense in
                        expenses.append(newExpense)
                    }
                )
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                // Back button
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(textColor)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                
                Spacer()
                
                // Title
                Text("Expense Tracker")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                // Add expense button
                Button(action: {
                    showAddExpense = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(primaryColor)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            
            // Search and period selector
            HStack {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(mutedTextColor)
                    
                    TextField("Search expenses", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
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
        .padding(16)
        .background(cardBgColor)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Summary Cards View
    private var summaryCardsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Summary")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Total expenses card
                summaryCard(
                    title: "Total Expenses",
                    value: "$\(String(format: "%.2f", totalExpenses))",
                    icon: "dollarsign.circle.fill",
                    color: Color(hex: "#F44336")
                )
                
                // Number of expenses card
                summaryCard(
                    title: "Transactions",
                    value: "\(filteredExpenses.count)",
                    icon: "list.bullet",
                    color: primaryColor
                )
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Summary card
    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
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
    
    // MARK: - Category Breakdown View
    private var categoryBreakdownView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expense Breakdown")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            // Pie chart
            if !filteredExpenses.isEmpty {
                HStack {
                    // Chart
                    Chart {
                        ForEach(expensesByCategory) { category in
                            SectorMark(
                                angle: .value("Amount", category.sum),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(category.color)
                            .cornerRadius(3)
                        }
                    }
                    .frame(height: 180)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(expensesByCategory.prefix(5)) { category in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(category.category)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(textColor)
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", category.sum))")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(mutedTextColor)
                            }
                        }
                        
                        if expensesByCategory.count > 5 {
                            Text("+ \(expensesByCategory.count - 5) more")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(mutedTextColor)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            } else {
                Text("No expenses to display")
                    .font(.system(size: 16))
                    .foregroundColor(mutedTextColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 60)
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Category Filter View
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All categories chip
                categoryFilterChip(category: nil)
                
                // Category chips
                ForEach(expenseCategories) { category in
                    categoryFilterChip(category: category)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // Category filter chip
    private func categoryFilterChip(category: ExpenseTrackerCategory?) -> some View {
        let isSelected = (category == nil && selectedCategory == nil) || 
                         (category != nil && selectedCategory?.name == category?.name)
        
        return Button(action: {
            withAnimation {
                selectedCategory = category
            }
        }) {
            HStack(spacing: 6) {
                if let category = category {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)
                }
                
                Text(category?.name ?? "All")
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? primaryColor.opacity(0.1) : Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? primaryColor : borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Expense List View
    private var expenseListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Expense History")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                // Sort button (placeholder)
                Button(action: {
                    // Sort functionality would go here
                }) {
                    HStack(spacing: 4) {
                        Text("Sort")
                            .font(.system(size: 14))
                            .foregroundColor(mutedTextColor)
                        
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 12))
                            .foregroundColor(mutedTextColor)
                    }
                }
            }
            
            if filteredExpenses.isEmpty {
                Text("No expenses to display")
                    .font(.system(size: 16))
                    .foregroundColor(mutedTextColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                // Group expenses by date
                let groupedExpenses = Dictionary(grouping: filteredExpenses) { expense in
                    Calendar.current.startOfDay(for: expense.date)
                }
                
                ForEach(groupedExpenses.keys.sorted(by: >), id: \.self) { date in
                    if let expensesForDate = groupedExpenses[date] {
                        VStack(alignment: .leading, spacing: 12) {
                            // Date header
                            Text(formatDate(date))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(mutedTextColor)
                                .padding(.top, 4)
                            
                            // Expenses for this date
                            ForEach(expensesForDate) { expense in
                                expenseRow(expense: expense)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Expense row
    private func expenseRow(expense: Expense) -> some View {
        HStack(spacing: 12) {
            // Category icon
            let categoryColor = expenseCategories.first(where: { $0.name == expense.category })?.color ?? Color.gray
            
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: getCategoryIcon(for: expense.category))
                    .font(.system(size: 16))
                    .foregroundColor(categoryColor)
            }
            
            // Expense details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                Text(expense.category)
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            // Amount
            Text("$\(String(format: "%.2f", expense.amount))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(textColor)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Functions
    
    // Format date for section headers
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
    
    // Get icon for expense category
    private func getCategoryIcon(for category: String) -> String {
        switch category {
        case "Supplies":
            return "box.fill"
        case "Travel":
            return "car.fill"
        case "Equipment":
            return "wrench.fill"
        case "Marketing":
            return "megaphone.fill"
        case "Staff":
            return "person.2.fill"
        case "Utilities":
            return "bolt.fill"
        case "Rent":
            return "building.fill"
        default:
            return "tag.fill"
        }
    }
    
    // Sample expenses data
    private var sampleExpenses: [Expense] {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            Expense(name: "Cleaning supplies", amount: 85.99, category: "Supplies", date: today),
            Expense(name: "Gas for company van", amount: 45.50, category: "Travel", date: today),
            Expense(name: "New vacuum cleaner", amount: 199.99, category: "Equipment", date: calendar.date(byAdding: .day, value: -1, to: today)!),
            Expense(name: "Facebook ads", amount: 75.00, category: "Marketing", date: calendar.date(byAdding: .day, value: -1, to: today)!),
            Expense(name: "Staff wages", amount: 450.00, category: "Staff", date: calendar.date(byAdding: .day, value: -2, to: today)!),
            Expense(name: "Electricity bill", amount: 120.50, category: "Utilities", date: calendar.date(byAdding: .day, value: -3, to: today)!),
            Expense(name: "Office rent", amount: 800.00, category: "Rent", date: calendar.date(byAdding: .day, value: -5, to: today)!),
            Expense(name: "Cleaning chemicals", amount: 65.75, category: "Supplies", date: calendar.date(byAdding: .day, value: -7, to: today)!),
            Expense(name: "Mileage reimbursement", amount: 78.25, category: "Travel", date: calendar.date(byAdding: .day, value: -7, to: today)!),
            Expense(name: "Business insurance", amount: 175.00, category: "Other", date: calendar.date(byAdding: .day, value: -10, to: today)!)
        ]
    }
}

// MARK: - Data Models

// Expense model
struct Expense: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let category: String
    let date: Date
    let notes: String?
    
    init(name: String, amount: Double, category: String, date: Date, notes: String? = nil) {
        self.name = name
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
    }
}

// Expense category model
struct ExpenseTrackerCategory: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: Color
    
    static func == (lhs: ExpenseTrackerCategory, rhs: ExpenseTrackerCategory) -> Bool {
        return lhs.name == rhs.name
    }
}

// Category sum model for chart
struct CategorySum: Identifiable {
    let id = UUID()
    let category: String
    let sum: Double
    let color: Color
}

// MARK: - Add Expense View
struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    let expenseCategories: [ExpenseTrackerCategory]
    let onSave: (Expense) -> Void
    
    @State private var expenseName = ""
    @State private var expenseAmount = ""
    @State private var selectedCategory = "Supplies"
    @State private var expenseDate = Date()
    @State private var expenseNotes = ""
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let cardBgColor = Color.white
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Expense Name", text: $expenseName)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(mutedTextColor)
                        TextField("Amount", text: $expenseAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(expenseCategories, id: \.name) { category in
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 10, height: 10)
                                Text(category.name)
                            }
                            .tag(category.name)
                        }
                    }
                    
                    DatePicker("Date", selection: $expenseDate, displayedComponents: .date)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $expenseNotes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(expenseName.isEmpty || expenseAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amount = Double(expenseAmount) else { return }
        
        let newExpense = Expense(
            name: expenseName,
            amount: amount,
            category: selectedCategory,
            date: expenseDate,
            notes: expenseNotes.isEmpty ? nil : expenseNotes
        )
        
        onSave(newExpense)
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    ExpenseTrackerView()
} 