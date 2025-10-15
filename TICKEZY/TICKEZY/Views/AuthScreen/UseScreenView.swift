//
//  UseScreenView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct UseScreenView: View {
    @StateObject private var authService = AuthService.shared
    @State private var navigateToLogin = false
    @State private var navigateToSignup = false
    @State private var navigateToHome = false
    
    // Animation states
    @State private var showLogo = false
    @State private var showTagline = false
    @State private var showButtons = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("concert")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Dark overlay
                Color.black.opacity(0.55)
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    Spacer()

                    // MARK: - Logo
                    if showLogo {
                        Image("logo1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .shadow(radius: 8)
                            .transition(.scale.combined(with: .opacity))
                    }

                    // MARK: - Tagline
                    if showTagline {
                        Text("Event • Ticket • Moment")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .transition(.opacity)
                    }

                    Spacer()

                    // MARK: - Buttons
                    if showButtons {
                        VStack(spacing: 22) {
                            VStack(spacing: 8) {
                                Text("Already have an account?")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .transition(.opacity)

                                ButtonPrimary(title: "Login") {
                                    navigateToLogin = true
                                }
                                .frame(width: 280)
                            }

                            VStack(spacing: 8) {
                                Text("New here?")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .transition(.opacity)

                                ButtonPrimary(title: "Sign Up") {
                                    navigateToSignup = true
                                }
                                .frame(width: 280)
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer()
                }
                .padding()
            }

            // MARK: - Navigation Destinations
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $navigateToSignup) {
                SignupView()
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }

            // MARK: - Appear animations
            .onAppear {
                if authService.token != nil && authService.currentUser != nil {
                    navigateToHome = true
                } else {
                    animateIntro()
                }
            }
        }
    }

    // MARK: - Animation Sequence
    private func animateIntro() {
        withAnimation(.easeOut(duration: 0.8)) {
            showLogo = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.8)) {
                showTagline = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 1.0)) {
                showButtons = true
            }
        }
    }
}

#Preview {
    UseScreenView()
}
