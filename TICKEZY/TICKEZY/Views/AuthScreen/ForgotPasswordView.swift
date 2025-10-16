//
//  ForgotPasswordView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Illustration
                    illustrationSection
                    
                    // MARK: - Description
                    descriptionSection
                    
                    // MARK: - Email Input
                    emailInputSection
                    
                    // MARK: - Submit Button
                    submitButton
                    
                    // MARK: - Back to Login
                    backToLoginSection
                    
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
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isSuccess {
                        dismiss()
                    }
                }
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Forgot Password?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text("No worries, we'll help you reset it")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Illustration Section
    
    private var illustrationSection: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.brandPrimary.opacity(0.3),
                            Color.brandAccent.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .blur(radius: 20)
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.surface)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "lock.rotation")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(spacing: 12) {
            Text("Enter your email address")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text("We'll send you instructions to reset your password and regain access to your account.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)
        }
    }
    
    // MARK: - Email Input Section
    
    private var emailInputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email Address")
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
                    .focused($isEmailFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        Task { await sendResetLink() }
                    }
                
                if !email.isEmpty {
                    Button {
                        email = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .padding(14)
            .background(Color.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isEmailFocused ? Color.brandPrimary : Color.border,
                        lineWidth: isEmailFocused ? 2 : 1
                    )
            )
            
            // Helper text
            if !email.isEmpty && !isValidEmail {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption2)
                    Text("Please enter a valid email address")
                        .font(.caption2)
                }
                .foregroundColor(.stateWarning)
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            isEmailFocused = false
            Task { await sendResetLink() }
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                }
                
                Text(isLoading ? "Sending..." : "Send Reset Link")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                isValidEmail && !isLoading ?
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
                color: isValidEmail && !isLoading ? Color.brandPrimary.opacity(0.4) : Color.clear,
                radius: 12,
                x: 0,
                y: 8
            )
        }
        .disabled(!isValidEmail || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isValidEmail)
        .padding(.top, 8)
    }
    
    // MARK: - Back to Login Section
    
    private var backToLoginSection: some View {
        VStack(spacing: 16) {
            // Divider
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
            
            // Back button
            Button {
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.circle.fill")
                    Text("Back to Login")
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
    
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Send Reset Link Function
    
    private func sendResetLink() async {
        guard isValidEmail else { return }
        
        isLoading = true
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            isLoading = false
            isSuccess = true
            alertTitle = "Check Your Email"
            alertMessage = "We've sent password reset instructions to \(email). Please check your inbox and follow the link to reset your password."
            showAlert = true
        }
        
        // TODO: Implement actual API call
        // try await AuthService.shared.sendPasswordReset(email: email)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
