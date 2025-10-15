//
//  AdminUsersView.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI

struct AdminUsersView: View {
    @StateObject private var userService = UserService.shared
    @EnvironmentObject var auth: AuthService
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedRole: UserRole? = nil
    @State private var showingFilters = false
    
    var filteredUsers: [User] {
        var users = userService.allUsers
        
        // Filter by role
        if let role = selectedRole {
            users = users.filter { $0.role == role }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            users = users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return users
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stats Header
                    if !isLoading && errorMessage == nil {
                        statsHeader
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                    }
                    
                    // Main Content
                    Group {
                        if isLoading {
                            loadingView
                        } else if let errorMessage = errorMessage {
                            errorView(message: errorMessage)
                        } else if filteredUsers.isEmpty {
                            emptyStateView
                        } else {
                            usersList
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: selectedRole == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                            .foregroundColor(.brandPrimary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await loadUsers()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.brandPrimary)
                    }
                    .disabled(isLoading)
                }
            }
            .searchable(text: $searchText, prompt: "Search users...")
            .sheet(isPresented: $showingFilters) {
                filterSheet
            }
        }
        .task {
            await loadUsers()
        }
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total",
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
            
            StatCard(
                title: "Users",
                value: "\(userService.allUsers.filter { $0.role == .CUSTOMER }.count)",
                icon: "person.fill",
                color: .brandSecondary
            )
        }
    }
    
    // MARK: - Users List
    
    private var usersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredUsers) { user in
                    UserCard(user: user)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.brandPrimary)
                .scaleEffect(1.2)
            Text("Loading users...")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.stateError)
            
            Text("Error")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                Task {
                    await loadUsers()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text("No Users Found")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text(searchText.isEmpty ? "No users available" : "Try adjusting your search")
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            if !searchText.isEmpty || selectedRole != nil {
                Button {
                    searchText = ""
                    selectedRole = nil
                } label: {
                    Text("Clear Filters")
                        .font(.headline)
                        .foregroundColor(.brandPrimary)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    // MARK: - Filter Sheet
    
    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("Filter by Role") {
                    FilterButton(
                        title: "All Roles",
                        isSelected: selectedRole == nil
                    ) {
                        selectedRole = nil
                        showingFilters = false
                    }
                    
                    FilterButton(
                        title: "Admin",
                        icon: "crown.fill",
                        isSelected: selectedRole == .ADMIN
                    ) {
                        selectedRole = .ADMIN
                        showingFilters = false
                    }
                    
                    FilterButton(
                        title: "User",
                        icon: "person.fill",
                        isSelected: selectedRole == .CUSTOMER
                    ) {
                        selectedRole = .CUSTOMER
                        showingFilters = false
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showingFilters = false
                    }
                    .foregroundColor(.brandPrimary)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Data Loading
    
    @MainActor
    private func loadUsers() async {
        guard let token = auth.token else {
            errorMessage = "Unauthorized. Please log in again."
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        
        do {
            try await userService.fetchAllUsers(token: token)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.surface)
        .cornerRadius(12)
    }
}

struct UserCard: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.brandPrimary.gradient)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.name.prefix(1).uppercased())
                        .font(.title3.bold())
                        .foregroundColor(.white)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    if user.role == .ADMIN {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.brandAccent)
                    }
                }
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                // Role Badge
                HStack(spacing: 4) {
                    Image(systemName: user.role == .ADMIN ? "shield.fill" : "person.fill")
                        .font(.caption2)
                    Text(user.role.rawValue.capitalized)
                        .font(.caption.bold())
                }
                .foregroundColor(user.role == .ADMIN ? .brandAccent : .brandSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (user.role == .ADMIN ? Color.brandAccent : Color.brandSecondary)
                        .opacity(0.15)
                )
                .cornerRadius(6)
            }
            
            Spacer()
            
            // Chevron
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

struct FilterButton: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? .brandPrimary : .textSecondary)
                }
                
                Text(title)
                    .foregroundColor(isSelected ? .brandPrimary : .textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AdminUsersView()
        .environmentObject(AuthService.shared)
}
