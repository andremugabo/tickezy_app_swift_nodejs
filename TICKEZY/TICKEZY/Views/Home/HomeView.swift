//
//  HomeView.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI
import Combine

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
                    homeSkeletalLoading
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
            VStack(spacing: 28) {
                if auth.currentUser?.role == .ADMIN {
                    adminDashboardContent
                } else {
                    customerHomeContent
                }
            }
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Customer Content
    
    private var customerHomeContent: some View {
        VStack(spacing: 28) {
            // Immersive Hero Carousel
            if !featuredEvents.isEmpty {
                HeroCarousel(events: featuredEvents)
                    .padding(.top, -8) // Pull closer to header
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            VStack(spacing: 24) {
                // Personalized Greeting
                customerGreeting
                
                // Enhanced Quick Actions
                customerQuickActions
                
                // My Active Tickets
                if !upcomingTickets.isEmpty {
                    customerTicketsSection
                }
                
                // Discovery Sections
                discoverySections
            }
        }
    }
    
    // MARK: - Admin Content
    
    private var adminDashboardContent: some View {
        VStack(spacing: 28) {
            // Admin Personalized Header
            adminGreeting
            
            // Quick Stats Dashboard
            AdminQuickStatsBar()
            
            // Primary Management Actions
            adminManagementActions
            
            // Recent Overview
            adminOverviewSection
        }
    }

    // MARK: - Greeting Section
    
    // MARK: - Customer Greeting
    
    private var customerGreeting: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingMessage())
                    .font(.subheadline)
                    .foregroundColor(.textTertiary)
                
                Text(auth.currentUser?.name ?? "Guest")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            // Notification Button already in toolbar, maybe just a small badge here or profile pic
            Circle()
                .fill(Color.brandGradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(auth.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.headline)
                        .foregroundColor(.white)
                )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Admin Greeting
    
    private var adminGreeting: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundColor(.brandAccent)
                    Text("Admin Console")
                        .font(.caption.bold())
                        .foregroundColor(.brandAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.brandAccent.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Text("Welcome back, \(auth.currentUser?.name.split(separator: " ").first ?? "Admin")")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Quick Actions
    
    // MARK: - Quick Actions
    
    private var customerQuickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                NavigationLink { EventView() } label: { HomeActionCard(icon: "sparkles", title: "Top Rated", color: .brandPrimary) }
                NavigationLink { EventView() } label: { HomeActionCard(icon: "calendar", title: "Upcoming", color: .brandSecondary) }
                NavigationLink { TicketView() } label: { HomeActionCard(icon: "ticket.fill", title: "Purchased", color: .brandAccent) }
                NavigationLink { FavoritesView() } label: { HomeActionCard(icon: "heart.fill", title: "Saved", color: .stateError) }
            }
            .padding(.horizontal)
        }
    }
    
    private var adminManagementActions: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                NavigationLink { EventManagement() } label: {
                    AdminActionCard(icon: "plus.circle.fill", title: "Create Event", subtitle: "Launch new experience") {}
                }
                NavigationLink { AdminTicketsView() } label: {
                    AdminActionCard(icon: "qrcode.viewfinder", title: "Scan Ticket", subtitle: "Verify attendance") {}
                }
            }
            
            HStack(spacing: 16) {
                NavigationLink { DashboardView() } label: {
                    AdminActionCard(icon: "chart.bar.xaxis", title: "Analytics", subtitle: "Review sales performance") {}
                }
                NavigationLink { AdminTicketsView() } label: { // Or User management view if it exists
                    AdminActionCard(icon: "person.2.fill", title: "Users", subtitle: "Manage members") {}
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - My Tickets Section
    
    // MARK: - Discovery & Sections
    
    private var discoverySections: some View {
        VStack(spacing: 32) {
            featuredEventsSection
            upcomingEventsSection
            categoriesSection
        }
    }
    
    private var customerTicketsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("My Upcoming Tickets")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                NavigationLink("See All") { TicketView() }
                    .font(.subheadline)
                    .foregroundColor(.brandPrimary)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(upcomingTickets.prefix(5)) { ticket in
                        NavigationLink { TicketDetailView(ticket: ticket) } label: {
                            TicketCard(ticket: ticket)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var adminOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Sales")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(ticketService.tickets.prefix(3)) { ticket in
                    AdminActivityRow(ticket: ticket)
                }
            }
            .padding(.horizontal)
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
    
    // MARK: - Skeletal Loading
    
    private var homeSkeletalLoading: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Skeleton
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceAlt)
                            .frame(width: 100, height: 14)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.surfaceAlt)
                            .frame(width: 180, height: 28)
                    }
                    Spacer()
                    Circle()
                        .fill(Color.surfaceAlt)
                        .frame(width: 50, height: 50)
                }
                .padding(.horizontal)
                
                // Hero Skeleton
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.surfaceAlt)
                    .frame(height: 200)
                    .padding(.horizontal)
                
                // Quick Actions Skeleton
                HStack(spacing: 16) {
                    ForEach(0..<4) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.surfaceAlt)
                            .frame(width: 80, height: 100)
                    }
                }
                .padding(.horizontal)
                
                // Content Blocks Skeleton
                VStack(alignment: .leading, spacing: 16) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceAlt)
                        .frame(width: 150, height: 20)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<3) { _ in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.surfaceAlt)
                                    .frame(width: 250, height: 180)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 20)
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
                
                Text(ticket.purchaseDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
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
                .stroke(Color.brandBorder, lineWidth: 1)
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
                                ProgressView().tint(.brandPrimary)
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ZStack {
                                Color.brandGradient.opacity(0.3)
                                Image(systemName: "photo.fill")
                                    .font(.title2)
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
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .frame(width: 280, height: 160)
            .clipped()
            
            // Event Info
            VStack(alignment: .leading, spacing: 10) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 12) {
                    Label(event.eventDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    Label(event.location, systemImage: "mappin.circle.fill")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textTertiary)
                .lineLimit(1)
                
                HStack {
                    Text("\(Int(event.price)) Frw")
                        .font(.subheadline.bold())
                        .foregroundColor(.brandPrimary)
                    
                    Spacer()
                    
                    Text(event.category.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brandPrimary.opacity(0.1))
                        .foregroundColor(.brandPrimary)
                        .cornerRadius(6)
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .frame(width: 280)
        .background(Color.surface)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.brandBorder.opacity(0.5), lineWidth: 1)
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
        HStack(spacing: 16) {
            // Event Image
            Group {
                if let url = event.fullImageURL {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            ZStack {
                                Color.brandGradient.opacity(0.2)
                                Image(systemName: "calendar")
                                    .foregroundColor(.brandPrimary.opacity(0.5))
                            }
                        }
                    }
                } else {
                    ZStack {
                        Color.brandGradient.opacity(0.2)
                        Image(systemName: "calendar")
                            .foregroundColor(.brandPrimary.opacity(0.5))
                    }
                }
            }
            .frame(width: 70, height: 70)
            .cornerRadius(12)
            .clipped()
            
            // Event Info
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Label(event.eventDate.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                    Label(event.location, systemImage: "mappin.and.ellipse")
                }
                .font(.caption)
                .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(event.price)) Frw")
                    .font(.caption.bold())
                    .foregroundColor(.brandPrimary)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.brandBorder.opacity(0.5), lineWidth: 1)
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
                .stroke(Color.brandBorder, lineWidth: 1)
        )
    }
}

