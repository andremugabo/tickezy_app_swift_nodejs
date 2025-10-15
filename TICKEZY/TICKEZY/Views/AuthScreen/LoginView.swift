//
//  LoginView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String?
    @State private var navigateNext = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack {
                    Spacer(minLength: 40)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 25) {
                            // MARK: - Header
                            VStack(spacing: 8) {
                                Text("Welcome Back")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primaryText)
                                
                                Image("logo1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90)
                                    .padding(.top, 5)
                                
                                Text("Login to your account")
                                    .foregroundColor(.secondaryText)
                                    .font(.subheadline)
                            }
                            .padding(.bottom, 10)
                            
                            // MARK: - Input Fields
                            VStack(spacing: 16) {
                                CustomInputField(icon: "envelope", placeholder: "Email", text: $email)
                                CustomInputField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                                
                                if let error = loginError {
                                    Text(error)
                                        .foregroundColor(.errorRed)
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                }
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Login Button
                            Button {
                                Task { await loginUser() }
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(0.9)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.headline)
                                    }
                                    Text(isLoading ? "Signing In..." : "Login")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isLoading ? Color.gray : Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.2), radius: 5)
                            }
                            .disabled(email.isEmpty || password.isEmpty || isLoading)
                            .padding(.horizontal)
                            .padding(.top, 5)
                            
                            // MARK: - Signup Redirect
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.secondaryText)
                                NavigationLink(destination: SignupView()) {
                                    Text("Sign up")
                                        .foregroundColor(.accentColor)
                                        .bold()
                                }
                            }
                            .font(.footnote)
                            .padding(.top, 15)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    
                    Spacer(minLength: 20)
                }
            }
            // MARK: - Success/Error Alert
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isSuccess ? "Success 🎉" : "Error ❌")
                        .foregroundColor(isSuccess ? .successGreen : .stateError),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"), action: {
                        if isSuccess { navigateNext = true }
                    })
                )
            }
            .navigationDestination(isPresented: $navigateNext) {
                roleBasedDestination()
            }
        }
    }
    
    // MARK: - Async login
    private func loginUser() async {
        loginError = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await auth.login(email: email, password: password)
            isSuccess = true
            alertMessage = "Login successful! Welcome back 🎉"
            showAlert = true
        } catch {
            isSuccess = false
            if let nsError = error as NSError?,
               let serverMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
                alertMessage = serverMessage
            } else {
                alertMessage = error.localizedDescription
            }
            showAlert = true
        }
    }
    
    // MARK: - Role-based navigation
    @ViewBuilder
    private func roleBasedDestination() -> some View {
        if let role = auth.currentUser?.role {
            switch role {
            case .ADMIN: DashboardView()
            case .CUSTOMER: HomeView()
            }
        } else {
            ProgressView("Loading...")
        }
    }
}
