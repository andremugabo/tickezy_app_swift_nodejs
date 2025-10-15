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
    @State private var showDescription = false
    @State private var showButtons = false
    @State private var imageScale: CGFloat = 1.1
    @State private var overlayOpacity: Double = 0.3

    var body: some View {
        NavigationStack {
            ZStack {
                // Background image with ken burns effect
                Image("concert")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(imageScale)
                    .ignoresSafeArea()

                // Gradient overlay
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .opacity(overlayOpacity)

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)

                    // MARK: - Logo Section
                    VStack(spacing: 24) {
                        if showLogo {
                            ZStack {
                                // Glow effect
                                Circle()
                                    .fill(Color.brandPrimary.opacity(0.3))
                                    .frame(width: 140, height: 140)
                                    .blur(radius: 30)
                                
                                Image("logo1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .brandPrimary.opacity(0.5), radius: 20)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }

                        // MARK: - Tagline
                        if showTagline {
                            VStack(spacing: 12) {
                                Text("TICKEZY")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, Color.brandAccent],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Text("Event • Ticket • Moment")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                    .tracking(2)
                            }
                            .transition(.opacity)
                        }
                        
                        // MARK: - Description
                        if showDescription {
                            Text("Your gateway to unforgettable experiences")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .transition(.opacity)
                        }
                    }

                    Spacer()

                    // MARK: - Buttons Section
                    if showButtons {
                        VStack(spacing: 20) {
                            // Login Button
                            VStack(spacing: 12) {
                                Text("Already have an account?")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Button {
                                    navigateToLogin = true
                                } label: {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .font(.title3)
                                        Text("Login")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.brandPrimary, Color.brandSecondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: .brandPrimary.opacity(0.4), radius: 12, x: 0, y: 8)
                                }
                                .frame(width: 300)
                            }
                            
                            // Divider
                            HStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 1)
                                
                                Text("or")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 12)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 4)
                            
                            // Signup Button
                            VStack(spacing: 12) {
                                Text("New to TICKEZY?")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Button {
                                    navigateToSignup = true
                                } label: {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .font(.title3)
                                        Text("Create Account")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.brandPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
                                }
                                .frame(width: 300)
                            }
                        }
                        .padding(.horizontal, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer()
                        .frame(height: 60)
                }
            }

            // MARK: - Navigation Destinations
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $navigateToSignup) {
                SignupView()
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MainTabView()
            }

            // MARK: - Appear animations
            .onAppear {
                if authService.token != nil && authService.currentUser != nil {
                    navigateToHome = true
                } else {
                    animateIntro()
                    animateBackground()
                }
            }
        }
    }

    // MARK: - Animation Sequences
    
    private func animateIntro() {
        // Logo animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            showLogo = true
        }
        
        // Tagline animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.8)) {
                showTagline = true
            }
        }
        
        // Description animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.8)) {
                showDescription = true
            }
        }
        
        // Buttons animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                showButtons = true
            }
        }
    }
    
    private func animateBackground() {
        // Subtle Ken Burns effect
        withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
            imageScale = 1.0
        }
        
        // Overlay pulse effect
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            overlayOpacity = 0.5
        }
    }
}

// MARK: - Custom Button Style

struct WelcomeButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    UseScreenView()
}
