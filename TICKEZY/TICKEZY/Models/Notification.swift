//
//  Notification.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation

enum NotificationType: String, Codable {
    case TICKET_CONFIRMATION, EVENT_REMINDER, PAYMENT_SUCCESS, EVENT_UPDATE, ADMIN_MESSAGE
}

struct Notification: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    let isRead: Bool
    let relatedEventId: String?
    let relatedTicketId: String?
}

