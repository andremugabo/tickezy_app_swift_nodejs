//
//  LoginView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String?
    @State private var navigateNext = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var showPassword = false
    
    // Focus states for keyboard management
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 10)
                    
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Input Fields
                    inputFieldsSection
                    
                    // MARK: - Login Button
                    loginButton
                    
                    // MARK: - Forgot Password
                    forgotPasswordButton
                    
                    // MARK: - Divider
                    dividerSection
                    
                    // MARK: - Signup Link
                    signupSection
                    
                    Spacer()
                        .frame(height: 20)
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isSuccess ? "Success" : "Login Failed"),
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
        VStack(spacing: 12) {
            // Logo with glow
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.2))
                    .frame(width: 90, height: 90)
                    .blur(radius: 20)
                
                Image("logo1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            
            VStack(spacing: 6) {
                Text("Welcome Back")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text("Sign in to continue your journey")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    // MARK: - Input Fields Section
    
    private var inputFieldsSection: some View {
        VStack(spacing: 14) {
            // Email Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption.bold())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.brandPrimary)
                        .frame(width: 20)
                    
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
                .padding(14)
                .background(Color.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            focusedField == .email ? Color.brandPrimary : Color.border,
                            lineWidth: focusedField == .email ? 2 : 1
                        )
                )
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption.bold())
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.brandPrimary)
                        .frame(width: 20)
                    
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .foregroundColor(.textPrimary)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                Task { await loginUser() }
                            }
                    } else {
                        SecureField("Enter your password", text: $password)
                            .foregroundColor(.textPrimary)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                Task { await loginUser() }
                            }
                    }
                    
                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
                .padding(14)
                .background(Color.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            focusedField == .password ? Color.brandPrimary : Color.border,
                            lineWidth: focusedField == .password ? 2 : 1
                        )
                )
            }
            
            // Error Message
            if let error = loginError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text(error)
                        .font(.caption)
                }
                .foregroundColor(.stateError)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // MARK: - Login Button
    
    private var loginButton: some View {
        Button {
            focusedField = nil
            Task { await loginUser() }
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                
                Text(isLoading ? "Signing in..." : "Sign In")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
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
            .cornerRadius(14)
            .shadow(
                color: isFormValid && !isLoading ? Color.brandPrimary.opacity(0.4) : Color.clear,
                radius: 12,
                x: 0,
                y: 8
            )
        }
        .disabled(!isFormValid || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isFormValid)
    }
    
    // MARK: - Forgot Password Button
    
    private var forgotPasswordButton: some View {
        Button {
            // Handle forgot password
        } label: {
            Text("Forgot Password?")
                .font(.subheadline)
                .foregroundColor(.brandPrimary)
        }
    }
    
    // MARK: - Divider Section
    
    private var dividerSection: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.divider)
                .frame(height: 1)
            
            Text("OR")
                .font(.caption.bold())
                .foregroundColor(.textTertiary)
            
            Rectangle()
                .fill(Color.divider)
                .frame(height: 1)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Signup Section
    
    private var signupSection: some View {
        VStack(spacing: 12) {
            Text("Don't have an account?")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            NavigationLink {
                SignupView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                    Text("Create Account")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.brandPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.surface)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.brandPrimary, lineWidth: 2)
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        !password.isEmpty &&
        password.count >= 6
    }
    
    // MARK: - Login Function
    
    private func loginUser() async {
        loginError = nil
        isLoading = true
        
        do {
            try await auth.login(email: email, password: password)
            
            await MainActor.run {
                isSuccess = true
                alertMessage = "Welcome back! 🎉"
                showAlert = true
            }
            
            // Small delay for better UX
            try? await Task.sleep(nanoseconds: 500_000_000)
            
        } catch {
            await MainActor.run {
                isSuccess = false
                
                if let nsError = error as NSError?,
                   let serverMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
                    loginError = serverMessage
                    alertMessage = serverMessage
                } else {
                    loginError = error.localizedDescription
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
        LoginView()
            .environmentObject(AuthService.shared)
    }
}
