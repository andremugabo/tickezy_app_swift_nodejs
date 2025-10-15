//
//  SignupView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Form Fields
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phoneNumber = ""
    
    // MARK: - State
    @State private var signupError: String?
    @State private var navigateNext = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var showPassword = false
    
    // Focus states
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password, phone
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Spacer()
                        .frame(height: 5)
                    
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Input Fields
                    inputFieldsSection
                    
                    // MARK: - Signup Button
                    signupButton
                    
                    // MARK: - Terms
                    termsSection
                    
                    // MARK: - Login Link
                    loginSection
                    
                    Spacer()
                        .frame(height: 15)
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isSuccess ? "Welcome!" : "Signup Failed"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
                    if isSuccess { navigateNext = true }
                })
            )
        }
        .navigationDestination(isPresented: $navigateNext) {
            MainTabView()
                .navigationBarBackButtonHidden()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            // Logo with glow
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .blur(radius: 15)
                
                Image("logo1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            
            VStack(spacing: 4) {
                Text("Create Account")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text("Join us and discover events")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    // MARK: - Input Fields Section
    
    private var inputFieldsSection: some View {
        VStack(spacing: 12) {
            // Name Field
            VStack(alignment: .leading, spacing: 4) {
                Text("Full Name")
                    .font(.caption2.bold())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 10) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.brandPrimary)
                        .frame(width: 18)
                        .font(.caption)
                    
                    TextField("Enter your name", text: $name)
                        .autocapitalization(.words)
                        .foregroundColor(.textPrimary)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .email
                        }
                }
                .padding(12)
                .background(Color.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            focusedField == .name ? Color.brandPrimary : Color.border,
                            lineWidth: focusedField == .name ? 2 : 1
                        )
                )
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 4) {
                Text("Email")
                    .font(.caption2.bold())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.brandPrimary)
                        .frame(width: 18)
                        .font(.caption)
                    
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .foregroundColor(.textPrimary)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }
                }
                .padding(12)
                .background(Color.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            focusedField == .email ? Color.brandPrimary : Color.border,
                            lineWidth: focusedField == .email ? 2 : 1
                        )
                )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 4) {
                Text("Password")
                    .font(.caption2.bold())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.brandPrimary)
                        .frame(width: 18)
                        .font(.caption)
                    
                    if showPassword {
                        TextField("Create a password", text: $password)
                            .foregroundColor(.textPrimary)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .phone
                            }
                    } else {
                        SecureField("Create a password", text: $password)
                            .foregroundColor(.textPrimary)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .phone
                            }
                    }
                    
                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.textTertiary)
                            .font(.caption)
                    }
                }
                .padding(12)
                .background(Color.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            focusedField == .password ? Color.brandPrimary : Color.border,
                            lineWidth: focusedField == .password ? 2 : 1
                        )
                )
                
                // Password strength indicator
                if !password.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(passwordStrengthColor(for: index))
                                .frame(height: 3)
                        }
                    }
                    .padding(.top, 2)
                    
                    Text(passwordStrengthText())
                        .font(.caption2)
                        .foregroundColor(passwordStrengthColor(for: 0))
                }
            }
            
            // Phone Field
            VStack(alignment: .leading, spacing: 4) {
                Text("Phone Number")
                    .font(.caption2.bold())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 10) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.brandPrimary)
                        .frame(width: 18)
                        .font(.caption)
                    
                    TextField("Enter your phone", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .foregroundColor(.textPrimary)
                        .focused($focusedField, equals: .phone)
                        .submitLabel(.go)
                        .onSubmit {
                            Task { await signupUser() }
                        }
                }
                .padding(12)
                .background(Color.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            focusedField == .phone ? Color.brandPrimary : Color.border,
                            lineWidth: focusedField == .phone ? 2 : 1
                        )
                )
            }
            
            // Error Message
            if let error = signupError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text(error)
                        .font(.caption2)
                }
                .foregroundColor(.stateError)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Signup Button
    
    private var signupButton: some View {
        Button {
            focusedField = nil
            Task { await signupUser() }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "person.badge.plus.fill")
                }
                
                Text(isLoading ? "Creating..." : "Create Account")
                    .font(.subheadline.bold())
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                isFormValid && !isLoading ?
                LinearGradient(
                    colors: [Color.brandPrimary, Color.brandSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(
                color: isFormValid && !isLoading ? Color.brandPrimary.opacity(0.4) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(!isFormValid || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isFormValid)
    }
    
    // MARK: - Terms Section
    
    private var termsSection: some View {
        Text("By creating an account, you agree to our Terms and Privacy Policy")
            .font(.caption2)
            .foregroundColor(.textTertiary)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Login Section
    
    private var loginSection: some View {
        VStack(spacing: 10) {
            Text("Already have an account?")
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            NavigationLink {
                LoginView()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                    Text("Sign In")
                        .font(.subheadline.bold())
                }
                .foregroundColor(.brandPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.brandPrimary, lineWidth: 2)
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        name.count >= 2 &&
        !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password.count >= 6 &&
        !phoneNumber.isEmpty &&
        phoneNumber.count >= 10
    }
    
    // MARK: - Password Strength
    
    private func passwordStrengthColor(for index: Int) -> Color {
        let strength = passwordStrength()
        if index < strength {
            switch strength {
            case 1: return .stateError
            case 2: return .stateWarning
            case 3: return .stateSuccess
            default: return .textTertiary
            }
        }
        return .textTertiary.opacity(0.3)
    }
    
    private func passwordStrength() -> Int {
        let length = password.count
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        
        if length < 6 { return 1 }
        if length >= 6 && (hasUppercase || hasNumber) { return 2 }
        if length >= 8 && hasUppercase && hasNumber { return 3 }
        return 1
    }
    
    private func passwordStrengthText() -> String {
        switch passwordStrength() {
        case 1: return "Weak password"
        case 2: return "Medium password"
        case 3: return "Strong password"
        default: return ""
        }
    }
    
    // MARK: - Signup Function
    
    private func signupUser() async {
        signupError = nil
        isLoading = true
        
        do {
            try await auth.register(
                name: name,
                email: email,
                password: password,
                phoneNumber: phoneNumber
            )
            
            await MainActor.run {
                isSuccess = true
                alertMessage = "Welcome to TICKEZY! 🎉"
                showAlert = true
            }
            
            // Small delay for better UX
            try? await Task.sleep(nanoseconds: 500_000_000)
            
        } catch {
            await MainActor.run {
                isSuccess = false
                
                if let nsError = error as NSError?,
                   let serverMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
                    signupError = serverMessage
                    alertMessage = serverMessage
                } else {
                    signupError = error.localizedDescription
                    alertMessage = error.localizedDescription
                }
                
                showAlert = true
                isLoading = false
            }
            return
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AuthService.shared)
    }
}
