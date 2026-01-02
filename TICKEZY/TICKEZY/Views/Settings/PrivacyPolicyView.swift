//
//  PrivacyPolicyView.swift
//  TICKEZY
//
//  Created by Antigravity on 12/27/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero Section
                heroSection
                
                VStack(spacing: 24) {
                    // Last Updated Badge
                    lastUpdatedBadge
                    
                    // Policy Content
                    VStack(alignment: .leading, spacing: 28) {
                        PrivacySection(
                            icon: "doc.text.fill",
                            title: "Introduction",
                            content: "At Tickezy, we take your privacy seriously. This policy explains how we collect, use, and protect your personal information when you use our ticket booking application."
                        )
                        
                        PrivacySection(
                            icon: "person.crop.square.fill",
                            title: "Data We Collect",
                            content: "We collect information essential for your experience, including your name, email address, phone number, and purchase history. Payment details are handled securely by our payment partners."
                        )
                        
                        PrivacySection(
                            icon: "hand.raised.fill",
                            title: "How We Use Data",
                            content: "Your data is used to process bookings, provide customer support, and send relevant event notifications. We never sell your personal information to third parties."
                        )
                        
                        PrivacySection(
                            icon: "shield.lefthalf.filled",
                            title: "Data Security",
                            content: "We implement industry-standard security measures, including encryption and secure server protocols, to protect your data from unauthorized access or disclosure."
                        )
                        
                        PrivacySection(
                            icon: "checkerboard.shield",
                            title: "Your Rights",
                            content: "You have the right to access, update, or delete your personal information at any time. You can manage these settings directly in the profile section of the app."
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }
    
    private var heroSection: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color.brandPrimary, Color.brandSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 220)
            
            // Decorative Circles
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 200, height: 200)
                .offset(x: 150, y: -50)
            
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 150, height: 150)
                .offset(x: -120, y: 80)
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                Text("Privacy Policy")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
        }
    }
    
    private var lastUpdatedBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.fill")
                .font(.caption2)
            Text("Last Updated: December 27, 2025")
                .font(.caption.bold())
        }
        .foregroundColor(.brandPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.brandPrimary.opacity(0.1))
        .cornerRadius(20)
    }
}

struct PrivacySection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 16, weight: .bold))
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
