//
//  EventView.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI

struct EventView: View {
    let events: [Event] = [
        Event(
            id: "1",
            title: "Music Concert",
            description: "An amazing evening with live performances.",
            location: "Kigali Arena",
            eventDate: Date().addingTimeInterval(86400 * 5), // 5 days from now
            price: 25.0,
            totalTickets: 100,
            ticketsSold: 45,
            imageURL: nil,
            createdBy: "admin",
            createdAt: Date(),
            updatedAt: nil,
            isPublished: true,
            category: .CONCERT,
            status: .UPCOMING
        ),
        Event(
            id: "2",
            title: "Tech Conference",
            description: "Learn about the latest tech trends.",
            location: "AUCA Hall",
            eventDate: Date().addingTimeInterval(86400 * 20),
            price: 50.0,
            totalTickets: 200,
            ticketsSold: 150,
            imageURL: nil,
            createdBy: "admin",
            createdAt: Date(),
            updatedAt: nil,
            isPublished: true,
            category: .CONFERENCE,
            status: .UPCOMING
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(events) { event in
                        VStack(alignment: .leading, spacing: 12) {
                            
                            // Event Image
                            if let imageURL = event.imageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 150)
                                        .clipped()
                                        .cornerRadius(12)
                                } placeholder: {
                                    Color.surfaceAlt
                                        .frame(height: 150)
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Event Title & Description
                            Text(event.title)
                                .font(.headline)
                                .foregroundColor(.primaryText)
                            
                            Text(event.description)
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                                .lineLimit(3)
                            
                            // Date & Location
                            HStack {
                                Text(event.eventDate.formatted(date: .abbreviated, time: .shortened))
                                Spacer()
                                Text(event.location)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            
                            // Price & Tickets
                            HStack {
                                Text("Price: $\(String(format: "%.2f", event.price))")
                                Spacer()
                                Text("Available: \(event.availableTickets)")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            
                            // Buy Ticket Button
                            NavigationLink(destination: TicketPurchaseView(event: event)) {
                                Text("Buy Ticket")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.brandAccent)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(event.status == .UPCOMING ? Color.surface : Color.surfaceAlt)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Events")
        }
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

#Preview {
    EventView()
}
