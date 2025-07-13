import Foundation
import Supabase
import SwiftUI

// MARK: - User Models
struct AppUser: Codable {
    let id: String
    let email: String
    let name: String?
    let createdAt: Date
    let lastSignIn: Date?
}

struct UserProfile: Codable {
    let id: String
    let userId: String
    let businessName: String?
    let phoneNumber: String?
    let address: String?
    let profileImageUrl: String?
    let subscriptionTier: String // "free", "pro", "enterprise"
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Authentication Manager
@MainActor
class SupabaseAuthManager: ObservableObject {
    static let shared = SupabaseAuthManager()
    
    @Published var currentUser: AppUser?
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase: SupabaseClient
    
    private init() {
        // Your Supabase configuration
        let url = URL(string: "https://nzidlxeqrcxfrdesyiyb.supabase.co")!
        let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im56aWRseGVxcmN4ZnJkZXN5aXliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzNjU4NzgsImV4cCI6MjA2Nzk0MTg3OH0.yN7cvjXZTrZGbQXO5OX38SEZVmRN8ug6fyeRTwkZt6E"
        
        self.supabase = SupabaseClient(supabaseURL: url, supabaseKey: key)
        
        // Check for existing session
        _Concurrency.Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, name: String, businessName: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Sign up with Supabase Auth
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            let user = authResponse.user
            
            // Create user profile
            let profile = UserProfile(
                id: UUID().uuidString,
                userId: user.id.uuidString,
                businessName: businessName,
                phoneNumber: nil,
                address: nil,
                profileImageUrl: nil,
                subscriptionTier: "free",
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // Insert profile into Supabase
            try await supabase.database
                .from("user_profiles")
                .insert(profile)
                .execute()
            
            // Update local state
            self.currentUser = AppUser(
                id: user.id.uuidString,
                email: user.email ?? email,
                name: name,
                createdAt: Date(),
                lastSignIn: nil
            )
            self.userProfile = profile
            self.isAuthenticated = true
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            let user = session.user
            
            // Fetch user profile
            await fetchUserProfile(userId: user.id.uuidString)
            
            // Update local state
            self.currentUser = AppUser(
                id: user.id.uuidString,
                email: user.email ?? email,
                name: userProfile?.businessName,
                createdAt: Date(), // This should come from the database
                lastSignIn: Date()
            )
            self.isAuthenticated = true
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            
            // Clear local state
            self.currentUser = nil
            self.userProfile = nil
            self.isAuthenticated = false
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            // Success - user will receive email
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Profile Management
    
    func updateProfile(_ profile: UserProfile) async {
        do {
            let updatedProfile = UserProfile(
                id: profile.id,
                userId: profile.userId,
                businessName: profile.businessName,
                phoneNumber: profile.phoneNumber,
                address: profile.address,
                profileImageUrl: profile.profileImageUrl,
                subscriptionTier: profile.subscriptionTier,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            
            try await supabase.database
                .from("user_profiles")
                .update(updatedProfile)
                .eq("user_id", value: profile.userId)
                .execute()
            
            self.userProfile = updatedProfile
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthStatus() async {
        do {
            let session = try await supabase.auth.session
            
            let user = session.user
            await fetchUserProfile(userId: user.id.uuidString)
            
            self.currentUser = AppUser(
                id: user.id.uuidString,
                email: user.email ?? "",
                name: userProfile?.businessName,
                createdAt: Date(),
                lastSignIn: Date()
            )
            self.isAuthenticated = true
        } catch {
            // No active session
            self.isAuthenticated = false
        }
    }
    
    private func fetchUserProfile(userId: String) async {
        do {
            let response: [UserProfile] = try await supabase.database
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            if let profile = response.first {
                self.userProfile = profile
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - SwiftUI Integration
extension SupabaseAuthManager {
    var isSignedIn: Bool {
        isAuthenticated && currentUser != nil
    }
    
    var userDisplayName: String {
        currentUser?.name ?? userProfile?.businessName ?? currentUser?.email ?? "User"
    }
    
    var subscriptionTier: String {
        userProfile?.subscriptionTier ?? "free"
    }
    
    var isPremiumUser: Bool {
        subscriptionTier == "pro" || subscriptionTier == "enterprise"
    }
} 