struct NotificationsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthService
    @StateObject private var notificationService = NotificationService.shared
    @State private var isLoading = true
    
    // For deep linking
    @State private var selectedEvent: Event?
    @State private var selectedTicket: Ticket?
    @StateObject private var ticketService = TicketService.shared
    @StateObject private var eventService = EventService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.brandPrimary)
                        Text("Loading notifications...")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
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
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(notificationService.notifications) { notif in
                                    NotificationRowView(notification: notif) {
                                        Task { await handleNotificationTap(notif) }
                                    } onDelete: {
                                        Task { await delete(notif) }
                                    } onMarkRead: {
                                        Task { await markRead(notif) }
                                    }
                                }
                            }
                            .padding()
                        }
                        
                        // Mark all read footer
                        if notificationService.notifications.contains(where: { !$0.isRead }) {
                            Button {
                                Task { await markAllRead() }
                            } label: {
                                Text("Mark all as read")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.brandPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.surface.opacity(0.8))
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.brandPrimary)
                }
            }
            .navigationDestination(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
            .navigationDestination(item: $selectedTicket) { ticket in
                TicketDetailView(ticket: ticket)
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
    
    private func handleNotificationTap(_ notif: Notification) async {
        guard let token = auth.token else { return }
        
        // Mark as read immediately
        if !notif.isRead {
            try? await notificationService.markRead(id: notif.id, token: token)
            await notificationService.fetchNotifications(token: token)
        }
        
        // Navigate based on metadata
        if let ticketId = notif.relatedTicketId {
            if let ticket = try? await ticketService.getTicketById(id: ticketId, token: token) {
                selectedTicket = ticket
            }
        } else if let eventId = notif.relatedEventId {
            if let event = try? await eventService.getEventById(id: eventId) {
                selectedEvent = event
            }
        }
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
    let onTap: () -> Void
    let onDelete: () -> Void
    let onMarkRead: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .top, spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(notification.title)
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(notification.timestamp.formatted(.relative(presentation: .named)))
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                    }
                    
                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if !notification.isRead {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.brandPrimary)
                                .frame(width: 6, height: 6)
                            Text("New")
                                .font(.caption2.bold())
                                .foregroundColor(.brandPrimary)
                        }
                        .padding(.top, 2)
                    }
                }
            }
            .padding()
            .background(notification.isRead ? Color.surface.opacity(0.4) : Color.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(notification.isRead ? Color.clear : Color.brandPrimary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            if !notification.isRead {
                Button { onMarkRead() } label: {
                    Label("Mark as Read", systemImage: "envelope.open")
                }
            }
            
            Button(role: .destructive) { onDelete() } label: {
                Label("Delete", systemImage: "trash")
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

// MARK: - Premium Home Components

struct HeroCarousel: View {
    let events: [Event]
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentIndex) {
                ForEach(0..<events.count, id: \.self) { index in
                    NavigationLink {
                        EventDetailView(event: events[index])
                    } label: {
                        HeroEventCard(event: events[index])
                    }
                    .tag(index)
                }
            }
            .frame(height: 220)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Indicators
            HStack(spacing: 6) {
                ForEach(0..<events.count, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? Color.brandPrimary : Color.textTertiary.opacity(0.3))
                        .frame(width: currentIndex == index ? 12 : 6, height: 6)
                        .animation(.spring(), value: currentIndex)
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % events.count
            }
        }
    }
}

