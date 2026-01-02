//
//  PaymentCardView.swift
//  TICKEZY
//
//  Created by M.A on 11/4/25.
//

import SwiftUI

struct PaymentCardView: View {
    let payment: Payment

    var body: some View {
        HStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: statusIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)
            }

            // Payment Details
            VStack(alignment: .leading, spacing: 4) {
                Text("Transaction: \(payment.transactionId.prefix(8))...")
                    .font(.subheadline.bold())
                    .foregroundColor(.textPrimary)

                Text(payment.paymentDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                HStack {
                    Text(payment.paymentMethod.rawValue.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.surface.opacity(0.7))
                        .cornerRadius(8)

                    Text(payment.paymentStatus.rawValue)
                        .font(.caption2.bold())
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.15))
                        .cornerRadius(8)
                }
            }

            Spacer()

            // Amount
            VStack(alignment: .trailing) {
                Text("\(Int(payment.amount)) Frw")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text("View")
                    .font(.caption2)
                    .foregroundColor(.brandPrimary)
            }
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var statusColor: Color {
        switch payment.paymentStatus {
        case .SUCCESS: return .stateSuccess
        case .PENDING: return .stateWarning
        case .FAILED: return .stateError
        case .REFUNDED: return .stateWarning
        }
    }

    private var statusIcon: String {
        switch payment.paymentStatus {
        case .SUCCESS: return "checkmark.circle.fill"
        case .PENDING: return "clock.fill"
        case .FAILED: return "xmark.octagon.fill"
        case .REFUNDED: return "arrow.uturn.backward.circle.fill"
        }
    }
}

#Preview {
    PaymentCardView(payment: Payment(
        id: "123",
        userId: "u1",
        ticketId: "t1",
        eventId: "e1",
        amount: 45.99,
        paymentStatus: .SUCCESS,
        paymentMethod: .STRIPE,
        paymentDate: .now,
        transactionId: "TXN-20251104-ABCDEFG",
        createdAt: .now
    ))
    .padding()
    .background(Color.backgroundPrimary)
}

