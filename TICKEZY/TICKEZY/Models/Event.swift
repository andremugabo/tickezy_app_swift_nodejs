//
//  Event.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation

enum EventCategory: String, Codable {
    case CONCERT, SPORTS, CONFERENCE, THEATER, OTHER
}

enum EventStatus: String, Codable {
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
    let createdBy: String
    let createdAt: Date
    let updatedAt: Date?
    let isPublished: Bool
    let category: EventCategory
    let status: EventStatus

    var availableTickets: Int {
        max(0, totalTickets - ticketsSold)
    }
}
