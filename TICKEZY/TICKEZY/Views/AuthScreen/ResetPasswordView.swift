//
//  ResetPasswordView.swift
//  TICKEZY
//
//  Enhanced with proper navigation handling
//

import SwiftUI
import Combine

struct ResetPasswordView: View {
    let email: String
    @Environment(\.dismiss) var dismiss
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var shouldDismissToRoot = false
    
    @FocusState private var focusedField: Field?

    enum Field { case new, confirm }

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 60)

                    // Header
                    VStack(spacing: 20) {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 40, height: 40)
                                    .background(Color.surface)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                            }
                            Spacer()
                        }
                        
                        // Lock shield icon
                        ZStack {
                            Circle()
                                .fill(Color.brandPrimary.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 45))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.brandPrimary, Color.brandAccent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 12) {
                            Text("Create New Password")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.textPrimary)
                            
                            Text("Your new password must be different from previously used passwords")
                                .font(.callout)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }
                    }

                    // Password inputs
                    VStack(spacing: 16) {
                        passwordField(
                            title: "New Password",
                            text: $newPassword,
                            showPassword: $showNewPassword,
                            field: .new
                        )
                        
                        passwordField(
                            title: "Confirm Password",
                            text: $confirmPassword,
                            showPassword: $showConfirmPassword,
                            field: .confirm
                        )

                        if !newPassword.isEmpty {
                            PasswordStrengthView(password: newPassword)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        if !confirmPassword.isEmpty && !passwordsMatch {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                Text("Passwords do not match")
                                    .font(.caption)
                            }
                            .foregroundColor(.stateWarning)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    confirmButton

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle == "Success" {
                        // Pop Reset -> Verify -> Forgot => back to Login
                        dismiss()
                        DispatchQueue.main.async { dismiss() }
                        DispatchQueue.main.async { dismiss() }
                    }
                }
            )
        }
    }

    private func passwordField(title: String, text: Binding<String>, showPassword: Binding<Bool>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.textSecondary)
                .padding(.leading, 4)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "lock.fill")
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 16))
                }

                Group {
                    if showPassword.wrappedValue {
                        TextField("Enter password", text: text)
                            .textContentType(.newPassword)
                    } else {
                        SecureField("Enter password", text: text)
                            .textContentType(.newPassword)
                    }
                }
                .focused($focusedField, equals: field)
                .foregroundColor(.textPrimary)
                .submitLabel(.done)

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showPassword.wrappedValue.toggle()
                    }
                } label: {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.textTertiary)
                        .font(.system(size: 18))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surface)
                    .shadow(
                        color: focusedField == field ? Color.brandPrimary.opacity(0.2) : .black.opacity(0.05),
                        radius: focusedField == field ? 12 : 8,
                        y: focusedField == field ? 4 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        focusedField == field ?
                        LinearGradient(colors: [Color.brandPrimary, Color.brandAccent], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color.border, Color.border], startPoint: .leading, endPoint: .trailing),
                        lineWidth: focusedField == field ? 2 : 1
                    )
            )
        }
    }

    private var canSubmit: Bool { newPassword.count >= 8 && passwordsMatch && !isLoading }
    private var passwordsMatch: Bool { !newPassword.isEmpty && newPassword == confirmPassword }

    private var confirmButton: some View {
        Button {
            Task { await doReset() }
        } label: {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.1)
                } else {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(isLoading ? "Updating Password..." : "Update Password")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if canSubmit {
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(16)
            .shadow(
                color: canSubmit ? Color.brandPrimary.opacity(0.4) : .clear,
                radius: 16,
                x: 0,
                y: 8
            )
            .scaleEffect(isLoading ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
        }
        .disabled(!canSubmit)
        .padding(.top, 8)
    }

    private func doReset() async {
        guard canSubmit else { return }
        await MainActor.run { isLoading = true }
        
        do {
            try await AuthService.shared.resetPassword(email: email, newPassword: newPassword)
            
            await MainActor.run {
                isLoading = false
                alertTitle = "Success"
                alertMessage = "Your password has been updated."
                showAlert = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                alertTitle = "Update Failed"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    // ✅ SOLUTION 1: Using dismiss multiple times (Simple approach)
    private func dismissToLogin() {
        // Dismiss ResetPasswordView
        dismiss()
        
        // Use delayed dismissals to pop the navigation stack
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss() // Dismiss VerifyOtpView
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            dismiss() // Dismiss ForgotPasswordView
        }
    }
}

#Preview {
    NavigationStack {
        ResetPasswordView(email: "user@example.com")
    }
}