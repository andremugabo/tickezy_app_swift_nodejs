//
//  ForgotPasswordView.swift
//  TICKEZY
//
//  Enhanced UI/UX Implementation
//

import SwiftUI

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var goToVerify = false
    
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        ZStack {
            // Static background
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Spacer(minLength: 12)
                    
                    headerSection
                    
                    illustrationSection
                    
                    VStack(spacing: 10) {
                        descriptionSection
                        emailInputSection
                        submitButton
                    }
                    
                    backToLoginSection
                    
                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToVerify) {
            VerifyOtpView(email: email)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 10) {
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
            
            VStack(spacing: 8) {
                Text("Forgot Password?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text("Don't worry, it happens to the best of us")
                    .font(.callout)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Illustration Section
    private var illustrationSection: some View {
        ZStack {
            // Animated glow effects
            ForEach(0..<3) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.brandPrimary.opacity(0.3 - Double(i) * 0.1),
                                Color.brandAccent.opacity(0.2 - Double(i) * 0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180 + CGFloat(i * 20), height: 180 + CGFloat(i * 20))
                    .blur(radius: 15 + CGFloat(i * 5))
                    .opacity(isEmailFocused ? 0.6 : 0.4)
            }
            
            // Main icon container
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.brandPrimary.opacity(0.3), Color.brandAccent.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(isEmailFocused ? 360 : 0))
                
                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.surface, Color.surface.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                
                // Icon
                Image(systemName: "lock.rotation")
                    .font(.system(size: 55, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(isEmailFocused ? -10 : 0))
                    .scaleEffect(isEmailFocused ? 1.1 : 1.0)
            }
        }
        .frame(height: 200)
        .padding(.vertical, 20)
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(spacing: 12) {
            Text("Enter your email address")
                .font(.title3.weight(.semibold))
                .foregroundColor(.textPrimary)
            
            Text("We'll send you a verification code to reset your password and regain access to your account.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 8)
        }
    }
    
    // MARK: - Email Input Section
    private var emailInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email Address")
                .font(.caption.bold())
                .foregroundColor(.textSecondary)
                .padding(.leading, 4)
            
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 16))
                }
                
                TextField("your.email@example.com", text: $email)
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
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surface)
                    .shadow(color: isEmailFocused ? Color.brandPrimary.opacity(0.2) : .black.opacity(0.05), radius: isEmailFocused ? 12 : 8, y: isEmailFocused ? 4 : 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isEmailFocused ? 
                        LinearGradient(colors: [Color.brandPrimary, Color.brandAccent], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color.border, Color.border], startPoint: .leading, endPoint: .trailing),
                        lineWidth: isEmailFocused ? 2 : 1
                    )
            )
            
            // Validation feedback
            if !email.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: isValidEmail ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(isValidEmail ? .stateSuccess : .stateWarning)
                    
                    Text(isValidEmail ? "Valid email format" : "Please enter a valid email address")
                        .font(.caption)
                        .foregroundColor(isValidEmail ? .stateSuccess : .stateWarning)
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            isEmailFocused = false
            Task { await sendResetLink() }
        } label: {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.1)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(isLoading ? "Sending code..." : "Send Reset Link")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if isValidEmail && !isLoading {
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
                color: isValidEmail && !isLoading ? Color.brandPrimary.opacity(0.4) : Color.clear,
                radius: 16,
                x: 0,
                y: 8
            )
        }
        .disabled(!isValidEmail || isLoading)
        .padding(.top, 8)
    }
    
    // MARK: - Back to Login Section
    private var backToLoginSection: some View {
        VStack(spacing: 10) {
            // Divider
            HStack(spacing: 16) {
                Rectangle()
                    .fill(Color.divider)
                    .frame(height: 1)
                
                Text("OR")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.textTertiary)
                    .padding(.horizontal, 8)
                
                Rectangle()
                    .fill(Color.divider)
                    .frame(height: 1)
            }
            
            // Back button
            Button {
                dismiss()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: 18))
                    Text("Back to Login")
                        .font(.headline)
                }
                .foregroundColor(.brandPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.surface)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.brandPrimary.opacity(0.5), Color.brandAccent.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
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
        
        await MainActor.run { isLoading = true }
        
        do {
            try await AuthService.shared.sendPasswordOtp(email: email)
            
            await MainActor.run {
                isLoading = false
                goToVerify = true
            }
        } catch {
            await MainActor.run {
                isLoading = false
                alertTitle = "Unable to Send Code"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}










// MARK: - Preview
#Preview {
    NavigationStack {
        ForgotPasswordView()
    }
}
