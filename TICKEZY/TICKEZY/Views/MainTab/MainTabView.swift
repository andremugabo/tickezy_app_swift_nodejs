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
                    Label(
                        user.role == .ADMIN ? "Dashboard" : "Home",
                        systemImage: user.role == .ADMIN ? "chart.bar.fill" : "house.fill"
                    )
                }
                .tag(0)
            }

            // MARK: - Events Tab
            EventView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
                .tag(1)

            // MARK: - Tickets Tab
            TicketView()
                .tabItem {
                    Label("Tickets", systemImage: "ticket.fill")
                }
                .tag(2)

            // MARK: - Admin Management Tab (only visible for ADMIN)
            if let user = auth.currentUser, user.role == .ADMIN {
                NavigationStack {
                    
                    ZStack {
                        Color.backgroundPrimary.ignoresSafeArea()
                        ScrollView {
                            VStack(spacing: 20) {
                                
                                // Manage Events
                                NavigationLink {
                                    EventManagement()
                                } label: {
                                    ActionCard(
                                        title: "Manage Events",
                                        subtitle: "Create and manage events",
                                        icon: "calendar.badge.plus",
                                        color: .brandPrimary
                                    )
                                }
                                
                                // Manage Users
                                NavigationLink {
                                    AdminUsersView()
                                } label: {
                                    ActionCard(
                                        title: "Manage Users",
                                        subtitle: "View and control user accounts",
                                        icon: "person.3.fill",
                                        color: .brandSecondary
                                    )
                                }
                            }
                            .padding()
                        }
                        .navigationTitle("Admin Tools")
                    }
                }
                .tabItem {
                    Label("Admin", systemImage: "gearshape.fill")
                }
                .tag(3)
            }

            // MARK: - Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(auth.currentUser?.role == .ADMIN ? 4 : 3)
        }
        .tint(.brandPrimary)
        .preferredColorScheme(.dark)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    // MARK: - Helper: Configure Tab Bar Appearance
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Background color
        appearance.backgroundColor = UIColor(Color.backgroundSecondary)
        
        // Shadow
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.3)
        appearance.shadowImage = UIImage()
        
        // Selected item appearance
        let selectedColor = UIColor(Color.brandPrimary)
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        
        // Normal item appearance
        let normalColor = UIColor(Color.textSecondary)
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Remove top border line
        UITabBar.appearance().clipsToBounds = true
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environmentObject(AuthService.shared)
}
