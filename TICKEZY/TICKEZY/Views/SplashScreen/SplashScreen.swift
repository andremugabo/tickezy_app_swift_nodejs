//
//  SplashScreen.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity = 0.0
    @State private var glowOpacity = 0.0
    @State private var brandNameOpacity = 0.0
    @State private var brandNameOffset: CGFloat = 20
    @State private var taglineOpacity = 0.0
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            if isActive {
                // Main app content
                ContentView()
                    .transition(.opacity)
            } else {
                // Background with gradient
                LinearGradient(
                    colors: [
                        Color.backgroundPrimary,
                        Color.backgroundSecondary,
                        Color.backgroundPrimary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated background particles
                GeometryReader { geometry in
                    ForEach(0..<20) { i in
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.1))
                            .frame(width: CGFloat.random(in: 10...30))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .blur(radius: 10)
                            .opacity(glowOpacity)
                    }
                }
                .ignoresSafeArea()
                
                // Splash content
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Logo with animated glow
                    ZStack {
                        // Outer glow rings
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(
                                    Color.brandPrimary.opacity(0.3 - Double(i) * 0.1),
                                    lineWidth: 2
                                )
                                .frame(
                                    width: 180 + CGFloat(i) * 30,
                                    height: 180 + CGFloat(i) * 30
                                )
                                .scaleEffect(logoScale)
                                .opacity(glowOpacity)
                        }
                        
                        // Main glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.brandPrimary.opacity(0.4),
                                        Color.brandAccent.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                            .blur(radius: 30)
                            .opacity(glowOpacity)
                        
                        // Logo
                        Image("logo1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(rotationAngle))
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                            .shadow(
                                color: .brandPrimary.opacity(0.5),
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                    }
                    
                    // Brand name with gradient
                    Text("TICKEZY")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.brandAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(brandNameOpacity)
                        .offset(y: brandNameOffset)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    // Tagline
                    Text("Event • Ticket • Moment")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(3)
                        .opacity(taglineOpacity)
                    
                    Spacer()
                    
                    // Loading indicator
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.brandPrimary)
                            .scaleEffect(1.2)
                        
                        Text("Loading your experience...")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .opacity(taglineOpacity)
                    .padding(.bottom, 40)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            animateSplash()
            
            // Navigate to main content after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isActive = true
                }
            }
        }
    }
    
    // MARK: - Animation Sequence
    
    private func animateSplash() {
        // Background particles fade in
        withAnimation(.easeIn(duration: 0.8)) {
            glowOpacity = 0.5
        }
        
        // Logo appears with bounce
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Subtle rotation effect
        withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
            rotationAngle = 360
        }
        
        // Brand name slides up
        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
            brandNameOpacity = 1.0
            brandNameOffset = 0
        }
        
        // Tagline fades in
        withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
            taglineOpacity = 1.0
        }
        
        // Continuous glow pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }
    }
}

// MARK: - Preview
#Preview {
    SplashScreen()
}
