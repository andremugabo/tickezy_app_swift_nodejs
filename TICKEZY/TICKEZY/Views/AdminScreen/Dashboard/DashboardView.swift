//
//  DashboardView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var auth: AuthService
    @StateObject private var userService = UserService.shared
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else {
                    mainContent
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingProfile.toggle()
                    } label: {
                        profileButton
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                if let profile = userService.currentUserProfile {
                    ProfileDetailSheet(profile: profile)
                }
            }
            .refreshable {
                await loadDashboardData()
            }
            .task {
                await loadDashboardData()
            }
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Welcome Header
                welcomeHeader
                
                // Quick Stats
                if let profile = userService.currentUserProfile {
                    quickStatsSection(profile: profile)
                }
                
                // Admin Actions
                if auth.currentUser?.role == .ADMIN {
                    adminActionsSection
                }
                
                // Recent Activity or Users Preview
                if auth.currentUser?.role == .ADMIN {
                    recentUsersSection
                } else {
                    userActivitySection
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let profile = userService.currentUserProfile {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greetingMessage())
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                        
                        Text(profile.name)
                            .font(.title.bold())
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    // Avatar
                    Circle()
                        .fill(Color.brandGradient)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(profile.name.prefix(1).uppercased())
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 2)
                        )
                }
                
                // Role Badge
                HStack(spacing: 6) {
                    Image(systemName: profile.role == .ADMIN ? "crown.fill" : "person.fill")
                        .font(.caption)
                    Text(profile.role.rawValue.capitalized)
                        .font(.caption.bold())
                }
                .foregroundColor(profile.role == .ADMIN ? .brandAccent : .brandSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    (profile.role == .ADMIN ? Color.brandAccent : Color.brandSecondary)
                        .opacity(0.15)
                )
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Stats Section
    
    private func quickStatsSection(profile: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                if auth.currentUser?.role == .ADMIN {
                    StatCard(
                        title: "Total Users",
                        value: "\(userService.allUsers.count)",
                        icon: "person.2.fill",
                        color: .brandPrimary
                    )
                    
                    StatCard(
                        title: "Admins",
                        value: "\(userService.allUsers.filter { $0.role == .ADMIN }.count)",
                        icon: "crown.fill",
                        color: .brandAccent
                    )
                } else {
                    StatCard(
                        title: "My Events",
                        value: "0",
                        icon: "calendar",
                        color: .brandPrimary
                    )
                    
                    StatCard(
                        title: "My Tickets",
                        value: "0",
                        icon: "ticket.fill",
                        color: .brandAccent
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Admin Actions Section
    
    private var adminActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Admin Actions")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                NavigationLink {
                    AdminUsersView()
                } label: {
                    ActionCard(
                        title: "Manage Users",
                        subtitle: "View and manage all users",
                        icon: "person.3.fill",
                        color: .brandPrimary
                    )
                }
                
                ActionCard(
                    title: "Manage Events",
                    subtitle: "Create and edit events",
                    icon: "calendar.badge.plus",
                    color: .brandSecondary,
                    isComingSoon: true
                )
                
                ActionCard(
                    title: "Reports",
                    subtitle: "View analytics and reports",
                    icon: "chart.bar.fill",
                    color: .brandAccent,
                    isComingSoon: true
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Users Section (Admin)
    
    private var recentUsersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Users")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                NavigationLink {
                    AdminUsersView()
                } label: {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.brandPrimary)
                }
            }
            .padding(.horizontal)
            
            if userService.allUsers.isEmpty {
                Text("No users yet")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(Color.surface)
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(userService.allUsers.prefix(3)) { user in
                        NavigationLink {
                            AdminUsersView()
                        } label: {
                            CompactUserCard(user: user)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - User Activity Section
    
    private var userActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                EmptyActivityCard(
                    icon: "calendar.badge.clock",
                    title: "No Recent Activity",
                    subtitle: "Your recent activity will appear here"
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Profile Button
    
    private var profileButton: some View {
        ZStack {
            Circle()
                .fill(Color.surface)
                .frame(width: 36, height: 36)
            
            if let profile = userService.currentUserProfile {
                Text(profile.name.prefix(1).uppercased())
                    .font(.caption.bold())
                    .foregroundColor(.brandPrimary)
            } else {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.brandPrimary)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.brandPrimary)
                .scaleEffect(1.2)
            Text("Loading dashboard...")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.stateError)
            
            Text("Something went wrong")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                Task {
                    await loadDashboardData()
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
    
    // MARK: - Helper Functions
    
    private func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    // MARK: - Load Dashboard Data
    
    @MainActor
    private func loadDashboardData() async {
        guard let token = auth.token else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        
        do {
            try await userService.fetchProfile(token: token)

            if auth.currentUser?.role == .ADMIN {
                try await userService.fetchAllUsers(token: token)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isComingSoon: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    if isComingSoon {
                        Text("Soon")
                            .font(.caption2.bold())
                            .foregroundColor(.brandAccent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.brandAccent.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            if !isComingSoon {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
        .opacity(isComingSoon ? 0.6 : 1.0)
    }
}

struct CompactUserCard: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.brandPrimary.gradient)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.name.prefix(1).uppercased())
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(user.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                    
                    if user.role == .ADMIN {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.brandAccent)
                    }
                }
                
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct EmptyActivityCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.textTertiary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.surface)
        .cornerRadius(12)
    }
}

struct ProfileDetailSheet: View {
    let profile: User
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar
                    Circle()
                        .fill(Color.brandGradient)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(profile.name.prefix(1).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .padding(.top, 20)
                    
                    // Name and Role
                    VStack(spacing: 8) {
                        Text(profile.name)
                            .font(.title2.bold())
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: profile.role == .ADMIN ? "crown.fill" : "person.fill")
                                .font(.caption)
                            Text(profile.role.rawValue.capitalized)
                                .font(.caption.bold())
                        }
                        .foregroundColor(profile.role == .ADMIN ? .brandAccent : .brandSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            (profile.role == .ADMIN ? Color.brandAccent : Color.brandSecondary)
                                .opacity(0.15)
                        )
                        .cornerRadius(8)
                    }
                    
                    // Details
                    VStack(spacing: 12) {
                        ProfileDetailRow(icon: "envelope.fill", label: "Email", value: profile.email)
                        ProfileDetailRow(icon: "phone.fill", label: "Phone", value: profile.phoneNumber ?? "Not provided")
                    }
                    .padding()
                    .background(Color.surface)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Profile")
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

struct ProfileDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
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
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.surfaceAlt)
        .cornerRadius(8)
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
        .environmentObject(AuthService.shared)
}
