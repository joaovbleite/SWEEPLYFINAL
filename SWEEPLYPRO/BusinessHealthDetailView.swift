//
//  BusinessHealthDetailView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct BusinessHealthDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // This is a placeholder for the detailed business health view
                    // In a real app, this would contain more comprehensive business metrics
                    
                    // Example content
                    ForEach(0..<5) { _ in
                        BusinessHealthDetailCard()
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
            }
        }
    }
}

struct BusinessHealthDetailCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card title
            Text("Performance Metrics")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#0A0A0A"))
            
            // Sample metrics
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Revenue")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#7D8A99"))
                    
                    Text("$1,250")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }
                
                Spacer()
                
                // Growth indicator
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#2ECC71"))
                    
                    Text("12%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#2ECC71"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "#E6F0FF"))
                .cornerRadius(16)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Completed Jobs")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#7D8A99"))
                    
                    Text("8")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }
                
                Spacer()
                
                // Growth indicator
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#2ECC71"))
                    
                    Text("25%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#2ECC71"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: "#E6F0FF"))
                .cornerRadius(16)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    BusinessHealthDetailView()
} 