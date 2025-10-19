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
    var status: TicketStatus
    var usedAt: Date?
    var checkedInBy: String?
    let createdAt: Date
    let updatedAt: Date?
}
