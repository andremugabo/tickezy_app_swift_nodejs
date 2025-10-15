//
//  MainTabView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var auth: AuthService
    @StateObject private var userService = UserService.shared
    @State private var selectedTab = 0
    @State private var isLoadingUsers = false
    @State private var userErrorMessage: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - Home / Dashboard Tab
            if let user = auth.currentUser {
                Group {
                    if user.role == .ADMIN {
                        DashboardView()
                    } else {
                        HomeView()
                    }
                }
                .tabItem {
                    Image(systemName: "house")
                    Text(user.role == .ADMIN ? "Dashboard" : "Home")
                }
                .tag(0)
            }

            // MARK: - Events Tab
            EventView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
                .tag(1)

            // MARK: - Tickets Tab
            TicketView()
                .tabItem {
                    Image(systemName: "ticket")
                    Text("Tickets")
                }
                .tag(2)

            // MARK: - Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
            
            // MARK: - Admin Users Tab (only visible for ADMIN)
            if let user = auth.currentUser, user.role == .ADMIN {
                NavigationStack {
                    VStack {
                        if isLoadingUsers {
                            ProgressView("Loading users...")
                        } else if let errorMessage = userErrorMessage {
                            Text(errorMessage)
                                .foregroundColor(.stateError)
                                .padding()
                        } else {
                            List(userService.allUsers) { u in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(u.name)
                                        .font(.headline)
                                    Text(u.email)
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    Text("Role: \(u.role.rawValue)")
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    if let phone = u.phoneNumber {
                                        Text("Phone: \(phone)")
                                            .font(.subheadline)
                                            .foregroundColor(.textSecondary)
                                    }
                                    if let created = u.createdAt {
                                        Text("Created: \(created.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                            .foregroundColor(.textTertiary)
                                    }
                                    if let updated = u.updatedAt {
                                        Text("Updated: \(updated.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption)
                                            .foregroundColor(.textTertiary)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .navigationTitle("All Users")
                    .task {
                        await loadAllUsers()
                    }
                }
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Users")
                }
                .tag(4)
            }
        }
        .accentColor(.blue)
        .preferredColorScheme(.dark)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    // MARK: - Helper: Configure Tab Bar Appearance
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        let backgroundColor = UIColor(Color.appBackground.opacity(0.9))
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = UIColor.gray.withAlphaComponent(0.3)

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    // MARK: - Load All Users (Admin)
    @MainActor
    private func loadAllUsers() async {
        guard let token = auth.token else { return }
        isLoadingUsers = true
        userErrorMessage = nil
        do {
            try await userService.fetchAllUsers(token: token)
        } catch {
            userErrorMessage = error.localizedDescription
        }
        isLoadingUsers = false
    }
}
