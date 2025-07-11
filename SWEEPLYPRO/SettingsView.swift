import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedAccount = "Business account"
    @State private var showAccountPicker = false
    
    // Colors
    let primaryColor = Color(hex: "#153B3F")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let dividerColor = Color(hex: "#E5E7EB")
    let textColor = Color(hex: "#4A5568")
    let accentColor = Color(hex: "#246BFD")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Account selector
                    Button(action: {
                        showAccountPicker = true
                    }) {
                        HStack {
                            Text(selectedAccount)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(primaryColor)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(primaryColor)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#F4F4F2"))
                        )
                    }
                    .padding(.top, 10)
                    
                    // Account settings group
                    VStack(spacing: 0) {
                        settingsLink(icon: "person.circle", title: "Account info")
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "lock.shield", title: "Login and security")
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "eye", title: "Data and privacy")
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "bell", title: "Notification preferences")
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "dollarsign.circle", title: "Marketing preferences")
                    }
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Business settings group
                    VStack(spacing: 0) {
                        settingsLink(icon: "doc.text", title: "Statements and taxes")
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        notificationLink(icon: "message", title: "Message Center", notificationCount: 1)
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "questionmark.circle", title: "Help")
                    }
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Account actions group
                    VStack(spacing: 0) {
                        settingsLink(icon: "trash", title: "Close your account", textColor: Color(hex: "#DC2626"))
                    }
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Log out button
                    VStack(spacing: 0) {
                        settingsLink(icon: "arrow.right.square", title: "Log out")
                    }
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Bottom padding
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                leading: HStack(spacing: 8) {
                    Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(primaryColor)
                    }
                    
                    Text("Settings")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(primaryColor)
                }
            )
            .confirmationDialog("Select Account Type", isPresented: $showAccountPicker, titleVisibility: .visible) {
                Button("Business account") {
                    selectedAccount = "Business account"
                }
                Button("Personal account") {
                    selectedAccount = "Personal account"
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    // Helper function to create consistent settings links
    private func settingsLink(icon: String, title: String, textColor: Color? = nil) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(textColor ?? primaryColor)
                .frame(width: 36, height: 36)
            
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(textColor ?? primaryColor)
            
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap action for specific setting
            print("Tapped on \(title)")
        }
    }
    
    // Helper function for links with notification badge
    private func notificationLink(icon: String, title: String, notificationCount: Int) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(primaryColor)
                .frame(width: 36, height: 36)
            
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(primaryColor)
            
            Spacer()
            
            if notificationCount > 0 {
                Text("\(notificationCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color(hex: "#DC2626"))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle tap action for notification item
            print("Tapped on \(title)")
        }
    }
}

#Preview {
    SettingsView()
} 