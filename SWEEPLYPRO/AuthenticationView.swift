import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authManager = SupabaseAuthManager.shared
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#246BFD"))
                        
                        VStack(spacing: 8) {
                            Text("Welcome to Sweeply")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Manage your cleaning business with ease")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    
                    // Auth Form
                    VStack(spacing: 20) {
                        // Toggle between Sign In / Sign Up
                        HStack(spacing: 0) {
                            Button(action: { isSignUp = false }) {
                                Text("Sign In")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isSignUp ? .gray : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isSignUp ? Color.clear : Color(hex: "#246BFD"))
                            }
                            
                            Button(action: { isSignUp = true }) {
                                Text("Sign Up")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(!isSignUp ? .gray : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(!isSignUp ? Color.clear : Color(hex: "#246BFD"))
                            }
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // Auth Form Content
                        if isSignUp {
                            SignUpFormView()
                        } else {
                            SignInFormView()
                        }
                    }
                    
                    Spacer()
                }
                
                // Loading overlay
                if authManager.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Color(hex: "#246BFD"))
                        
                        Text("Please wait...")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(24)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                }
            }
            .alert("Error", isPresented: .constant(authManager.errorMessage != nil)) {
                Button("OK") {
                    authManager.errorMessage = nil
                }
            } message: {
                Text(authManager.errorMessage ?? "")
            }
        }
        .navigationBarHidden(true)
    }
}

struct SignInFormView: View {
    @StateObject private var authManager = SupabaseAuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showingForgotPassword = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }
            .padding(.horizontal, 20)
            
            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showingForgotPassword = true
                }
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#246BFD"))
            }
            .padding(.horizontal, 20)
            
            // Sign In Button
            Button(action: signIn) {
                Text("Sign In")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#246BFD"))
                    .cornerRadius(12)
            }
            .disabled(email.isEmpty || password.isEmpty)
            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .sheet(isPresented: $showingForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    private func signIn() {
        _Concurrency.Task {
            await authManager.signIn(email: email, password: password)
        }
    }
}

struct SignUpFormView: View {
    @StateObject private var authManager = SupabaseAuthManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var businessName = ""
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !name.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Name")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    TextField("Enter your full name", text: $name)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Business Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Business Name (Optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    TextField("Enter your business name", text: $businessName)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Confirm Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Password validation
                if !password.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(password.count >= 6 ? .green : .red)
                                .font(.system(size: 12))
                            Text("At least 6 characters")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        if !confirmPassword.isEmpty {
                            HStack {
                                Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(password == confirmPassword ? .green : .red)
                                    .font(.system(size: 12))
                                Text("Passwords match")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal, 20)
            
            // Sign Up Button
            Button(action: signUp) {
                Text("Create Account")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#246BFD"))
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
    
    private func signUp() {
        _Concurrency.Task {
            await authManager.signUp(
                email: email,
                password: password,
                name: name,
                businessName: businessName.isEmpty ? nil : businessName
            )
        }
    }
}

struct ForgotPasswordView: View {
    @StateObject private var authManager = SupabaseAuthManager.shared
    @State private var email = ""
    @State private var isEmailSent = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#246BFD"))
                    
                    VStack(spacing: 8) {
                        Text("Reset Password")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Enter your email address and we'll send you a link to reset your password.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 40)
                
                if !isEmailSent {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        Button(action: resetPassword) {
                            Text("Send Reset Link")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#246BFD"))
                                .cornerRadius(12)
                        }
                        .disabled(email.isEmpty)
                        .opacity(email.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text("Email Sent!")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Check your email for a link to reset your password.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#246BFD"))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "#246BFD"))
            )
        }
    }
    
    private func resetPassword() {
        _Concurrency.Task {
            await authManager.resetPassword(email: email)
            if authManager.errorMessage == nil {
                isEmailSent = true
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .font(.system(size: 16))
    }
}

#Preview {
    AuthenticationView()
} 