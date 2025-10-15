//
//  MainTabView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//


import SwiftUI
import Foundation

struct MainTabView: View {
    @EnvironmentObject var auth: AuthService
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
//                .badge(upcomingTicketsCount()) // Badge with live count
                .tag(2)

            // MARK: - Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
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

    // MARK: - Helper: Count upcoming valid tickets
//    private func upcomingTicketsCount() -> Int {
//        guard let tickets = auth.tickets else { return 0 }
//        return tickets.filter {
//            $0.status == TicketStatus.VALID && $0.purchaseDate >= Date()
//        }.count
//    }
}
