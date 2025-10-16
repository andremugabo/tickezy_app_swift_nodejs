//
//  Event.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation

enum EventCategory: String, Codable, CaseIterable {
    case CONCERT, SPORTS, CONFERENCE, THEATER, OTHER
}

enum EventStatus: String, Codable, CaseIterable {
    case UPCOMING, ONGOING, COMPLETED, CANCELLED
}


struct Event: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let location: String
    let eventDate: Date
    let price: Double
    let totalTickets: Int
    let ticketsSold: Int
    let imageURL: String?       
    let createdBy: String?
    let createdAt: Date?
    let updatedAt: Date?
    let isPublished: Bool
    let category: EventCategory
    let status: EventStatus

    var availableTickets: Int {
        max(0, totalTickets - ticketsSold)
    }
    
    // Computed property to generate full URL
    var fullImageURL: URL? {
        guard let imageURL else { return nil }
        if imageURL.hasPrefix("http") {
            return URL(string: imageURL)
        } else {
            // Replace localhost with your server URL if needed
            return URL(string: "http://localhost:3000\(imageURL)")
        }
    }
}
