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
    @StateObject private var ticketService = TicketService.shared
    @StateObject private var eventService = EventService.shared
    @StateObject private var notificationService = NotificationService.shared
    
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
                                .opacity(unreadCount > 0 ? 1 : 0)
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
                    EventView()
                } label: {
                    QuickActionCard(
                        icon: "calendar.badge.plus",
                        title: "Browse Events",
                        color: .brandPrimary
                    )
                }
                
                NavigationLink {
                    TicketView()
                } label: {
                    QuickActionCard(
                        icon: "ticket.fill",
                        title: "My Tickets",
                        color: .brandSecondary
                    )
                }
                
                NavigationLink {
                    FavoritesView()
                } label: {
                    QuickActionCard(
                        icon: "heart.fill",
                        title: "Favorites",
                        color: .stateError
                    )
                }
                
                NavigationLink {
                    EventView()
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
                    TicketView()
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
                    EventView()
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
                NavigationLink { EventView() } label: { CategoryCard(icon: "music.note", title: "Music", color: .brandPrimary) }
                NavigationLink { EventView() } label: { CategoryCard(icon: "theatermasks.fill", title: "Arts", color: .brandSecondary) }
                NavigationLink { EventView() } label: { CategoryCard(icon: "sportscourt.fill", title: "Sports", color: .brandAccent) }
                NavigationLink { EventView() } label: { CategoryCard(icon: "briefcase.fill", title: "Business", color: .stateInfo) }
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
            
            await ticketService.fetchMyTickets(token: token)
            await eventService.fetchEvents(limit: 20, isPublished: true)
            await notificationService.fetchNotifications(token: token)
            
            upcomingTickets = ticketService.tickets
            let events = eventService.events
            upcomingEvents = Array(events.filter { $0.status == .UPCOMING }.prefix(10))
            featuredEvents = Array(events.prefix(5))

        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    // Unread notifications count for badge
    private var unreadCount: Int {
        notificationService.notifications.filter { !$0.isRead }.count
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
                Text(ticket.Event?.title ?? "Event #\(ticket.eventId)")
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
            // Event Image
            Group {
                if let url = event.fullImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.surfaceAlt
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                Color.brandGradient.opacity(0.3)
                                Image(systemName: "photo.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        @unknown default:
                            Color.surfaceAlt
                        }
                    }
                } else {
                    ZStack {
                        Color.brandGradient.opacity(0.3)
                        Image(systemName: "photo.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .frame(width: 280, height: 160)
            .clipped()
            
            // Event Info
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(event.eventDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                    Text(event.location)
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
                    Text(event.eventDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption2)
                    Text(event.location)
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
}

struct NotificationsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthService
    @StateObject private var notificationService = NotificationService.shared
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.brandPrimary)
                        Text("Loading notifications...")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if notificationService.notifications.isEmpty {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notificationService.notifications) { notif in
                            NotificationRowView(notification: notif)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button {
                                        Task { await markRead(notif) }
                                    } label: {
                                        Label("Mark Read", systemImage: "envelope.open")
                                    }
                                    .tint(.brandPrimary)
                                    
                                    Button(role: .destructive) {
                                        Task { await delete(notif) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.stateError)
                                }
                                .listRowBackground(Color.surface)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color.backgroundPrimary)
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !notificationService.notifications.isEmpty {
                        Button("Mark All Read") {
                            Task { await markAllRead() }
                        }
                        .foregroundColor(.brandPrimary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.brandPrimary)
                }
            }
        }
        .task { await fetch() }
    }
    
    private func fetch() async {
        guard let token = auth.token else {
            isLoading = false
            return
        }
        await notificationService.fetchNotifications(token: token)
        isLoading = false
    }
    
    private func markRead(_ notif: Notification) async {
        guard let token = auth.token else { return }
        do {
            try await notificationService.markRead(id: notif.id, token: token)
            await notificationService.fetchNotifications(token: token)
        } catch { }
    }
    
    private func delete(_ notif: Notification) async {
        guard let token = auth.token else { return }
        do {
            try await notificationService.deleteNotification(id: notif.id, token: token)
            await notificationService.fetchNotifications(token: token)
        } catch { }
    }
    
    private func markAllRead() async {
        guard let token = auth.token else { return }
        do {
            try await notificationService.markAllRead(token: token)
            await notificationService.fetchNotifications(token: token)
        } catch { }
    }
}

struct NotificationRowView: View {
    let notification: Notification
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    Spacer()
                    Text(notification.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 6)
        .overlay(alignment: .leading) {
            if !notification.isRead {
                Capsule()
                    .fill(Color.brandPrimary)
                    .frame(width: 3)
                    .offset(x: -8)
            }
        }
    }
    
    private var icon: String {
        switch notification.type {
        case .TICKET_CONFIRMATION: return "ticket.fill"
        case .EVENT_REMINDER: return "calendar.badge.clock"
        case .PAYMENT_SUCCESS: return "checkmark.seal.fill"
        case .EVENT_UPDATE: return "bell.badge.fill"
        case .ADMIN_MESSAGE: return "envelope.badge"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .TICKET_CONFIRMATION: return .brandSecondary
        case .EVENT_REMINDER: return .brandPrimary
        case .PAYMENT_SUCCESS: return .stateSuccess
        case .EVENT_UPDATE: return .stateInfo
        case .ADMIN_MESSAGE: return .brandAccent
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AuthService.shared)
}

// MARK: - Favorites View (placeholder)
struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.textTertiary)
                    Text("No Favorites Yet")
                        .font(.title2.bold())
                        .foregroundColor(.textPrimary)
                    Text("Tap the heart on events to save them here.")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    NavigationLink {
                        EventView()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                            Text("Browse Events")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.brandPrimary, Color.brandSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
