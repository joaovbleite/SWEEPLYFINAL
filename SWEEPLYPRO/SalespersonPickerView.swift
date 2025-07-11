//
//  SalespersonPickerView.swift
//  SWEEPLYPRO
//
//  Created on 7/11/25.
//

import SwiftUI

struct SalespersonPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSalesperson: String
    let salespeople: [String]
    
    // Colors
    private let primaryColor = Color(hex: "#246BFD")
    private let textColor = Color(hex: "#1A1A1A")
    private let mutedTextColor = Color(hex: "#5E7380")
    private let backgroundColor = Color(hex: "#F5F5F5")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(textColor)
                    }
                    
                    Spacer()
                    
                    Text("Select Salesperson")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.clear)
                    }
                    .disabled(true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
                
                // List of salespeople
                List {
                    ForEach(salespeople, id: \.self) { salesperson in
                        Button(action: {
                            selectedSalesperson = salesperson
                            dismiss()
                        }) {
                            HStack {
                                Text(salesperson)
                                    .font(.system(size: 16))
                                    .foregroundColor(textColor)
                                
                                Spacer()
                                
                                if selectedSalesperson == salesperson {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(primaryColor)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .background(backgroundColor)
        }
    }
}

// MARK: - Preview
#Preview {
    SalespersonPickerView(selectedSalesperson: .constant("Joao"), salespeople: ["Joao", "Sarah", "Michael", "Emma", "David"])
}