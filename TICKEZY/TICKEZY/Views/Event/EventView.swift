//
//  EventView.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

//
//  EventView.swift
//  TICKEZY
//

import SwiftUI

struct EventView: View {
    @StateObject private var viewModel = EventViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - Filters
                HStack {
                    Menu {
                        ForEach(EventCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) {
                                viewModel.selectedCategory = category
                                Task { await viewModel.fetchEvents() }
                            }
                        }
                        Button("All") {
                            viewModel.selectedCategory = nil
                            Task { await viewModel.fetchEvents() }
                        }
                    } label: {
                        Label(viewModel.selectedCategory?.rawValue ?? "Category", systemImage: "line.3.horizontal.decrease.circle")
                    }

                    Menu {
                        ForEach(EventStatus.allCases, id: \.self) { status in
                            Button(status.rawValue) {
                                viewModel.selectedStatus = status
                                Task { await viewModel.fetchEvents() }
                            }
                        }
                        Button("All") {
                            viewModel.selectedStatus = nil
                            Task { await viewModel.fetchEvents() }
                        }
                    } label: {
                        Label(viewModel.selectedStatus?.rawValue ?? "Status", systemImage: "line.3.horizontal.circle")
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Search
                TextField("Search events...", text: $viewModel.searchText, onCommit: {
                    Task { await viewModel.fetchEvents() }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                
                // MARK: - Event List
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.events) { event in
                            EventCardView(event: event)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Events")
            .task {
                await viewModel.fetchEvents()
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// MARK: - Event Card UI
struct EventCardView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Event Image
            if let imageURL = event.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(12)
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(height: 150)
                        .cornerRadius(12)
                }
            }
            
            // Title & Description
            Text(event.title)
                .font(.headline)
            
            Text(event.description)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.secondary)
            
            // Date & Location
            HStack {
                Text(event.eventDate.formatted(date: .abbreviated, time: .shortened))
                Spacer()
                Text(event.location)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            // Price & Tickets
            HStack {
                Text("Price: $\(String(format: "%.2f", event.price))")
                Spacer()
                Text("Available: \(event.availableTickets)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            // Buy Ticket Button
            NavigationLink(destination: TicketPurchaseView(event: event)) {
                Text("Buy Ticket")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(event.status == .UPCOMING ? Color.white : Color.gray.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 5)
        .padding(.horizontal)
    }
}

// MARK: - Ticket Purchase Placeholder
struct TicketPurchaseView: View {
    let event: Event
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Purchase Ticket for \(event.title)")
                .font(.title2)
                .bold()
            
            Text("Location: \(event.location)")
            Text("Price: $\(String(format: "%.2f", event.price))")
            Spacer()
        }
        .padding()
        .navigationTitle("Buy Ticket")
    }
}
