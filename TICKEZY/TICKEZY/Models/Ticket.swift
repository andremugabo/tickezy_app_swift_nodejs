//
//  Ticket.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation

enum TicketStatus: String, Codable, CaseIterable {
    case VALID
    case USED
    case CANCELLED
    case REFUNDED
}

struct Ticket: Codable, Identifiable {
    let id: String
    let userId: String
    let eventId: String
    let purchaseDate: Date
    let quantity: Int
    let qrCodeURL: String?
    var status: TicketStatus
    var usedAt: Date?
    var checkedInBy: String?
    let createdAt: Date
    let updatedAt: Date?
    
    // Related event (if included from backend)
    let Event: Event?
    
    enum CodingKeys: String, CodingKey {
        case id, userId, eventId, purchaseDate, quantity
        case qrCodeURL, status, usedAt, checkedInBy
        case createdAt, updatedAt
        case Event
    }
}