struct HeroEventCard: View {
    let event: Event
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            if let url = event.fullImageURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        ZStack {
                            Color.surfaceAlt
                            ProgressView().tint(.brandPrimary)
                        }
                    }
                }
            } else {
                Color.brandGradient
            }
            
            // Masking Overlay - More robust multi-point gradient for visibility
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black.opacity(0.3), location: 0.5),
                    .init(color: .black.opacity(0.8), location: 0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("FEATURED")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.brandPrimary)
                        .cornerRadius(6)
                    
                    Spacer()
                }
                
                Text(event.title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                
                HStack(spacing: 16) {
                    Label(event.location, systemImage: "mappin.circle.fill")
                    Label(event.eventDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .cornerRadius(28)
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

struct HomeActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(color)
            }
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.textPrimary)
        }
        .frame(width: 90, height: 110)
        .background(Color.surface)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AdminActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.brandPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.surface)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct AdminQuickStatsBar: View {
    @StateObject private var ticketService = TicketService.shared
    
    var totalRevenue: Double {
        ticketService.tickets.reduce(0) { $0 + ($1.Event?.price ?? 0) * Double($1.quantity) }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            StatBox(title: "Revenue", value: "\(Int(totalRevenue)) Frw", icon: "banknote.fill", color: .stateSuccess)
            StatBox(title: "Tickets", value: "\(ticketService.tickets.count)", icon: "ticket.fill", color: .brandPrimary)
            StatBox(title: "Events", value: "12", icon: "calendar", color: .brandSecondary) // Placeholder
        }
        .padding(.horizontal)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption2.bold())
                    .foregroundColor(.textSecondary)
                Spacer()
            }
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.textPrimary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

struct AdminActivityRow: View {
    let ticket: Ticket
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.brandGradient)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "cart.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Customer #\(ticket.userId.suffix(6))")
                    .font(.subheadline.bold())
                    .foregroundColor(.textPrimary)
                Text("Purchased \(ticket.quantity) for \(ticket.Event?.title ?? "Event")")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(ticket.purchaseDate?.formatted(.relative(presentation: .named)) ?? "Just now")
                .font(.caption2)
                .foregroundColor(.textTertiary)
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
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
