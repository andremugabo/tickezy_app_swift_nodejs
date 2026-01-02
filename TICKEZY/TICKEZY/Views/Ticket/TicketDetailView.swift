//
//  TicketDetailView.swift
//  TICKEZY
//
//  Created by M.A on 10/19/25.
//

import SwiftUI

struct TicketDetailView: View {
    let ticket: Ticket
    @Environment(\.dismiss) var dismiss
    @State private var qrCodeImage: UIImage?
    @State private var brightness: CGFloat = UIScreen.main.brightness
    
    @State private var isGeneratingPDF = false
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // QR Code
                        qrCodeSection
                        
                        // Ticket Info
                        if let event = ticket.Event {
                            eventInfoSection(event: event)
                        }
                        
                        // Ticket Details
                        ticketDetailsSection
                    }
                    .padding()
                }
                .background(Color.backgroundPrimary)
                
                if isGeneratingPDF {
                    loadingOverlay
                }
            }
            .navigationTitle("Ticket Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            generatePDFTicket()
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.brandPrimary)
                        
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundColor(.brandPrimary)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .onAppear {
                // Increase brightness for better QR scanning
                brightness = UIScreen.main.brightness
                UIScreen.main.brightness = 1.0
                loadQRCode()
            }
            .onDisappear {
                // Restore original brightness
                UIScreen.main.brightness = brightness
            }
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Generating PDF...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private var qrCodeSection: some View {
        VStack(spacing: 16) {
            if let qrImage = qrCodeImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 10)
            } else {
                ProgressView()
                    .frame(width: 250, height: 250)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            
            Text("Show this QR code at the event entrance")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            // Status Badge
            HStack(spacing: 6) {
                Image(systemName: statusIcon)
                Text(ticket.status.rawValue)
                    .font(.subheadline.bold())
            }
            .foregroundColor(statusColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(statusColor.opacity(0.15))
            .cornerRadius(10)
        }
    }
    
    private func eventInfoSection(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.title)
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                TicketInfoRow(icon: "calendar", label: "Date & Time", value: event.eventDate.formatted(date: .long, time: .shortened))
                TicketInfoRow(icon: "mappin.circle.fill", label: "Location", value: event.location)
                TicketInfoRow(icon: "tag.fill", label: "Category", value: event.category.rawValue)
            }
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
    }
    
    private var ticketDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ticket Information")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                TicketDetailRow(label: "Ticket ID", value: String(ticket.id.prefix(12)))
                TicketDetailRow(label: "Quantity", value: "×\(ticket.quantity)")
                TicketDetailRow(label: "Purchase Date", value: ticket.purchaseDate?.formatted(date: .long, time: .shortened) ?? "Unknown")
                
                if let usedAt = ticket.usedAt {
                    TicketDetailRow(label: "Used At", value: usedAt.formatted(date: .long, time: .shortened))
                }
                
                if let checkedInBy = ticket.checkedInBy {
                    TicketDetailRow(label: "Checked In By", value: checkedInBy)
                }
            }
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
    }
    
    private func generatePDFTicket() {
        withAnimation(.spring()) {
            isGeneratingPDF = true
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // Short delay to allow UI to breathe
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let printableTicket = PrintableTicketView(ticket: ticket, qrCodeImage: qrCodeImage)
            let fileName = "Tickezy_Ticket_\(ticket.id.prefix(8))"
            
            if let url = PDFGenerator.generatePDF(from: printableTicket, fileName: fileName) {
                self.pdfURL = url
                self.showShareSheet = true
                
                // Success haptic
                let successGen = UINotificationFeedbackGenerator()
                successGen.notificationOccurred(.success)
            }
            
            withAnimation {
                isGeneratingPDF = false
            }
        }
    }
    
    private func loadQRCode() {
        guard let qrCodeURL = ticket.qrCodeURL else { return }
        
        // If it's a base64 data URL
        if qrCodeURL.hasPrefix("data:image") {
            let base64String = qrCodeURL.components(separatedBy: ",").last ?? ""
            if let data = Data(base64Encoded: base64String) {
                qrCodeImage = UIImage(data: data)
            }
        } else if let url = URL(string: qrCodeURL.hasPrefix("http") ? qrCodeURL : "http://localhost:3000\(qrCodeURL)") {
            // Download from URL
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    await MainActor.run {
                        qrCodeImage = UIImage(data: data)
                    }
                } catch {
                    print("Failed to load QR code: \(error)")
                }
            }
        }
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

// MARK: - Supporting Views (Renamed to avoid conflicts)

struct TicketInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.brandPrimary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
            }
        }
    }
}

struct TicketDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
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
}

// MARK: - Share Sheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
