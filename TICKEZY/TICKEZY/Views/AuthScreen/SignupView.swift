//
//  SignupView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var auth: AuthService
    
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
                                Text("Create Account")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primaryText)
                                
                                Image("logo1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90)
                                    .padding(.top, 5)
                                
                                Text("Event • Tickets • Moments")
                                    .foregroundColor(.secondaryText)
                                    .font(.subheadline)
                            }
                            .padding(.bottom, 10)
                            
                            // MARK: - Input Fields
                            VStack(spacing: 16) {
                                CustomInputField(icon: "person", placeholder: "Full Name", text: $name)
                                CustomInputField(icon: "envelope", placeholder: "Email", text: $email)
                                CustomInputField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                                CustomInputField(icon: "phone", placeholder: "Phone Number", text: $phoneNumber)
                                
                                if let error = signupError {
                                    Text(error)
                                        .foregroundColor(.errorRed)
                                        .font(.footnote)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                }
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Signup Button
                            Button {
                                Task { await signupUser() }
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(0.9)
                                    } else {
                                        Image(systemName: "person.badge.plus")
                                            .font(.headline)
                                    }
                                    Text(isLoading ? "Creating Account..." : "Create Account")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isLoading ? Color.gray : Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.2), radius: 5)
                            }
                            .disabled(name.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty || isLoading)
                            .padding(.horizontal)
                            .padding(.top, 5)
                            
                            // MARK: - Already have an account
                            HStack {
                                Text("Already have an account?")
                                    .foregroundColor(.secondaryText)
                                NavigationLink(destination: LoginView()) {
                                    Text("Login")
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
    
    // MARK: - Async signup
    private func signupUser() async {
        signupError = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await auth.register(name: name, email: email, password: password, phoneNumber: phoneNumber)
            isSuccess = true
            alertMessage = "Signup successful! Welcome 🎉"
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
