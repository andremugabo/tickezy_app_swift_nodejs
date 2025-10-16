//
//  EventManagement.swift
//  TICKEZY
//
//  Created by M.A on 10/16/25.
//

import SwiftUI
import PhotosUI

struct EventManagement: View {
    @StateObject private var eventService = EventService.shared
    @EnvironmentObject var auth: AuthService
    @State private var showingCreateEvent = false
    @State private var showingEditEvent = false
    @State private var selectedEvent: Event?
    @State private var showingDeleteConfirmation = false
    @State private var eventToDelete: Event?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Stats Header
                    if !eventService.events.isEmpty {
                        statsHeader
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                    }
                    
                    // Events List
                    if eventService.events.isEmpty {
                        emptyStateView
                    } else {
                        eventsList
                    }
                }
            }
            .navigationTitle("Event Management")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateEvent = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.brandPrimary)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingCreateEvent) {
                CreateEventView()
                    .onDisappear {
                        Task {
                            await eventService.fetchEvents()
                        }
                    }
            }
            .sheet(isPresented: $showingEditEvent) {
                if let event = selectedEvent {
                    EditEventView(event: event)
                        .onDisappear {
                            Task {
                                await eventService.fetchEvents()
                            }
                        }
                }
            }
            .confirmationDialog("Delete Event", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let event = eventToDelete {
                        Task {
                            await deleteEvent(event)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let event = eventToDelete {
                    Text("Are you sure you want to delete '\(event.title)'? This action cannot be undone.")
                }
            }
            .task {
                await eventService.fetchEvents()
            }
        }
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total",
                value: "\(eventService.events.count)",
                icon: "calendar",
                color: .brandPrimary
            )
            
            StatCard(
                title: "Upcoming",
                value: "\(eventService.events.filter { $0.status == .UPCOMING }.count)",
                icon: "clock.fill",
                color: .brandAccent
            )
            
            StatCard(
                title: "Published",
                value: "\(eventService.events.filter { $0.isPublished }.count)",
                icon: "checkmark.circle.fill",
                color: .stateSuccess
            )
        }
    }
    
    // MARK: - Events List
    
    private var eventsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(eventService.events) { event in
                    AdminEventCard(
                        event: event,
                        onEdit: {
                            selectedEvent = event
                            showingEditEvent = true
                        },
                        onDelete: {
                            eventToDelete = event
                            showingDeleteConfirmation = true
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text("No Events Created")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text("Create your first event to get started")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Button {
                showingCreateEvent = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Event")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    // MARK: - Delete Event
    
    private func deleteEvent(_ event: Event) async {
        guard let token = auth.token else { return }
        
        await eventService.deleteEvent(eventId: event.id, token: token)
        await eventService.fetchEvents()
    }
}

// MARK: - Admin Event Card

struct AdminEventCard: View {
    let event: Event
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image and Status
            ZStack(alignment: .topTrailing) {
                eventImage
                
                // Status Badge
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
                .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                // Title and Published Status
                HStack {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if event.isPublished {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.stateSuccess)
                    } else {
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
                
                // Date and Location
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(event.eventDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                }
                .foregroundColor(.textSecondary)
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                    Text(event.location)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(.textSecondary)
                
                Divider()
                
                // Stats
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Price")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        Text("$\(String(format: "%.2f", event.price))")
                            .font(.subheadline.bold())
                            .foregroundColor(.brandPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Sold")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        Text("\(event.ticketsSold)/\(event.totalTickets)")
                            .font(.subheadline.bold())
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Available")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        Text("\(event.availableTickets)")
                            .font(.subheadline.bold())
                            .foregroundColor(event.availableTickets > 0 ? .stateSuccess : .stateError)
                    }
                }
                
                Divider()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button {
                        onEdit()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                            Text("Edit")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.brandPrimary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                            Text("Delete")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.stateError)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.stateError.opacity(0.1))
                        .cornerRadius(8)
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
    }
    
    private var eventImage: some View {
        Group {
            if let url = event.fullImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                    default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(height: 150)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }
    
    private var imagePlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color.brandGradient.opacity(0.3))
            
            Image(systemName: "photo.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
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

// MARK: - Create Event View

struct CreateEventView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthService
    @StateObject private var eventService = EventService.shared
    
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var eventDate = Date()
    @State private var price = ""
    @State private var totalTickets = ""
    @State private var category: EventCategory = .OTHER
    @State private var status: EventStatus = .UPCOMING
    @State private var isPublished = false
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var previewImage: Image?
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Picker
                    imagePickerSection
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        FormField(title: "Event Title", text: $title, placeholder: "Enter event title")
                        
                        FormTextEditor(title: "Description", text: $description, placeholder: "Enter event description")
                        
                        FormField(title: "Location", text: $location, placeholder: "Enter event location")
                        
                        // Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Date & Time")
                                .font(.subheadline.bold())
                                .foregroundColor(.textSecondary)
                            
                            DatePicker("", selection: $eventDate, in: Date()...)
                                .datePickerStyle(.compact)
                                .padding(12)
                                .background(Color.surface)
                                .cornerRadius(12)
                        }
                        
                        FormField(title: "Price", text: $price, placeholder: "0.00", keyboardType: .decimalPad)
                        
                        FormField(title: "Total Tickets", text: $totalTickets, placeholder: "0", keyboardType: .numberPad)
                        
                        // Category Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.subheadline.bold())
                                .foregroundColor(.textSecondary)
                            
                            Picker("Category", selection: $category) {
                                ForEach(EventCategory.allCases, id: \.self) { cat in
                                    Text(cat.rawValue).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(12)
                            .background(Color.surface)
                            .cornerRadius(12)
                        }
                        
                        // Status Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.subheadline.bold())
                                .foregroundColor(.textSecondary)
                            
                            Picker("Status", selection: $status) {
                                ForEach(EventStatus.allCases, id: \.self) { stat in
                                    Text(stat.rawValue).tag(stat)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(12)
                            .background(Color.surface)
                            .cornerRadius(12)
                        }
                        
                        // Published Toggle
                        Toggle(isOn: $isPublished) {
                            Text("Publish Event")
                                .font(.subheadline.bold())
                                .foregroundColor(.textSecondary)
                        }
                        .padding(12)
                        .background(Color.surface)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await createEvent()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.brandPrimary)
                        } else {
                            Text("Create")
                                .fontWeight(.semibold)
                                .foregroundColor(isFormValid ? .brandPrimary : .textTertiary)
                        }
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isSuccess ? "Success" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if isSuccess {
                            dismiss()
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Image Picker Section
    
    private var imagePickerSection: some View {
        VStack(spacing: 12) {
            if let previewImage {
                previewImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.textTertiary)
                    
                    Text("No image selected")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.surface)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            PhotosPicker(selection: $selectedImage, matching: .images) {
                HStack(spacing: 8) {
                    Image(systemName: previewImage == nil ? "photo.badge.plus" : "photo.badge.arrow.down")
                    Text(previewImage == nil ? "Select Image" : "Change Image")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.brandPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.brandPrimary.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                        if let uiImage = UIImage(data: data) {
                            previewImage = Image(uiImage: uiImage)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Form Validation
    
    private var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !location.isEmpty &&
        !price.isEmpty &&
        Double(price) != nil &&
        !totalTickets.isEmpty &&
        Int(totalTickets) != nil
    }
    
    // MARK: - Create Event
    
    private func createEvent() async {
        guard let token = auth.token,
              let priceValue = Double(price),
              let ticketsValue = Int(totalTickets) else {
            return
        }
        
        isLoading = true
        
        let eventInput = EventInput(
            title: title,
            description: description,
            location: location,
            eventDate: eventDate,
            price: priceValue,
            totalTickets: ticketsValue,
            category: category,
            status: status,
            isPublished: isPublished,
            imageData: imageData
        )
        
        await eventService.createEvent(event: eventInput, token: token)
        
        await MainActor.run {
            isLoading = false
            
            if eventService.errorMessage == nil {
                isSuccess = true
                alertMessage = "Event created successfully! 🎉"
            } else {
                isSuccess = false
                alertMessage = eventService.errorMessage ?? "Failed to create event"
            }
            
            showAlert = true
        }
    }
}

// MARK: - Edit Event View

struct EditEventView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthService
    @StateObject private var eventService = EventService.shared
    
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var eventDate = Date()
    @State private var price = ""
    @State private var totalTickets = ""
    @State private var category: EventCategory = .OTHER
    @State private var status: EventStatus = .UPCOMING
    @State private var isPublished = false
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var previewImage: Image?
    
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current or New Image
                    imageSection
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        FormField(title: "Event Title", text: $title, placeholder: "Enter event title")
                        FormTextEditor(title: "Description", text: $description, placeholder: "Enter event description")
                        FormField(title: "Location", text: $location, placeholder: "Enter event location")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Event Date & Time")
                                .font(.subheadline.bold())
                                .foregroundColor(.textSecondary)
                            DatePicker("", selection: $eventDate, in: Date()...)
                                .datePickerStyle(.compact)
                                .padding(12)
                                .background(Color.surface)
                                .cornerRadius(12)
                        }
                        
                        FormField(title: "Price", text: $price, placeholder: "0.00", keyboardType: .decimalPad)
                        FormField(title: "Total Tickets", text: $totalTickets, placeholder: "0", keyboardType: .numberPad)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.subheadline.bold())
                                .foregroundColor(.textSecondary)
                            Picker("Category", selection: $category) {
                                ForEach(EventCategory.allCases, id: \.self) { cat in
                                    Text(cat.rawValue).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(12)
                            .background(Color.surface)
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.subheadline.bold())
                                .foregroundColor(.textSecondary)
                            Picker("Status", selection: $status) {
                                ForEach(EventStatus.allCases, id: \.self) { stat in
                                    Text(stat.rawValue).tag(stat)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(12)
                            .background(Color.surface)
                            .cornerRadius(12)
                        }
                        
                        Toggle(isOn: $isPublished) {
                            Text("Publish Event")
                                .font(.subheadline.bold())
                                .foregroundColor(.textSecondary)
                        }
                        .padding(12)
                        .background(Color.surface)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await updateEvent()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.brandPrimary)
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                                .foregroundColor(isFormValid ? .brandPrimary : .textTertiary)
                        }
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isSuccess ? "Success" : "Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if isSuccess {
                            dismiss()
                        }
                    }
                )
            }
            .onAppear {
                loadEventData()
            }
        }
    }
    
    private var imageSection: some View {
        VStack(spacing: 12) {
            if let previewImage {
                previewImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else if let url = event.fullImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                    default:
                        placeholderImage
                    }
                }
                .padding(.horizontal)
            } else {
                placeholderImage
            }
            
            PhotosPicker(selection: $selectedImage, matching: .images) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.badge.arrow.down")
                    Text("Change Image")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.brandPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.brandPrimary.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                        if let uiImage = UIImage(data: data) {
                            previewImage = Image(uiImage: uiImage)
                        }
                    }
                }
            }
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(Color.surface)
            Image(systemName: "photo.fill")
                .font(.system(size: 50))
                .foregroundColor(.textTertiary)
        }
        .frame(height: 200)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !location.isEmpty &&
        !price.isEmpty &&
        Double(price) != nil &&
        !totalTickets.isEmpty &&
        Int(totalTickets) != nil
    }
    
    private func loadEventData() {
        title = event.title
        description = event.description
        location = event.location
        eventDate = event.eventDate
        price = String(format: "%.2f", event.price)
        totalTickets = "\(event.totalTickets)"
        category = event.category
        status = event.status
        isPublished = event.isPublished
    }
    
    private func updateEvent() async {
        guard let token = auth.token,
              let priceValue = Double(price),
              let ticketsValue = Int(totalTickets) else {
            return
        }
        
        isLoading = true
        
        let eventInput = EventInput(
            title: title,
            description: description,
            location: location,
            eventDate: eventDate,
            price: priceValue,
            totalTickets: ticketsValue,
            category: category,
            status: status,
            isPublished: isPublished,
            imageData: imageData
        )
        
        await eventService.updateEvent(eventId: event.id, event: eventInput, token: token)
        
        await MainActor.run {
            isLoading = false
            
            if eventService.errorMessage == nil {
                isSuccess = true
                alertMessage = "Event updated successfully! ✅"
            } else {
                isSuccess = false
                alertMessage = eventService.errorMessage ?? "Failed to update event"
            }
            
            showAlert = true
        }
    }
}

// MARK: - Form Components

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.textSecondary)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(12)
                .background(Color.surface)
                .cornerRadius(12)
                .foregroundColor(.textPrimary)
        }
    }
}

struct FormTextEditor: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.textSecondary)
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.textTertiary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $text)
                    .frame(height: 100)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.textPrimary)
            }
            .background(Color.surface)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        EventManagement()
            .environmentObject(AuthService.shared)
    }
}
