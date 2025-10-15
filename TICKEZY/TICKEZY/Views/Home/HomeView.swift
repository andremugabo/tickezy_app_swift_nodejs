//
//  HomeView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: AuthService
    @StateObject private var userService = UserService.shared
    
    // Placeholder state for other modules
    @State private var upcomingTickets: [Ticket] = []
    @State private var upcomingEvents: [Event] = []
//    @State private var notifications: [NotificationItem] = []
    
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingSection
                    ticketsSection
                    eventsSection
//                    notificationsSection
                    Spacer()
                }
                .padding(.top)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .task {
                await loadHomeData()
            }
        }
    }

    // MARK: - Greeting Section
    private var greetingSection: some View {
        Group {
            if let user = auth.currentUser {
                Text("Welcome, \(user.name)!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - Tickets Section
    private var ticketsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Upcoming Tickets")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)

            if isLoading {
                ProgressView()
                    .foregroundColor(.textPrimary)
                    .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.stateError)
                    .padding()
            } else if upcomingTickets.isEmpty {
                Text("No upcoming tickets.")
                    .foregroundColor(.textSecondary)
                    .padding()
            } else {
                ForEach(upcomingTickets) { ticket in
                    TicketRow(ticket: ticket)
                }
            }
        }
        .padding(.top)
    }

    // MARK: - Events Section
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Events")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)

            if upcomingEvents.isEmpty {
                Text("No upcoming events.")
                    .foregroundColor(.textSecondary)
                    .padding()
            } else {
                ForEach(upcomingEvents) { event in
                    EventRow(event: event)
                }
            }
        }
        .padding(.top)
    }

    // MARK: - Notifications Section
//    private var notificationsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Notifications")
//                .font(.headline)
//                .foregroundColor(.textPrimary)
//                .padding(.horizontal)
//
//            if notifications.isEmpty {
//                Text("No new notifications.")
//                    .foregroundColor(.textSecondary)
//                    .padding()
//            } else {
//                ForEach(notifications) { note in
//                    NotificationRow(notification: note)
//                }
//            }
//        }
//        .padding(.top)
//    }

    // MARK: - Load Home Data
    @MainActor
    private func loadHomeData() async {
        guard let token = auth.token else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }

        isLoading = true
        do {
            // Load user profile
            try await userService.fetchProfile(token: token)
            
            // TODO: Fetch tickets, events, notifications when their services are implemented
            // upcomingTickets = ...
            // upcomingEvents = ...
            // notifications = ...

        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Ticket Row
struct TicketRow: View {
    let ticket: Ticket
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Event ID: \(ticket.eventId)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            Text("Quantity: \(ticket.quantity)")
                .font(.caption)
                .foregroundColor(.textSecondary)
            Text("Purchase Date: \(ticket.purchaseDate.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.surfaceAlt)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Event Row (Placeholder)
struct EventRow: View {
    let event: Event
    var body: some View {
        Text("Event: \(event.title)")
            .padding()
            .background(Color.surfaceAlt)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

// MARK: - Notification Row (Placeholder)
struct NotificationRow: View {
//    let notification: NotificationItem
    var body: some View {
//        Text(notification.message)
//            .padding()
//            .background(Color.surfaceAlt)
//            .cornerRadius(12)
//            .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AuthService.shared)
}
// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AuthService.shared)
}
