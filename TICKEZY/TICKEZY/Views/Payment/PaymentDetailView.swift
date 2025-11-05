//
//  PaymentDetailView.swift
//  TICKEZY
//
//  Created by M.A on 11/4/25.
//

import SwiftUI

struct PaymentDetailView: View {
    let payment: Payment
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary section
                    summarySection

                    // Details section
                    paymentInfoSection
                }
                .padding()
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Payment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.brandPrimary)
                }
            }
        }
    }

    private var summarySection: some View {
        VStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.system(size: 50))
                .foregroundColor(statusColor)
                .padding(.bottom, 4)

            Text(payment.paymentStatus.rawValue)
                .font(.title3.bold())
                .foregroundColor(statusColor)

            Text("$\(payment.amount, specifier: "%.2f")")
                .font(.title.bold())
                .foregroundColor(.textPrimary)

            Text(payment.paymentDate.formatted(date: .long, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.surface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var paymentInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transaction Information")
                .font(.headline)
                .foregroundColor(.textPrimary)

            VStack(spacing: 12) {
                infoRow(label: "Transaction ID", value: payment.transactionId)
                infoRow(label: "Payment Method", value: payment.paymentMethod.rawValue)
                infoRow(label: "Event ID", value: payment.eventId)
                if let ticketId = payment.ticketId {
                    infoRow(label: "Ticket ID", value: ticketId)
                }
                infoRow(label: "Status", value: payment.paymentStatus.rawValue)
                infoRow(label: "Created At", value: payment.createdAt.formatted(date: .long, time: .shortened))
            }
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.trailing)
        }
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
    PaymentDetailView(payment: Payment(
        id: "123",
        userId: "u1",
        ticketId: "t1",
        eventId: "e1",
        amount: 89.50,
        paymentStatus: .SUCCESS,
        paymentMethod: .APPLE_PAY,
        paymentDate: .now,
        transactionId: "TXN-20251104-ABCD1234",
        createdAt: .now
    ))
}
