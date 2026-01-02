//
//  SettingsView.swift
//  TICKEZY
//
//  Created by Antigravity on 12/27/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthService
    @StateObject private var userService = UserService.shared
    
    // Notification States
    @State private var notificationsEnabled = true
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    
    // Privacy States
    @State private var profilePublic = true
    @State private var sharingEnabled = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header Preview
                        if let profile = userService.currentUserProfile {
                            settingsProfileHeader(profile: profile)
                        }
                        
                        // General Settings
                        SettingsGroup(title: "General") {
                            NavigationLink {
                                LanguageSettingsView()
                            } label: {
                                SettingsRow(
                                    icon: "globe",
                                    iconColor: .brandPrimary,
                                    title: "Language",
                                    subtitle: "English (US)"
                                )
                            }
                            
                            SettingsToggleRow(
                                icon: "bell.fill",
                                iconColor: .brandAccent,
                                title: "Enable Notifications",
                                isOn: $notificationsEnabled
                            )
                            
                            if notificationsEnabled {
                                SettingsToggleRow(
                                    icon: "envelope.fill",
                                    iconColor: .brandSecondary,
                                    title: "Email Notifications",
                                    isOn: $emailNotifications
                                )
                                .padding(.leading, 12)
                                
                                SettingsToggleRow(
                                    icon: "iphone",
                                    iconColor: .brandPrimary,
                                    title: "Push Notifications",
                                    isOn: $pushNotifications
                                )
                                .padding(.leading, 12)
                            }
                        }
                        
                        // Security & Privacy
                        SettingsGroup(title: "Security & Privacy") {
                            NavigationLink {
                                ChangePasswordSheet()
                            } label: {
                                SettingsRow(
                                    icon: "lock.fill",
                                    iconColor: .brandAccent,
                                    title: "Change Password",
                                    subtitle: "Update your security"
                                )
                            }
                            
                            SettingsToggleRow(
                                icon: "eye.fill",
                                iconColor: .stateSuccess,
                                title: "Public Profile",
                                isOn: $profilePublic
                            )
                            
                            NavigationLink {
                                PrivacyPolicyView()
                            } label: {
                                SettingsRow(
                                    icon: "hand.raised.fill",
                                    iconColor: .brandSecondary,
                                    title: "Privacy Policy"
                                )
                            }
                        }
                        
                        // App Info
                        SettingsGroup(title: "Support & About") {
                            SettingsRow(
                                icon: "questionmark.circle.fill",
                                iconColor: .stateInfo,
                                title: "Help Center"
                            )
                            
                            SettingsRow(
                                icon: "star.fill",
                                iconColor: .brandAccent,
                                title: "Rate Tickezy"
                            )
                            
                            HStack {
                                Label {
                                    Text("Version")
                                        .foregroundColor(.textPrimary)
                                } icon: {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.textTertiary)
                                }
                                Spacer()
                                Text("1.2.0")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Sign Out
                        Button {
                            auth.logout()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.stateError)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.stateError.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.brandPrimary)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func settingsProfileHeader(profile: User) -> some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.brandGradient)
                .frame(width: 60, height: 60)
                .overlay(
                    Text(profile.name.prefix(1).uppercased())
                        .font(.title3.bold())
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                Text(profile.email)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
        .padding(.horizontal)
        .onTapGesture {
            dismiss() // Return to profile to edit properly
        }
    }
}

// MARK: - Custom Components

struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption2.bold())
                .foregroundColor(.textTertiary)
                .padding(.leading, 24)
            
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal)
            .background(Color.surface)
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.textPrimary)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2.bold())
                .foregroundColor(.textTertiary)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.brandPrimary)
                .onChange(of: isOn) { _, _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService.shared)
        .background(Color.backgroundPrimary)
}
