import SwiftUI
import UserNotifications

// MARK: - Notification Manager
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("❌ Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func sendGreetingNotification() {
        print("🔔 Attempting to send greeting notification...")
        
        let content = UNMutableNotificationContent()
        content.title = "Welcome to Sweeply Pro! 🎉"
        content.body = "Push notifications are now enabled. You'll receive important updates about your cleaning business."
        content.sound = .default
        content.badge = 1
        
        // Create a trigger for immediate delivery (2 seconds delay to ensure it shows)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "greeting-notification-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error scheduling greeting notification: \(error.localizedDescription)")
                } else {
                    print("✅ Greeting notification scheduled successfully")
                    // Also check pending notifications
                    self.checkPendingNotifications()
                }
            }
        }
    }
    
    func sendTestNotification(title: String, body: String) {
        print("🔔 Attempting to send test notification: \(title)")
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error scheduling test notification: \(error.localizedDescription)")
                } else {
                    print("✅ Test notification scheduled successfully")
                    self.checkPendingNotifications()
                }
            }
        }
    }
    
    func startRepeatingTestNotifications() {
        print("🔔 Starting repeating test notifications...")
        
        // Schedule 4 notifications, 30 seconds apart
        for i in 0..<4 {
            let content = UNMutableNotificationContent()
            content.title = "Test Notification \(i + 1)"
            content.body = "This is test notification number \(i + 1) of 4. Testing every 30 seconds."
            content.sound = .default
            content.badge = NSNumber(value: i + 1)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(i * 30), repeats: false)
            let request = UNNotificationRequest(
                identifier: "repeat-test-\(i)-\(Date().timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error scheduling repeat notification \(i + 1): \(error.localizedDescription)")
                    } else {
                        print("✅ Repeat notification \(i + 1) scheduled for \(i * 30) seconds")
                    }
                }
            }
        }
    }
    
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                print("📱 Notification status: \(settings.authorizationStatus.rawValue) - Authorized: \(isAuthorized)")
                print("📱 Alert setting: \(settings.alertSetting.rawValue)")
                print("📱 Badge setting: \(settings.badgeSetting.rawValue)")
                print("📱 Sound setting: \(settings.soundSetting.rawValue)")
                completion(isAuthorized)
            }
        }
    }
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                print("📋 Pending notifications: \(requests.count)")
                for request in requests {
                    print("  - \(request.identifier): \(request.content.title)")
                }
            }
        }
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("🗑️ All notifications removed")
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedAccount = "Business account"
    @State private var showAccountPicker = false
    @EnvironmentObject private var authManager: SupabaseAuthManager
    
    // Navigation states for different settings screens
    @State private var showAccountInfo = false
    @State private var showLoginSecurity = false
    @State private var showDataPrivacy = false
    @State private var showNotificationPreferences = false
    @State private var showMarketingPreferences = false
    @State private var showStatementsTaxes = false
    @State private var showMessageCenter = false
    @State private var showHelp = false
    @State private var showCloseAccount = false
    @State private var showLogoutConfirmation = false
    
    // Colors
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let dividerColor = Color(hex: "#E5E7EB")
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let accentColor = Color(hex: "#246BFD")
    let dangerColor = Color(hex: "#DC2626")
    
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
                        settingsLink(icon: "person.circle", title: "Account info") {
                            showAccountInfo = true
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "lock.shield", title: "Login and security") {
                            showLoginSecurity = true
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "eye", title: "Data and privacy") {
                            showDataPrivacy = true
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "bell", title: "Notification preferences") {
                            showNotificationPreferences = true
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "dollarsign.circle", title: "Marketing preferences") {
                            showMarketingPreferences = true
                        }
                    }
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Business settings group
                    VStack(spacing: 0) {
                        settingsLink(icon: "doc.text", title: "Statements and taxes") {
                            showStatementsTaxes = true
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        notificationLink(icon: "message", title: "Message Center", notificationCount: 1) {
                            showMessageCenter = true
                        }
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        settingsLink(icon: "questionmark.circle", title: "Help") {
                            showHelp = true
                        }
                    }
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Account actions group
                    VStack(spacing: 0) {
                        settingsLink(icon: "trash", title: "Close your account", textColor: dangerColor) {
                            showCloseAccount = true
                        }
                    }
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Log out button
                    VStack(spacing: 0) {
                        settingsLink(icon: "arrow.right.square", title: "Log out") {
                            showLogoutConfirmation = true
                        }
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
        }
            .confirmationDialog("Select Account Type", isPresented: $showAccountPicker, titleVisibility: .visible) {
                Button("Business account") {
                    selectedAccount = "Business account"
                }
                Button("Personal account") {
                    selectedAccount = "Personal account"
                }
                Button("Cancel", role: .cancel) {}
            }
        .sheet(isPresented: $showAccountInfo) {
            AccountInfoView()
        }
        .sheet(isPresented: $showLoginSecurity) {
            LoginSecurityView()
        }
        .sheet(isPresented: $showDataPrivacy) {
            DataPrivacyView()
        }
        .sheet(isPresented: $showNotificationPreferences) {
            NotificationPreferencesView()
        }
        .sheet(isPresented: $showMarketingPreferences) {
            MarketingPreferencesView()
        }
        .sheet(isPresented: $showStatementsTaxes) {
            StatementsTaxesView()
        }
        .sheet(isPresented: $showMessageCenter) {
            MessageCenterView()
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .sheet(isPresented: $showCloseAccount) {
            CloseAccountView()
        }
        .alert("Log Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                // Handle logout
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    // Helper function to create consistent settings links
    private func settingsLink(icon: String, title: String, textColor: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(textColor ?? primaryColor)
                .frame(width: 36, height: 36)
            
            Text(title)
                .font(.system(size: 18))
                    .foregroundColor(textColor ?? textColor)
            
            Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper function for links with notification badge
    private func notificationLink(icon: String, title: String, notificationCount: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(primaryColor)
                .frame(width: 36, height: 36)
            
            Text(title)
                .font(.system(size: 18))
                    .foregroundColor(textColor)
            
            Spacer()
            
            if notificationCount > 0 {
                Text("\(notificationCount)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                        .background(dangerColor)
                    .clipShape(Circle())
            }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Handle logout functionality
    private func handleLogout() {
        _Concurrency.Task {
            await authManager.signOut()
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Account Info View
struct AccountInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: SupabaseAuthManager
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var businessName = ""
    @State private var businessAddress = ""
    @State private var showSavedAlert = false
    @State private var isUpdating = false
    
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile picture section
                    VStack(spacing: 16) {
                        Circle()
                            .fill(primaryColor.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Group {
                                    if let profileImageUrl = authManager.userProfile?.profileImageUrl,
                                       !profileImageUrl.isEmpty {
                                        // Load actual image from URL
                                        AsyncImage(url: URL(string: profileImageUrl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Image(systemName: "person.circle.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(primaryColor)
                                        }
                                        .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(primaryColor)
                                    }
                                }
                            )
                        
                        Button("Change Photo") {
                            // Handle photo change
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(primaryColor)
                        
                        // Subscription tier
                        HStack(spacing: 4) {
                            Image(systemName: authManager.isPremiumUser ? "crown.fill" : "person.fill")
                                .font(.system(size: 14))
                                .foregroundColor(authManager.isPremiumUser ? Color(hex: "#FFD700") : mutedTextColor)
                            
                            Text(authManager.subscriptionTier.capitalized)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(authManager.isPremiumUser ? Color(hex: "#FFD700") : mutedTextColor)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Personal Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Personal Information")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 12) {
                            inputField(title: "Email", text: $email)
                                .disabled(true) // Email cannot be changed
                            inputField(title: "Phone Number", text: $phoneNumber)
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Business Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Business Information")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 12) {
                            inputField(title: "Business Name", text: $businessName)
                            inputField(title: "Business Address", text: $businessAddress)
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Save button
                    Button(action: updateProfile) {
                        HStack {
                            if isUpdating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            }
                            
                            Text(isUpdating ? "Updating..." : "Save Changes")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(primaryColor)
                        .cornerRadius(12)
                    }
                    .disabled(isUpdating)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Account Info", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
            .onAppear {
                loadProfileData()
            }
        }
        .alert("Changes Saved", isPresented: $showSavedAlert) {
            Button("OK") {}
        } message: {
            Text("Your account information has been updated successfully.")
        }
    }
    
    private func loadProfileData() {
        email = authManager.currentUser?.email ?? ""
        
        if let profile = authManager.userProfile {
            businessName = profile.businessName ?? ""
            phoneNumber = profile.phoneNumber ?? ""
            businessAddress = profile.address ?? ""
        }
    }
    
    private func updateProfile() {
        guard let currentProfile = authManager.userProfile else { return }
        
        isUpdating = true
        
        let updatedProfile = UserProfile(
            id: currentProfile.id,
            userId: currentProfile.userId,
            businessName: businessName.isEmpty ? nil : businessName,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            address: businessAddress.isEmpty ? nil : businessAddress,
            profileImageUrl: currentProfile.profileImageUrl,
            subscriptionTier: currentProfile.subscriptionTier,
            createdAt: currentProfile.createdAt,
            updatedAt: Date()
        )
        
        _Concurrency.Task {
            await authManager.updateProfile(updatedProfile)
            isUpdating = false
            showSavedAlert = true
        }
    }
    
    private func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(mutedTextColor)
            
            TextField("", text: text)
                .font(.system(size: 16))
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

// MARK: - Login & Security View
struct LoginSecurityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var twoFactorEnabled = false
    @State private var biometricEnabled = true
    @State private var showChangePasswordAlert = false
    
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Password section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Password")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 12) {
                            SecureField("Current Password", text: $currentPassword)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            SecureField("New Password", text: $newPassword)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            
                            SecureField("Confirm New Password", text: $confirmPassword)
                                .font(.system(size: 16))
                                .padding(12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Button("Change Password") {
                            showChangePasswordAlert = true
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(primaryColor)
                        .cornerRadius(8)
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Security options
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Security Options")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 16) {
                            // Two-factor authentication
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Two-Factor Authentication")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(textColor)
                                    
                                    Text("Add an extra layer of security to your account")
                                        .font(.system(size: 14))
                                        .foregroundColor(mutedTextColor)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $twoFactorEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                            }
                            
                            Divider()
                            
                            // Biometric authentication
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Biometric Authentication")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(textColor)
                                    
                                    Text("Use Face ID or Touch ID to sign in")
                                        .font(.system(size: 14))
                                        .foregroundColor(mutedTextColor)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $biometricEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                            }
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Login & Security", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
        }
        .alert("Password Changed", isPresented: $showChangePasswordAlert) {
            Button("OK") {}
        } message: {
            Text("Your password has been updated successfully.")
        }
    }
}

// MARK: - Data & Privacy View
struct DataPrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dataCollection = true
    @State private var analytics = false
    @State private var crashReporting = true
    @State private var locationTracking = true
    
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Data Collection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Data Collection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 16) {
                            toggleOption(
                                title: "Data Collection",
                                description: "Allow Sweeply to collect usage data to improve the app",
                                isOn: $dataCollection
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "Analytics",
                                description: "Share anonymous analytics to help us understand app usage",
                                isOn: $analytics
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "Crash Reporting",
                                description: "Automatically send crash reports to help us fix issues",
                                isOn: $crashReporting
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "Location Tracking",
                                description: "Allow location access for route optimization and scheduling",
                                isOn: $locationTracking
                            )
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Data Management
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Data Management")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 12) {
                            actionButton(title: "Download My Data", icon: "arrow.down.circle") {
                                // Handle data download
                            }
                            
                            actionButton(title: "Delete My Data", icon: "trash", isDestructive: true) {
                                // Handle data deletion
                            }
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Data & Privacy", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
        }
    }
    
    private func toggleOption(title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
        }
    }
    
    private func actionButton(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? Color.red : primaryColor)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDestructive ? Color.red : textColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Notification Preferences View
struct NotificationPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = true
    @State private var smsNotifications = false
    @State private var appointmentReminders = true
    @State private var paymentReminders = true
    @State private var marketingEmails = false
    @State private var weeklyReports = true
    @State private var showPermissionAlert = false
    @State private var showTestNotificationAlert = false
    
    @StateObject private var notificationManager = NotificationManager.shared

    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // General Notifications
                    VStack(alignment: .leading, spacing: 16) {
                        Text("General Notifications")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 16) {
                            toggleOption(
                                title: "Push Notifications",
                                description: "Receive notifications on your device",
                                isOn: $pushNotifications,
                                onChange: { isEnabled in
                                    handlePushNotificationToggle(isEnabled)
                                }
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "Email Notifications",
                                description: "Receive notifications via email",
                                isOn: $emailNotifications
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "SMS Notifications",
                                description: "Receive notifications via text message",
                                isOn: $smsNotifications
                            )
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Business Notifications
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Business Notifications")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 16) {
                            toggleOption(
                                title: "Appointment Reminders",
                                description: "Get reminded about upcoming appointments",
                                isOn: $appointmentReminders,
                                onChange: { isEnabled in
                                    if isEnabled && pushNotifications {
                                        notificationManager.sendTestNotification(
                                            title: "Appointment Reminder 📅",
                                            body: "You have a cleaning appointment tomorrow at 2:00 PM with Johnson Residence."
                                        )
                                    }
                                }
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "Payment Reminders",
                                description: "Get notified about pending payments",
                                isOn: $paymentReminders,
                                onChange: { isEnabled in
                                    if isEnabled && pushNotifications {
                                        notificationManager.sendTestNotification(
                                            title: "Payment Reminder 💰",
                                            body: "You have 2 pending payments totaling $450. Review your invoices now."
                                        )
                                    }
                                }
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "Weekly Reports",
                                description: "Receive weekly business performance reports",
                                isOn: $weeklyReports,
                                onChange: { isEnabled in
                                    if isEnabled && pushNotifications {
                                        notificationManager.sendTestNotification(
                                            title: "Weekly Report 📊",
                                            body: "Your weekly business report is ready! Revenue: $1,250 | Jobs: 15 | Team performance: Excellent"
                                        )
                                    }
                                }
                            )
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Marketing
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Marketing")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 16) {
                            toggleOption(
                                title: "Marketing Emails",
                                description: "Receive promotional emails and updates",
                                isOn: $marketingEmails
                            )
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Test Notification Button
                    if pushNotifications {
                        Button(action: {
                            showTestNotificationAlert = true
                        }) {
                            HStack {
                                Image(systemName: "bell.badge")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Send Test Notification")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(primaryColor)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Debug Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Debug & Troubleshooting")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 12) {
                            // Check Status Button
                            Button(action: {
                                notificationManager.checkNotificationStatus { isAuthorized in
                                    print("Current authorization status: \(isAuthorized)")
                                }
                                notificationManager.checkPendingNotifications()
                            }) {
                                HStack {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("Check Notification Status")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(primaryColor)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(primaryColor.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            // Force Send Greeting
                            Button(action: {
                                notificationManager.sendGreetingNotification()
                            }) {
                                HStack {
                                    Image(systemName: "paperplane")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("Force Send Greeting")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(Color.orange)
                                .cornerRadius(10)
                            }
                            
                            // Clear All Notifications
                            Button(action: {
                                notificationManager.removeAllNotifications()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("Clear All Notifications")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(Color.red)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Notifications", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
            .alert("Notification Permission", isPresented: $showPermissionAlert) {
                Button("Go to Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) {
                    pushNotifications = false
                }
            } message: {
                Text("To receive push notifications, please enable them in your device settings.")
            }
            .alert("Test Notification", isPresented: $showTestNotificationAlert) {
                Button("Business Update") {
                    notificationManager.sendTestNotification(
                        title: "Business Update 🏢",
                        body: "Great news! You've completed 5 jobs today and earned $625. Keep up the excellent work!"
                    )
                }
                Button("New Job Alert") {
                    notificationManager.sendTestNotification(
                        title: "New Job Alert 🧹",
                        body: "You have a new cleaning job request from Smith Family for tomorrow at 10:00 AM."
                    )
                }
                Button("Team Update") {
                    notificationManager.sendTestNotification(
                        title: "Team Update 👥",
                        body: "Sarah Johnson has completed her assigned jobs for today. All tasks finished successfully!"
                    )
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Choose a test notification to send:")
            }
        }
    }
    
    private func handlePushNotificationToggle(_ isEnabled: Bool) {
        if isEnabled {
            // Check current notification status
            notificationManager.checkNotificationStatus { isAuthorized in
                if isAuthorized {
                    // Already authorized, send greeting notification
                    notificationManager.sendGreetingNotification()
                } else {
                    // Request permission
                    notificationManager.requestPermission()
                    // Wait a moment then check status and send greeting if granted
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        notificationManager.checkNotificationStatus { isNowAuthorized in
                            if isNowAuthorized {
                                notificationManager.sendGreetingNotification()
                            } else {
                                showPermissionAlert = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func toggleOption(title: String, description: String, isOn: Binding<Bool>, onChange: ((Bool) -> Void)? = nil) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                .onChange(of: isOn.wrappedValue) { newValue in
                    onChange?(newValue)
                }
        }
    }
}

// MARK: - Marketing Preferences View
struct MarketingPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var emailMarketing = false
    @State private var smsMarketing = false
    @State private var productUpdates = true
    @State private var industryNews = false
    @State private var specialOffers = true
    
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Communication Preferences
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Communication Preferences")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 16) {
                            toggleOption(
                                title: "Email Marketing",
                                description: "Receive marketing emails and newsletters",
                                isOn: $emailMarketing
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "SMS Marketing",
                                description: "Receive marketing text messages",
                                isOn: $smsMarketing
                            )
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Content Preferences
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Content Preferences")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 16) {
                            toggleOption(
                                title: "Product Updates",
                                description: "Get notified about new features and updates",
                                isOn: $productUpdates
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "Industry News",
                                description: "Receive cleaning industry news and tips",
                                isOn: $industryNews
                            )
                            
                            Divider()
                            
                            toggleOption(
                                title: "Special Offers",
                                description: "Get exclusive deals and promotions",
                                isOn: $specialOffers
                            )
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Marketing", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
        }
    }
    
    private func toggleOption(title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
        }
    }
}

// MARK: - Statements & Taxes View
struct StatementsTaxesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var statements: [Statement] = [
        Statement(id: UUID(), month: "December 2024", amount: 4250.00, status: "Available"),
        Statement(id: UUID(), month: "November 2024", amount: 3890.50, status: "Available"),
        Statement(id: UUID(), month: "October 2024", amount: 4100.75, status: "Available")
    ]
    
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Monthly Statements
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Monthly Statements")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(statements) { statement in
                                statementRow(statement: statement)
                            }
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Tax Documents
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tax Documents")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 12) {
                            taxDocumentRow(title: "2024 Tax Summary", status: "Available")
                            taxDocumentRow(title: "2023 Tax Summary", status: "Available")
                            taxDocumentRow(title: "2022 Tax Summary", status: "Available")
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Statements & Taxes", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
        }
    }
    
    private func statementRow(statement: Statement) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(statement.month)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                Text("$\(String(format: "%.2f", statement.amount))")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            Button("Download") {
                // Handle download
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(primaryColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(primaryColor.opacity(0.1))
            .cornerRadius(6)
        }
        .padding(.vertical, 8)
    }
    
    private func taxDocumentRow(title: String, status: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                Text(status)
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            Button("Download") {
                // Handle download
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(primaryColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(primaryColor.opacity(0.1))
            .cornerRadius(6)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Message Center View
struct MessageCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [Message] = [
        Message(id: UUID(), title: "New Feature Available", content: "Check out our new team management features!", date: Date(), isRead: false),
        Message(id: UUID(), title: "Payment Processed", content: "Your payment of $125.00 has been processed successfully.", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), isRead: true),
        Message(id: UUID(), title: "Welcome to Sweeply Pro", content: "Thank you for upgrading to Sweeply Pro! Here's what's new...", date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), isRead: true)
    ]
    
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        messageRow(message: message)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Message Center", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
        }
    }
    
    private func messageRow(message: Message) -> some View {
        HStack(spacing: 12) {
            // Unread indicator
            Circle()
                .fill(message.isRead ? Color.clear : primaryColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(message.title)
                    .font(.system(size: 16, weight: message.isRead ? .medium : .semibold))
                    .foregroundColor(textColor)
                
                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
                    .lineLimit(2)
                
                Text(message.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundColor(mutedTextColor)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(mutedTextColor)
        }
        .padding(16)
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        .onTapGesture {
            // Mark as read and show details
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index].isRead = true
            }
        }
    }
}

// MARK: - Help View
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    let helpTopics = [
        HelpTopic(title: "Getting Started", items: [
            "How to create your first client",
            "Setting up your schedule",
            "Creating invoices and quotes"
        ]),
        HelpTopic(title: "Team Management", items: [
            "Adding team members",
            "Managing schedules",
            "Setting up permissions"
        ]),
        HelpTopic(title: "Billing & Payments", items: [
            "Processing payments",
            "Managing invoices",
            "Setting up automatic billing"
        ]),
        HelpTopic(title: "Technical Support", items: [
            "Troubleshooting common issues",
            "Contacting support",
            "Reporting bugs"
        ])
    ]
    
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(mutedTextColor)
                        
                        TextField("Search help topics", text: $searchText)
                            .font(.system(size: 16))
                    }
                    .padding(12)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Help topics
                    ForEach(helpTopics, id: \.title) { topic in
                        helpTopicSection(topic: topic)
                    }
                    
                    // Contact support
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Need More Help?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 12) {
                            contactButton(title: "Email Support", icon: "envelope", action: {
                                // Handle email support
                            })
                            
                            contactButton(title: "Live Chat", icon: "message", action: {
                                // Handle live chat
                            })
                            
                            contactButton(title: "Call Support", icon: "phone", action: {
                                // Handle phone support
                            })
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Help", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
        }
    }
    
    private func helpTopicSection(topic: HelpTopic) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(topic.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            VStack(spacing: 8) {
                ForEach(topic.items, id: \.self) { item in
                    HStack {
                        Text(item)
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(mutedTextColor)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    .onTapGesture {
                        // Handle help item tap
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
    }
    
    private func contactButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(primaryColor)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(mutedTextColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Close Account View
struct CloseAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reason = ""
    @State private var feedback = ""
    @State private var confirmDeletion = false
    @State private var showFinalConfirmation = false
    
    let primaryColor = Color(hex: "#246BFD")
    let backgroundColor = Color(hex: "#F5F5F5")
    let cardBackgroundColor = Color.white
    let textColor = Color(hex: "#1A1A1A")
    let mutedTextColor = Color(hex: "#5E7380")
    let dangerColor = Color(hex: "#DC2626")
    
    let reasons = [
        "No longer need the service",
        "Found a better alternative",
        "Too expensive",
        "Technical issues",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Warning section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(dangerColor)
                            
                            Text("Account Closure Warning")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(dangerColor)
                        }
                        
                        Text("Closing your account will permanently delete all your data including clients, schedules, invoices, and team information. This action cannot be undone.")
                            .font(.system(size: 14))
                            .foregroundColor(textColor)
                    }
                    .padding(16)
                    .background(dangerColor.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Reason selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Why are you closing your account?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        VStack(spacing: 8) {
                            ForEach(reasons, id: \.self) { reasonOption in
                                Button(action: {
                                    reason = reasonOption
                                }) {
                                    HStack {
                                        Image(systemName: reason == reasonOption ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(reason == reasonOption ? primaryColor : mutedTextColor)
                                        
                                        Text(reasonOption)
                                            .font(.system(size: 16))
                                            .foregroundColor(textColor)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Feedback section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Additional Feedback (Optional)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textColor)
                        
                        TextField("Help us improve by sharing your feedback", text: $feedback, axis: .vertical)
                            .font(.system(size: 16))
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .lineLimit(4, reservesSpace: true)
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    // Confirmation
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $confirmDeletion) {
                            Text("I understand that this action cannot be undone and all my data will be permanently deleted.")
                                .font(.system(size: 14))
                                .foregroundColor(textColor)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: dangerColor))
                        
                        Button("Close Account") {
                            showFinalConfirmation = true
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(confirmDeletion ? dangerColor : Color.gray)
                        .cornerRadius(12)
                        .disabled(!confirmDeletion)
                    }
                    .padding(16)
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(backgroundColor)
            .navigationBarTitle("Close Account", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(primaryColor)
            )
        }
        .alert("Final Confirmation", isPresented: $showFinalConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Close Account", role: .destructive) {
                // Handle account closure
                dismiss()
            }
        } message: {
            Text("Are you absolutely sure you want to close your account? This action cannot be undone.")
        }
    }
}

// MARK: - Supporting Data Models
struct Statement: Identifiable {
    let id: UUID
    let month: String
    let amount: Double
    let status: String
}

struct Message: Identifiable {
    let id: UUID
    let title: String
    let content: String
    let date: Date
    var isRead: Bool
}

struct HelpTopic {
    let title: String
    let items: [String]
}

#Preview {
    SettingsView()
} 