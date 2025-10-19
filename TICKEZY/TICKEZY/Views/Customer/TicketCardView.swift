//
//  TicketCardView.swift
//  TICKEZY
//
//  Created by M.A on 10/19/25.
//

import SwiftUI

struct TicketCardView: View {
    let ticket: Ticket
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with status
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "ticket.fill")
                        .foregroundColor(.brandAccent)
                    Text("Ticket #\(ticket.id.prefix(8))")
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                statusBadge
            }
            .padding()
            .background(Color.surfaceAlt)
            
            Divider()
            
            // Event Info
            if let event = ticket.Event {
                VStack(alignment: .leading, spacing: 12) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(event.eventDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                    }
                    .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text(event.location)
                            .font(.subheadline)
                    }
                    .foregroundColor(.textSecondary)
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quantity")
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                            Text("×\(ticket.quantity)")
                                .font(.subheadline.bold())
                                .foregroundColor(.textPrimary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Purchased")
                                .font(.caption)
                                .foregroundColor(.textTertiary)
                            Text(ticket.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline.bold())
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                .padding()
            }
            
            // View Details Button
            HStack {
                Image(systemName: "qrcode")
                    .foregroundColor(.brandPrimary)
                Text("Tap to view QR code")
                    .font(.subheadline)
                    .foregroundColor(.brandPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(Color.brandPrimary.opacity(0.1))
        }
        .background(Color.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.border, lineWidth: 1)
        )
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.caption2)
            Text(ticket.status.rawValue)
                .font(.caption.bold())
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.15))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        switch ticket.status {
        case .VALID: return "checkmark.circle.fill"
        case .USED: return "checkmark.seal.fill"
        case .CANCELLED: return "xmark.circle.fill"
        case .REFUNDED: return "arrow.uturn.backward.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch ticket.status {
        case .VALID: return .stateSuccess
        case .USED: return .textTertiary
        case .CANCELLED: return .stateError
        case .REFUNDED: return .stateWarning
        }
    }
}
