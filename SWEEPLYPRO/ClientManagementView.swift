//
//  ClientManagementView.swift
//  SWEEPLYPRO
//
//  Created on 7/10/25.
//

import SwiftUI
import SwiftData

struct ClientManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var clients: [Client]
    @State private var searchText = ""
    @State private var showNewClientView = false
    @State private var selectedClient: Client?
    @State private var showClientDetail = false
    @State private var selectedFilterType = "All"
    
    // Filter options
    let filterTypes = ["All", "Recent", "Active", "Inactive"]
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let secondaryColor = Color(hex: "#F5F5F5")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let cardBgColor = Color.white
    
    // Filtered clients based on search and filter
    private var filteredClients: [Client] {
        var filtered = clients
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { client in
                client.fullName.localizedCaseInsensitiveContains(searchText) ||
                client.propertyAddress.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply type filter
        switch selectedFilterType {
        case "Recent":
            // Sort by creation date (most recent first)
            filtered = filtered.sorted { $0.createdAt > $1.createdAt }
        case "Active":
            // Filter active clients (you might want to add an isActive property to Client)
            break
        case "Inactive":
            // Filter inactive clients
            break
        default:
            break
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                secondaryColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search and filter section
                    searchAndFilterSection
                    
                    // Clients list
                    clientsListSection
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showNewClientView) {
            NewClientView()
        }
        .sheet(isPresented: $showClientDetail) {
            if let client = selectedClient {
                ClientDetailView(client: client)
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
            
            Text("Client Management")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
            
            Button(action: {
                showNewClientView = true
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
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(mutedTextColor)
                    .font(.system(size: 16))
                
                TextField("Search clients...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(textColor)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(mutedTextColor)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Filter tabs
            HStack(spacing: 0) {
                ForEach(filterTypes, id: \.self) { filterType in
                    Button(action: {
                        selectedFilterType = filterType
                    }) {
                        Text(filterType)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedFilterType == filterType ? .white : mutedTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedFilterType == filterType ? primaryColor : Color.clear)
                            .cornerRadius(6)
                    }
                }
            }
            .padding(4)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    // MARK: - Clients List Section
    private var clientsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredClients.isEmpty {
                    // Empty state
                    emptyStateView
                } else {
                    // Client stats header
                    clientStatsHeader
                    
                    // Clients list
                    ForEach(filteredClients) { client in
                        ClientManagementRow(client: client) {
                            selectedClient = client
                            showClientDetail = true
                        }
                    }
                }
                
                // Bottom spacing
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Client Stats Header
    private var clientStatsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(filteredClients.count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
                
                Text("Total Clients")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.0f", calculateTotalRevenue()))")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#4CAF50"))
                
                Text("Total Revenue")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
        }
        .padding(16)
        .background(cardBgColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.bottom, 8)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundColor(mutedTextColor)
                .padding(.top, 60)
            
            Text("No Clients Found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)
            
            Text(searchText.isEmpty ? "Start building your client database by adding your first client" : "No clients match your search criteria")
                .font(.system(size: 16))
                .foregroundColor(mutedTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                showNewClientView = true
            }) {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Add New Client")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(primaryColor)
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    // Helper function to calculate total revenue (mock data)
    private func calculateTotalRevenue() -> Double {
        // In a real app, this would calculate based on completed jobs/invoices
        return Double(filteredClients.count) * 150.0 // Mock average revenue per client
    }
}

// MARK: - Client Management Row
struct ClientManagementRow: View {
    let client: Client
    let onTap: () -> Void
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let cardBgColor = Color.white
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Client avatar
                ZStack {
                    Circle()
                        .fill(primaryColor.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Text(String(client.fullName.prefix(1).uppercased()))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
                
                // Client info
                VStack(alignment: .leading, spacing: 6) {
                    Text(client.fullName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                    
                    if !client.email.isEmpty {
                        Text(client.email)
                            .font(.system(size: 14))
                            .foregroundColor(mutedTextColor)
                            .lineLimit(1)
                    }
                    
                    if !client.propertyAddress.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.system(size: 12))
                                .foregroundColor(mutedTextColor)
                            
                            Text(client.propertyAddress)
                                .font(.system(size: 14))
                                .foregroundColor(mutedTextColor)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Status and chevron
                VStack(alignment: .trailing, spacing: 8) {
                    // Active status indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: "#4CAF50"))
                            .frame(width: 6, height: 6)
                        
                        Text("Active")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#4CAF50"))
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(mutedTextColor)
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

#Preview {
    ClientManagementView()
        .modelContainer(for: [Client.self], inMemory: true)
} 