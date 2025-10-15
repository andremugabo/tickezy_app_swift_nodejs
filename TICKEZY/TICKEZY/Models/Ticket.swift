//
//  Ticket.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation

enum TicketStatus: String, Codable {
    case VALID, USED, CANCELLED, REFUNDED
}

struct Ticket: Codable, Identifiable {
    let id: String
    let userId: String
    let eventId: String
    let purchaseDate: Date
    let quantity: Int
    let qrCodeURL: String?
    let status: TicketStatus
    let usedAt: Date?
    let checkedInBy: String?
    let createdAt: Date
    let updatedAt: Date?
}
