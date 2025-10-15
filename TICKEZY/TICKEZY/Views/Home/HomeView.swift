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
    @State private var featuredEvents: [Event] = []
    
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingNotifications = false

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
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNotifications = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.brandPrimary)
                            
                            // Notification badge
                            Circle()
                                .fill(Color.stateError)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                                .opacity(0) // Show when there are notifications
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationsSheet()
            }
            .refreshable {
                await loadHomeData()
            }
            .task {
                await loadHomeData()
            }
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Greeting Section
                greetingSection
                
                // Quick Actions
                quickActionsSection
                
                // My Tickets Section
                if !upcomingTickets.isEmpty {
                    myTicketsSection
                }
                
                // Featured Events
                featuredEventsSection
                
                // Upcoming Events
                upcomingEventsSection
                
                // Categories (Coming Soon)
                categoriesSection
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Greeting Section
    
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let user = auth.currentUser {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greetingMessage())
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                        
                        Text(user.name)
                            .font(.title.bold())
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    // Avatar
                    Circle()
                        .fill(Color.brandGradient)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(user.name.prefix(1).uppercased())
                                .font(.title3.bold())
                                .foregroundColor(.white)
                        )
                }
                
                Text("Discover and book amazing events")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                NavigationLink {
                    Text("Browse Events - Coming Soon")
                        .navigationTitle("Browse Events")
                } label: {
                    QuickActionCard(
                        icon: "calendar.badge.plus",
                        title: "Browse Events",
                        color: .brandPrimary
                    )
                }
                
                NavigationLink {
                    Text("My Tickets - Coming Soon")
                        .navigationTitle("My Tickets")
                } label: {
                    QuickActionCard(
                        icon: "ticket.fill",
                        title: "My Tickets",
                        color: .brandSecondary
                    )
                }
                
                NavigationLink {
                    Text("Favorites - Coming Soon")
                        .navigationTitle("Favorites")
                } label: {
                    QuickActionCard(
                        icon: "heart.fill",
                        title: "Favorites",
                        color: .stateError
                    )
                }
                
                NavigationLink {
                    Text("Search - Coming Soon")
                        .navigationTitle("Search")
                } label: {
                    QuickActionCard(
                        icon: "magnifyingglass",
                        title: "Search",
                        color: .brandAccent
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - My Tickets Section
    
    private var myTicketsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Tickets")
                    .font(.title3.bold())
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                NavigationLink {
                    Text("All Tickets - Coming Soon")
                        .navigationTitle("My Tickets")
                } label: {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.brandPrimary)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(upcomingTickets.prefix(5)) { ticket in
                        TicketCard(ticket: ticket)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Featured Events Section
    
    private var featuredEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Events")
                .font(.title3.bold())
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            if featuredEvents.isEmpty {
                FeaturedEventPlaceholder()
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(featuredEvents) { event in
                            FeaturedEventCard(event: event)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Upcoming Events Section
    
    private var upcomingEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Events")
                    .font(.title3.bold())
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                NavigationLink {
                    Text("All Events - Coming Soon")
                        .navigationTitle("Events")
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.brandPrimary)
                }
            }
            .padding(.horizontal)
            
            if upcomingEvents.isEmpty {
                EmptyEventsPlaceholder()
                    .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    ForEach(upcomingEvents.prefix(3)) { event in
                        EventListCard(event: event)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    // MARK: - Categories Section
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse by Category")
                .font(.title3.bold())
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                CategoryCard(icon: "music.note", title: "Music", color: .brandPrimary)
                CategoryCard(icon: "theatermasks.fill", title: "Arts", color: .brandSecondary)
                CategoryCard(icon: "sportscourt.fill", title: "Sports", color: .brandAccent)
                CategoryCard(icon: "briefcase.fill", title: "Business", color: .stateInfo)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.brandPrimary)
                .scaleEffect(1.2)
            Text("Loading...")
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
                    await loadHomeData()
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

    // MARK: - Load Home Data
    
    @MainActor
    private func loadHomeData() async {
        guard let token = auth.token else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        
        do {
            try await userService.fetchProfile(token: token)
            
            // TODO: Fetch tickets, events when services are implemented
            // upcomingTickets = await TicketService.fetchUpcoming(token: token)
            // upcomingEvents = await EventService.fetchUpcoming(token: token)
            // featuredEvents = await EventService.fetchFeatured(token: token)

        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
        .padding(.vertical, 16)
        .background(Color.surface)
        .cornerRadius(16)
    }
}

struct TicketCard: View {
    let ticket: Ticket
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Ticket Header
            HStack {
                Image(systemName: "ticket.fill")
                    .font(.title2)
                    .foregroundColor(.brandAccent)
                
                Spacer()
                
                Text("×\(ticket.quantity)")
                    .font(.caption.bold())
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.surfaceAlt)
                    .cornerRadius(6)
            }
            
            // Event Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Event #\(ticket.eventId)")
                    .font(.subheadline.bold())
                    .foregroundColor(.textPrimary)
                
                Text(ticket.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            // Status Badge
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.stateSuccess)
                    .frame(width: 6, height: 6)
                Text("Active")
                    .font(.caption2.bold())
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct FeaturedEventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Event Image Placeholder
            Rectangle()
                .fill(Color.brandGradient)
                .frame(width: 280, height: 160)
                .overlay(
                    Image(systemName: "photo.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.3))
                )
            
            // Event Info
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("Coming Soon")
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                    Text("Location")
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
            }
            .padding()
        }
        .frame(width: 280)
        .background(Color.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct FeaturedEventPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.brandPrimary)
            
            VStack(spacing: 8) {
                Text("Featured Events Coming Soon")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text("Check back later for exciting featured events")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.surface)
        .cornerRadius(16)
    }
}

struct EventListCard: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            // Event Image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.brandGradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.3))
                )
            
            // Event Info
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text("Date TBA")
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                    Text("Location TBA")
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
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

struct EmptyEventsPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: 8) {
                Text("No Upcoming Events")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text("New events will appear here")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.surface)
        .cornerRadius(16)
    }
}

struct CategoryCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button {
            // Handle category tap
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.2))
                    .cornerRadius(10)
                
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.textPrimary)
                
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct NotificationsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.textTertiary)
                
                Text("No Notifications")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                
                Text("You're all caught up!\nNotifications will appear here.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxHeight: .infinity)
            .background(Color.backgroundPrimary)
            .navigationTitle("Notifications")
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
    HomeView()
        .environmentObject(AuthService.shared)
}
