import SwiftUI

struct EventView: View {
    @StateObject private var viewModel = EventViewModel()
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Search Bar
                    searchSection
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    // MARK: - Filter Pills
                    if viewModel.selectedCategory != nil || viewModel.selectedStatus != nil {
                        activeFiltersSection
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                    }
                    
                    // MARK: - Event List
                    eventListSection
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(.brandPrimary)
                    }
                    .accessibilityLabel("Filter events")
                    .accessibilityHint("Open filter options")
                }
            }
            .sheet(isPresented: $showFilters) {
                filterSheet
            }
            .task {
                await viewModel.fetchEvents()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
    
    // MARK: - Search Section
    
    private var searchSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textSecondary)
                
                TextField("Search events...", text: $viewModel.searchText)
                    .foregroundColor(.textPrimary)
                    .submitLabel(.search)
                    .accessibilityLabel("Search events")
                    .accessibilityHint("Enter event name or keyword")
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(12)
            .background(Color.surface)
            .cornerRadius(12)
            
            Button {
                Task { await viewModel.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.brandPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.surface)
                    .cornerRadius(12)
                    .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                    .animation(viewModel.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
            }
            .disabled(viewModel.isLoading)
            .accessibilityLabel("Refresh events")
        }
    }
    
    // MARK: - Active Filters Section
    
    private var activeFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = viewModel.selectedCategory {
                    FilterPill(text: category.rawValue, icon: "tag.fill") {
                        viewModel.selectedCategory = nil
                    }
                }
                
                if let status = viewModel.selectedStatus {
                    FilterPill(text: status.rawValue, icon: "clock.fill") {
                        viewModel.selectedStatus = nil
                    }
                }
                
                if hasActiveFilters {
                    Button {
                        viewModel.clearFilters()
                    } label: {
                        Text("Clear All")
                            .font(.caption.bold())
                            .foregroundColor(.stateError)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.stateError.opacity(0.15))
                            .cornerRadius(16)
                    }
                }
            }
        }
    }
    
    // MARK: - Event List Section
    
    private var eventListSection: some View {
        Group {
            if viewModel.isLoading && viewModel.events.isEmpty {
                loadingView
            } else if viewModel.events.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.events) { event in
                            EventCardView(event: event)
                                .onAppear {
                                    // Load more when reaching last item
                                    if event.id == viewModel.events.last?.id {
                                        Task {
                                            await viewModel.loadNextPage()
                                        }
                                    }
                                }
                        }
                        
                        // Pagination loader
                        if viewModel.isLoading && !viewModel.events.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        // End of results message
                        if !viewModel.hasMorePages && viewModel.events.count > 0 {
                            Text("No more events")
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading events...")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text(emptyStateTitle)
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if hasActiveFilters {
                Button {
                    viewModel.clearFilters()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Clear Filters")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.brandPrimary)
                    .cornerRadius(12)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateIcon: String {
        if !viewModel.searchText.isEmpty {
            return "magnifyingglass"
        } else if hasActiveFilters {
            return "line.3.horizontal.decrease.circle"
        } else {
            return "calendar.badge.exclamationmark"
        }
    }
    
    private var emptyStateTitle: String {
        if !viewModel.searchText.isEmpty {
            return "No Events Found"
        } else if hasActiveFilters {
            return "No Matching Events"
        } else {
            return "No Events Available"
        }
    }
    
    private var emptyStateMessage: String {
        if !viewModel.searchText.isEmpty {
            return "Try searching with different keywords"
        } else if hasActiveFilters {
            return "Try adjusting your filters to see more events"
        } else {
            return "Check back later for upcoming events"
        }
    }
    
    // MARK: - Filter Sheet
    
    private var filterSheet: some View {
        NavigationStack {
            List {
                Section("Category") {
                    ForEach(EventCategory.allCases, id: \.self) { category in
                        EventFilterButton(
                            title: category.rawValue,
                            icon: "tag.fill",
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = category
                            showFilters = false
                        }
                        .listRowBackground(Color.surface)
                    }
                    
                    EventFilterButton(
                        title: "All Categories",
                        isSelected: viewModel.selectedCategory == nil
                    ) {
                        viewModel.selectedCategory = nil
                        showFilters = false
                    }
                    .listRowBackground(Color.surface)
                }
                
                Section("Status") {
                    ForEach(EventStatus.allCases, id: \.self) { status in
                        EventFilterButton(
                            title: status.rawValue,
                            icon: statusIcon(for: status),
                            isSelected: viewModel.selectedStatus == status
                        ) {
                            viewModel.selectedStatus = status
                            showFilters = false
                        }
                        .listRowBackground(Color.surface)
                    }
                    
                    EventFilterButton(
                        title: "All Status",
                        isSelected: viewModel.selectedStatus == nil
                    ) {
                        viewModel.selectedStatus = nil
                        showFilters = false
                    }
                    .listRowBackground(Color.surface)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.backgroundPrimary)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear All") {
                        viewModel.clearFilters()
                        showFilters = false
                    }
                    .foregroundColor(.stateError)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showFilters = false
                    }
                    .foregroundColor(.brandPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Computed Properties
    
    private var hasActiveFilters: Bool {
        viewModel.selectedCategory != nil || viewModel.selectedStatus != nil
    }
    
    private func statusIcon(for status: EventStatus) -> String {
        switch status {
        case .UPCOMING: return "clock.fill"
        case .ONGOING: return "play.circle.fill"
        case .COMPLETED: return "checkmark.circle.fill"
        case .CANCELLED: return "xmark.circle.fill"
        }
    }
}

// MARK: - Event Card View

struct EventCardView: View {
    let event: Event
    
    var body: some View {
        NavigationLink {
            EventDetailView(event: event)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Event Image
                eventImage
                
                // Event Info
                VStack(alignment: .leading, spacing: 12) {
                    // Status Badge
                    statusBadge
                    
                    // Title
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    // Description
                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    Divider()
                        .background(Color.divider)
                    
                    // Date & Location
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(.brandPrimary)
                            Text(event.eventDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.brandPrimary)
                            Text(event.eventDate.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.brandPrimary)
                        Text(event.location)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Divider()
                        .background(Color.divider)
                    
                    // Price & Tickets
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Price")
                                .font(.caption2)
                                .foregroundColor(.textTertiary)
                            Text("$\(String(format: "%.2f", event.price))")
                                .font(.headline)
                                .foregroundColor(.brandPrimary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Available")
                                .font(.caption2)
                                .foregroundColor(.textTertiary)
                            Text("\(event.availableTickets) tickets")
                                .font(.subheadline.bold())
                                .foregroundColor(event.availableTickets > 0 ? .stateSuccess : .stateError)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var eventImage: some View {
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
                            .frame(height: 180)
                            .clipped()
                    case .failure:
                        imagePlaceholder
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.title3)
                                    Text("Failed to load")
                                        .font(.caption)
                                }
                                .foregroundColor(.textTertiary)
                            )
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(height: 180)
        .background(Color.surfaceAlt)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
    
    private var imagePlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color.brandGradient)
                .opacity(0.3)
            
            Image(systemName: "photo.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption2)
            Text(event.status.rawValue)
                .font(.caption.bold())
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.15))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        switch event.status {
        case .UPCOMING: return "clock.fill"
        case .ONGOING: return "play.circle.fill"
        case .COMPLETED: return "checkmark.circle.fill"
        case .CANCELLED: return "xmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch event.status {
        case .UPCOMING: return .brandPrimary
        case .ONGOING: return .stateSuccess
        case .COMPLETED: return .textTertiary
        case .CANCELLED: return .stateError
        }
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let text: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(text)
                    .font(.caption.bold())
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .foregroundColor(.brandPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.brandPrimary.opacity(0.15))
            .cornerRadius(16)
        }
    }
}

// MARK: - Event Filter Button

struct EventFilterButton: View {
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

// MARK: - Event Detail View

struct EventDetailView: View {
    let event: Event
    @State private var showPurchase = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Event Image
                if let url = event.fullImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Rectangle()
                                    .fill(Color.surfaceAlt)
                                ProgressView()
                            }
                            .frame(height: 250)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.brandGradient.opacity(0.3))
                                .frame(height: 250)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.title)
                                        Text("Failed to load image")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white.opacity(0.7))
                                )
                        @unknown default:
                            Rectangle()
                                .fill(Color.brandGradient.opacity(0.3))
                                .frame(height: 250)
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.brandGradient.opacity(0.3))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title & Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title.bold())
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: statusIcon)
                                .font(.caption)
                            Text(event.status.rawValue)
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(statusColor)
                    }
                    
                    Divider()
                    
                    // Description
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .lineSpacing(4)
                    
                    Divider()
                    
                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(icon: "calendar", label: "Date", value: event.eventDate.formatted(date: .long, time: .omitted))
                        DetailRow(icon: "clock", label: "Time", value: event.eventDate.formatted(date: .omitted, time: .shortened))
                        DetailRow(icon: "mappin.circle.fill", label: "Location", value: event.location)
                        DetailRow(icon: "tag.fill", label: "Category", value: event.category.rawValue)
                    }
                    
                    Divider()
                    
                    // Pricing
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ticket Price")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Text("$\(String(format: "%.2f", event.price))")
                                .font(.title2.bold())
                                .foregroundColor(.brandPrimary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("Available Tickets")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Text("\(event.availableTickets)")
                                .font(.title2.bold())
                                .foregroundColor(event.availableTickets > 0 ? .stateSuccess : .stateError)
                        }
                    }
                    .padding()
                    .background(Color.surface)
                    .cornerRadius(12)
                }
                .padding()
            }
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if event.availableTickets > 0 && event.status == .UPCOMING {
                Button {
                    showPurchase = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "ticket.fill")
                        Text("Buy Ticket")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .brandPrimary.opacity(0.4), radius: 12, x: 0, y: 8)
                }
                .padding()
                .background(Color.backgroundPrimary)
            }
        }
        .sheet(isPresented: $showPurchase) {
            TicketPurchaseView(event: event)
        }
    }
    
    private var statusIcon: String {
        switch event.status {
        case .UPCOMING: return "clock.fill"
        case .ONGOING: return "play.circle.fill"
        case .COMPLETED: return "checkmark.circle.fill"
        case .CANCELLED: return "xmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch event.status {
        case .UPCOMING: return .brandPrimary
        case .ONGOING: return .stateSuccess
        case .COMPLETED: return .textTertiary
        case .CANCELLED: return .stateError
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.brandPrimary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
            }
        }
    }
}

