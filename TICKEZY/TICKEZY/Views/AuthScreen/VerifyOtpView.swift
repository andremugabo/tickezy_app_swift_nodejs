//
//  VerifyOtpView.swift
//  TICKEZY
//
//  Created by M.A on 11/15/25.
//

import SwiftUI

struct VerifyOtpView: View {
    let email: String
    @Environment(\.dismiss) var dismiss
    @State private var otp: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var goToReset = false
    @State private var secondsLeft = 60
    @State private var canResend = false
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 24)

                    // Header
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
                        }
                        Spacer()
                    }

                    // Title
                    VStack(spacing: 8) {
                        Text("Verify Your Email")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.textPrimary)

                        Text("We sent a 6-digit code to")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)

                        Text(email)
                            .font(.callout.weight(.semibold))
                            .foregroundColor(.brandPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.brandPrimary.opacity(0.08))
                            .cornerRadius(8)
                    }
                    .multilineTextAlignment(.center)

                    otpInput
                    verifyButton
                    resendSection

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToReset) {
            ResetPasswordView(email: email)
        }
        .onAppear {
            focused = true
            startTimer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private var otpInput: some View {
        VStack(spacing: 12) {
            Text("Enter Code")
                .font(.caption.weight(.semibold))
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                TextField("", text: $otp)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .foregroundColor(.clear)
                    .accentColor(.clear)
                    .disableAutocorrection(true)
                    .focused($focused)
                    .onChange(of: otp) { _, newValue in
                        otp = String(newValue.prefix(6)).filter { $0.isNumber }
                        if otp.count == 6 { focused = false }
                    }

                HStack(spacing: 10) {
                    ForEach(0..<6, id: \.self) { idx in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.surface)

                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    idx < otp.count ? Color.brandPrimary : Color.brandBorder,
                                    lineWidth: idx < otp.count ? 2 : 1
                                )

                            Text(character(at: idx))
                                .font(.title2.bold())
                                .foregroundColor(.textPrimary)
                        }
                        .frame(height: 56)
                    }
                }
                .onTapGesture { focused = true }
            }
        }
    }

    private var verifyButton: some View {
        Button {
            Task { await verify() }
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "checkmark.seal.fill").font(.headline)
                }
                Text(isLoading ? "Verifying..." : "Verify Code")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                Group {
                    if isValidOtp && !isLoading {
                        LinearGradient(colors: [Color.brandPrimary, Color.brandSecondary], startPoint: .leading, endPoint: .trailing)
                    } else {
                        LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .cornerRadius(14)
            .shadow(color: isValidOtp && !isLoading ? Color.brandPrimary.opacity(0.25) : .clear, radius: 10, x: 0, y: 6)
        }
        .disabled(!isValidOtp || isLoading)
    }

    private var resendSection: some View {
        VStack(spacing: 8) {
            if !canResend {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill").font(.caption)
                    Text("Resend code in \(secondsLeft)s").font(.callout)
                }
                .foregroundColor(.textTertiary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.surface)
                .cornerRadius(16)
            }

            Button {
                Task { await resend() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise.circle.fill").font(.headline)
                    Text("Resend Code").font(.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Color.surface)
                .foregroundColor(canResend ? .brandPrimary : .textTertiary)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(canResend ? Color.brandPrimary : Color.brandBorder, lineWidth: canResend ? 2 : 1))
            }
            .disabled(!canResend)
        }
    }

    private var isValidOtp: Bool { otp.count == 6 }

    private func character(at index: Int) -> String {
        if index < otp.count {
            return String(otp[otp.index(otp.startIndex, offsetBy: index)])
        }
        return ""
    }

    private func verify() async {
        guard isValidOtp else { return }
        await MainActor.run { isLoading = true }
        do {
            try await AuthService.shared.verifyPasswordOtp(email: email, otp: otp)
            await MainActor.run { isLoading = false; goToReset = true }
        } catch {
            await MainActor.run {
                isLoading = false
                alertTitle = "Verification Failed"
                alertMessage = error.localizedDescription
                showAlert = true
                otp = ""
            }
        }
    }

    private func resend() async {
        guard canResend else { return }
        await MainActor.run { canResend = false; secondsLeft = 60 }
        do { try await AuthService.shared.sendPasswordOtp(email: email) } catch { }
        startTimer()
    }

    private func startTimer() {
        canResend = false
        secondsLeft = 60
        Task { @MainActor in
            while secondsLeft > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                secondsLeft -= 1
            }
            canResend = true
        }
    }
}