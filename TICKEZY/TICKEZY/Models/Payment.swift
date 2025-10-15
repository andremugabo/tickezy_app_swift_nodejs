//
//  Payment.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation

enum PaymentStatus: String, Codable {
    case PENDING, SUCCESS, FAILED, REFUNDED
}

enum PaymentMethod: String, Codable {
    case STRIPE, APPLE_PAY
}

struct Payment: Codable, Identifiable {
    let id: String
    let userId: String
    let ticketId: String?
    let eventId: String
    let amount: Double
    let paymentStatus: PaymentStatus
    let paymentMethod: PaymentMethod
    let paymentDate: Date
    let transactionId: String
    let createdAt: Date
}

