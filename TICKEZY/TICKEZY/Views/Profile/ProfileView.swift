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
    @StateObject private var ticketService = TicketService.shared
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingEditProfile = false
    @State private var showingLogoutConfirmation = false
    @State private var showingSettings = false
    @State private var showingChangePassword = false
    
    // Stats
    @State private var statsEvents: Int = 0
    @State private var statsTickets: Int = 0
    @State private var statsSpent: Double = 0.0

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
                SettingsView()
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordSheet()
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
                value: "\(statsEvents)",
                icon: "calendar"
            )
            
            StatPill(
                title: "Tickets",
                value: "\(statsTickets)",
                icon: "ticket.fill"
            )
            
            StatPill(
                title: "Spent",
                value: "\(Int(statsSpent)) Frw",
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
                    showingChangePassword = true
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
                    showingLogoutConfirmation = true
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
            await ticketService.fetchMyTickets(token: token)
            computeStats()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    // MARK: - Compute Stats
    private func computeStats() {
        let tickets = ticketService.tickets
        statsTickets = tickets.count
        let uniqueEventIds = Set(tickets.map { $0.eventId })
        statsEvents = uniqueEventIds.count
        // Sum spent using related Event price when available
        let total = tickets.reduce(0.0) { acc, t in
            if let price = t.Event?.price { return acc + (Double(t.quantity) * price) }
            return acc
        }
        statsSpent = total
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
                .stroke(Color.brandBorder, lineWidth: 1)
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
    @EnvironmentObject var auth: AuthService
    @StateObject private var userService = UserService.shared
    
    @State private var name: String
    @State private var phoneNumber: String
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    init(profile: User) {
        self.profile = profile
        _name = State(initialValue: profile.name)
        _phoneNumber = State(initialValue: profile.phoneNumber ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Avatar Section
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.brandGradient)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .brandPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Text(name.prefix(1).uppercased())
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Button {
                                    // Placeholder for image picker functionality
                                } label: {
                                    Circle()
                                        .fill(Color.surfaceAlt)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.brandPrimary)
                                        )
                                        .shadow(radius: 4)
                                }
                                .offset(x: 40, y: 40)
                            }
                            
                            Text("Change Profile Picture")
                                .font(.caption.bold())
                                .foregroundColor(.brandPrimary)
                        }
                        .padding(.top, 24)
                        
                        // Form Fields
                        VStack(spacing: 24) {
                            CustomEditField(
                                label: "Full Name",
                                icon: "person.fill",
                                placeholder: "Enter your name",
                                text: $name
                            )
                            
                            CustomEditField(
                                label: "Phone Number",
                                icon: "phone.fill",
                                placeholder: "Enter phone number",
                                text: $phoneNumber,
                                keyboardType: .phonePad
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email Address")
                                    .font(.caption.bold())
                                    .foregroundColor(.textTertiary)
                                    .padding(.leading, 4)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.textTertiary)
                                        .frame(width: 20)
                                    
                                    Text(profile.email)
                                        .font(.subheadline)
                                        .foregroundColor(.textTertiary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                        .foregroundColor(.textTertiary)
                                }
                                .padding()
                                .background(Color.surface.opacity(0.5))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.stateError)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
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
                    Button {
                        Task { await saveChanges() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(.brandPrimary)
                        } else {
                            Text("Save")
                                .fontWeight(.bold)
                                .foregroundColor(.brandPrimary)
                        }
                    }
                    .disabled(isSaving || name.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() async {
        guard let token = auth.token else { return }
        isSaving = true
        errorMessage = nil
        
        do {
            try await userService.updateProfile(name: name, phoneNumber: phoneNumber, token: token)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSaving = false
    }
}

struct CustomEditField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.textSecondary)
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.brandPrimary)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                    .keyboardType(keyboardType)
                    .tint(.brandPrimary)
            }
            .padding()
            .background(Color.surfaceAlt)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandBorder.opacity(0.5), lineWidth: 1)
            )
        }
    }
}



// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(AuthService.shared)
}

// MARK: - Change Password Sheet (placeholder)
struct ChangePasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthService
    @StateObject private var userService = UserService.shared
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showSuccessFeedback = false
    
    var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }
    
    var canSave: Bool {
        !currentPassword.isEmpty && passwordsMatch && newPassword.count >= 6
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header Illustration/Icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.brandGradient)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .brandPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Secure Your Account")
                                    .font(.title3.bold())
                                    .foregroundColor(.textPrimary)
                                
                                Text("Enter your current password and choose a strong new one.")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.top, 24)
                        
                        // Input Fields
                        VStack(spacing: 24) {
                            CustomSecureEditField(
                                label: "Current Password",
                                icon: "key.fill",
                                placeholder: "Enter current password",
                                text: $currentPassword
                            )
                            
                            Divider()
                                .background(Color.divider)
                                .padding(.vertical, 8)
                            
                            CustomSecureEditField(
                                label: "New Password",
                                icon: "lock.fill",
                                placeholder: "At least 6 characters",
                                text: $newPassword
                            )
                            
                            VStack(alignment: .leading, spacing: 12) {
                                CustomSecureEditField(
                                    label: "Confirm New Password",
                                    icon: "checkmark.shield.fill",
                                    placeholder: "Re-type new password",
                                    text: $confirmPassword
                                )
                                
                                if !confirmPassword.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        Text(passwordsMatch ? "Passwords match" : "Passwords do not match")
                                    }
                                    .font(.caption)
                                    .foregroundColor(passwordsMatch ? .stateSuccess : .stateError)
                                    .padding(.leading, 4)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.stateError)
                                .padding(.horizontal)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                if showSuccessFeedback {
                    successOverlay
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.textSecondary)
                        .disabled(isSaving)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await performChange() }
                    } label: {
                        if isSaving {
                            ProgressView().tint(.brandPrimary)
                        } else {
                            Text("Update")
                                .fontWeight(.bold)
                                .foregroundColor(canSave ? .brandPrimary : .textTertiary)
                        }
                    }
                    .disabled(!canSave || isSaving)
                }
            }
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.backgroundPrimary.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.stateSuccess)
                
                Text("Success!")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                
                Text("Your password has been updated.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            .padding(40)
            .background(Color.surface)
            .cornerRadius(24)
            .shadow(radius: 20)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private func performChange() async {
        guard let token = auth.token else { return }
        isSaving = true
        errorMessage = nil
        
        do {
            try await userService.changePassword(current: currentPassword, new: newPassword, token: token)
            withAnimation { showSuccessFeedback = true }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSaving = false
    }
}

struct CustomSecureEditField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.textSecondary)
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.brandPrimary)
                    .frame(width: 20)
                
                SecureField(placeholder, text: $text)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                    .tint(.brandPrimary)
            }
            .padding()
            .background(Color.surfaceAlt)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandBorder.opacity(0.5), lineWidth: 1)
            )
        }
    }
}