// MARK: - Ticket Purchase View

struct TicketPurchaseView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss
    @State private var quantity = 1
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var totalPrice: Double {
        Double(quantity) * event.price
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Event Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text(event.title)
                            .font(.title2.bold())
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(event.eventDate.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                        }
                        .foregroundColor(.textSecondary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                            Text(event.location)
                                .font(.subheadline)
                        }
                        .foregroundColor(.textSecondary)
                    }
                    .padding()
                    .background(Color.surface)
                    .cornerRadius(12)
                    
                    // Quantity Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Number of Tickets")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        HStack(spacing: 20) {
                            Button {
                                if quantity > 1 {
                                    withAnimation(.spring(response: 0.3)) {
                                        quantity -= 1
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(quantity > 1 ? .brandPrimary : .textTertiary)
                            }
                            .disabled(quantity <= 1)
                            
                            Text("\(quantity)")
                                .font(.title.bold())
                                .foregroundColor(.textPrimary)
                                .frame(minWidth: 50)
                                .contentTransition(.numericText())
                            
                            Button {
                                if quantity < min(event.availableTickets, 10) {
                                    withAnimation(.spring(response: 0.3)) {
                                        quantity += 1
                                    }
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(quantity < min(event.availableTickets, 10) ? .brandPrimary : .textTertiary)
                            }
                            .disabled(quantity >= min(event.availableTickets, 10))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("Maximum 10 tickets per purchase")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.surface)
                    .cornerRadius(12)
                    
                    // Price Summary
                    VStack(spacing: 12) {
                        HStack {
                            Text("Price per ticket")
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("$\(String(format: "%.2f", event.price))")
                                .foregroundColor(.textPrimary)
                        }
                        
                        HStack {
                            Text("Quantity")
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("×\(quantity)")
                                .foregroundColor(.textPrimary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("$\(String(format: "%.2f", totalPrice))")
                                .font(.title2.bold())
                                .foregroundColor(.brandPrimary)
                        }
                    }
                    .padding()
                    .background(Color.surface)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Purchase Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                    .disabled(isProcessing)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task {
                        await purchaseTicket()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "cart.fill")
                        }
                        Text(isProcessing ? "Processing..." : "Confirm Purchase")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.brandPrimary, Color.brandSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .brandPrimary.opacity(0.4), radius: 12, x: 0, y: 8)
                    .opacity(isProcessing ? 0.7 : 1.0)
                }
                .disabled(isProcessing)
                .padding()
                .background(Color.backgroundPrimary)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success!", isPresented: $showSuccess) {
                Button("View My Tickets") {
                    // Navigate to tickets view
                    dismiss()
                }
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Successfully purchased \(quantity) ticket\(quantity > 1 ? "s" : "") for \(event.title)")
            }
        }
    }
    
    private func purchaseTicket() async {
        guard let token = AuthService.shared.token else {
            errorMessage = "Please login to purchase tickets"
            showError = true
            return
        }
        
        isProcessing = true
        
        do {
            try await TicketService.shared.purchaseTicket(
                eventId: event.id,
                quantity: quantity,
                token: token
            )
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isProcessing = false
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    EventView()
}