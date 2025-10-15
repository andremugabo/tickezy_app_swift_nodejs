//
//  ProfileView.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthService
    @StateObject private var userService = UserService.shared
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingEditProfile = false
    @State private var showingLogoutConfirmation = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if let profile = userService.currentUserProfile {
                    mainContent(profile: profile)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditProfile = true
                        } label: {
                            Label("Edit Profile", systemImage: "pencil")
                        }
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingLogoutConfirmation = true
                        } label: {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.brandPrimary)
                    }
                }
            }
            .refreshable {
                await loadProfile()
            }
            .confirmationDialog("Logout", isPresented: $showingLogoutConfirmation) {
                Button("Logout", role: .destructive) {
                    auth.logout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to logout?")
            }
            .sheet(isPresented: $showingEditProfile) {
                if let profile = userService.currentUserProfile {
                    EditProfileSheet(profile: profile)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet()
            }
            .task {
                await loadProfile()
            }
        }
    }
    
    // MARK: - Main Content
    
    private func mainContent(profile: User) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeader(profile: profile)
                
                // Profile Stats
                profileStats(profile: profile)
                
                // Profile Information
                profileInformation(profile: profile)
                
                // Account Information
                accountInformation(profile: profile)
                
                // Actions Section
                actionsSection
                
                // Danger Zone
                dangerZone
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Profile Header
    
    private func profileHeader(profile: User) -> some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.brandGradient)
                    .frame(width: 120, height: 120)
                
                Text(profile.name.prefix(1).uppercased())
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                
                // Edit Badge
                Circle()
                    .fill(Color.surface)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.caption)
                            .foregroundColor(.brandPrimary)
                    )
                    .offset(x: 40, y: 40)
            }
            .padding(.top, 20)
            
            // Name and Role
            VStack(spacing: 8) {
                Text(profile.name)
                    .font(.title.bold())
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 6) {
                    Image(systemName: profile.role == .ADMIN ? "crown.fill" : "person.fill")
                        .font(.caption)
                    Text(profile.role.rawValue.capitalized)
                        .font(.subheadline.bold())
                }
                .foregroundColor(profile.role == .ADMIN ? .brandAccent : .brandSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    (profile.role == .ADMIN ? Color.brandAccent : Color.brandSecondary)
                        .opacity(0.15)
                )
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Profile Stats
    
    private func profileStats(profile: User) -> some View {
        HStack(spacing: 12) {
            StatPill(
                title: "Events",
                value: "0",
                icon: "calendar"
            )
            
            StatPill(
                title: "Tickets",
                value: "0",
                icon: "ticket.fill"
            )
            
            StatPill(
                title: "Spent",
                value: "$0",
                icon: "creditcard.fill"
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Profile Information
    
    private func profileInformation(profile: User) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Personal Information")
            
            VStack(spacing: 12) {
                InfoRow(
                    icon: "envelope.fill",
                    label: "Email",
                    value: profile.email,
                    valueColor: .textPrimary
                )
                
                InfoRow(
                    icon: "phone.fill",
                    label: "Phone",
                    value: profile.phoneNumber ?? "Not provided",
                    valueColor: profile.phoneNumber == nil ? .textTertiary : .textPrimary
                )
            }
            .padding()
            .background(Color.surface)
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Account Information
    
    private func accountInformation(profile: User) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Account Details")
            
            VStack(spacing: 12) {
                if let createdAt = profile.createdAt {
                    InfoRow(
                        icon: "calendar.badge.plus",
                        label: "Member Since",
                        value: createdAt.formatted(date: .long, time: .omitted),
                        valueColor: .textPrimary
                    )
                }
                
                if let updatedAt = profile.updatedAt {
                    InfoRow(
                        icon: "clock.fill",
                        label: "Last Updated",
                        value: formatRelativeDate(updatedAt),
                        valueColor: .textSecondary
                    )
                }
                
                InfoRow(
                    icon: "key.fill",
                    label: "Account Type",
                    value: profile.role == .ADMIN ? "Administrator" : "Standard User",
                    valueColor: .textPrimary
                )
            }
            .padding()
            .background(Color.surface)
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Actions")
            
            VStack(spacing: 12) {
                ActionButton(
                    icon: "pencil",
                    title: "Edit Profile",
                    subtitle: "Update your information",
                    color: .brandPrimary
                ) {
                    showingEditProfile = true
                }
                
                ActionButton(
                    icon: "lock.fill",
                    title: "Change Password",
                    subtitle: "Update your password",
                    color: .brandSecondary
                ) {
                    // Handle change password
                }
                
                ActionButton(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Manage notification preferences",
                    color: .stateInfo
                ) {
                    showingSettings = true
                }
            }
            .padding()
            .background(Color.surface)
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Danger Zone
    
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Danger Zone", color: .stateError)
            
            VStack(spacing: 12) {
                ActionButton(
                    icon: "trash.fill",
                    title: "Delete Account",
                    subtitle: "Permanently delete your account",
                    color: .stateError
                ) {
                    // Handle delete account
                }
            }
            .padding()
            .background(Color.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.stateError.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.brandPrimary)
                .scaleEffect(1.2)
            Text("Loading profile...")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.stateError)
            
            Text("Failed to Load Profile")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                Task {
                    await loadProfile()
                }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.buttonPrimaryText)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(Color.brandPrimary)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text("No Profile Data")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text("Unable to load your profile information")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button {
                Task {
                    await loadProfile()
                }
            } label: {
                Label("Reload", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.buttonPrimaryText)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(Color.brandPrimary)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Helper Functions
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Load Profile
    
    @MainActor
    private func loadProfile() async {
        guard let token = auth.token else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        
        do {
            try await userService.fetchProfile(token: token)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    var color: Color = .textPrimary
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(color)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .textPrimary
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.brandPrimary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(valueColor)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.surfaceAlt)
        .cornerRadius(12)
    }
}

struct StatPill: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brandPrimary)
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(Color.surfaceAlt)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EditProfileSheet: View {
    let profile: User
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var phoneNumber: String
    
    init(profile: User) {
        self.profile = profile
        _name = State(initialValue: profile.name)
        _phoneNumber = State(initialValue: profile.phoneNumber ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Email") {
                    Text(profile.email)
                        .foregroundColor(.textSecondary)
                }
                .listRowBackground(Color.surface.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundPrimary)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // Handle save
                        dismiss()
                    }
                    .foregroundColor(.brandPrimary)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Email Notifications", isOn: $emailNotifications)
                        .disabled(!notificationsEnabled)
                    Toggle("Push Notifications", isOn: $pushNotifications)
                        .disabled(!notificationsEnabled)
                }
                
                Section("Preferences") {
                    NavigationLink("Language") {
                        Text("Language settings coming soon")
                    }
                    NavigationLink("Privacy") {
                        Text("Privacy settings coming soon")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.backgroundPrimary)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(AuthService.shared)
}
