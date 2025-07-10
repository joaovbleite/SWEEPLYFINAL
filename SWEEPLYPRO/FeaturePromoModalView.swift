//
//  FeaturePromoModalView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct FeaturePromoModalView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Brand color - blue
    let brandColor = Color(hex: "#246BFD")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // Image - using the actual image with reduced size
                    Image("desktop_illustration")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 180)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    
                    // Feature list
                    VStack(alignment: .leading, spacing: 8) {
                        // Section title
                        Text("Discover the full power of Sweeply")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#002D2D"))
                            .padding(.bottom, 4)
                        
                        // Features
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureListItem(text: "Powerful, full-view scheduling", iconColor: brandColor)
                            FeatureListItem(text: "Customizable online booking forms", iconColor: brandColor)
                            FeatureListItem(text: "Automated quote and invoice follow-ups", iconColor: brandColor)
                            FeatureListItem(text: "Job costing and automatic billing", iconColor: brandColor)
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
                    .padding(.horizontal, 12)
                    
                    // Note card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to access")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#002D2D"))
                        
                        Text("Log in, on your computer, through the email in your inbox.")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#374151"))
                        
                        // CTA Button
                        Button(action: {
                            // Action for accessing desktop version
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Got it")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(brandColor)
                                .cornerRadius(12)
                        }
                        .padding(.top, 4)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 1)
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 16)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(hex: "#246BFD"))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Desktop Features")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#002D2D"))
                }
            }
        }
    }
}

struct FeatureListItem: View {
    let text: String
    let iconColor: Color
    
    init(text: String, iconColor: Color = Color(hex: "#246BFD")) {
        self.text = text
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(iconColor)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "#0F1A2B"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    FeaturePromoModalView()
} 