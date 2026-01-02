
import SwiftUI

struct AdminTicketsView: View {
    @StateObject private var ticketService = TicketService.shared
    @EnvironmentObject var auth: AuthService
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var ticketToDelete: Ticket?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.brandPrimary)
                            .scaleEffect(1.2)
                        Text("Loading tickets...")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                } else if filteredTickets.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "ticket")
                            .font(.system(size: 60))
                            .foregroundColor(.textTertiary)
                        Text("No tickets found")
                            .font(.title3.bold())
                            .foregroundColor(.textPrimary)
                        Text(searchText.isEmpty ? "No tickets have been purchased yet" : "Try adjusting your search")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredTickets) { ticket in
                                AdminTicketRow(ticket: ticket) {
                                    ticketToDelete = ticket
                                    showDeleteConfirmation = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Manage Tickets")
            .searchable(text: $searchText, prompt: "Search by Event or Ticket ID")
            .refreshable {
                await loadTickets()
            }
            .task {
                await loadTickets()
            }
            .alert("Delete Ticket", isPresented: $showDeleteConfirmation, presenting: ticketToDelete) { ticket in
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteTicket(ticket)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { ticket in
                Text("Are you sure you want to delete this ticket? This action cannot be undone.")
            }
        }
    }
    
    // Filter tickets based on search text
    var filteredTickets: [Ticket] {
        if searchText.isEmpty {
            return ticketService.tickets
        } else {
            return ticketService.tickets.filter { ticket in
                (ticket.Event?.title.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (ticket.id.localizedCaseInsensitiveContains(searchText))
            }
        }
    }
    
    private func loadTickets() async {
        guard let token = auth.token else { return }
        isLoading = true
        await ticketService.fetchMyTickets(token: token) // Admin gets all tickets
        isLoading = false
    }
    
    private func deleteTicket(_ ticket: Ticket) async {
        guard let token = auth.token else { return }
        try? await ticketService.deleteTicket(ticketId: ticket.id, token: token)
        await loadTickets()
    }
}

struct AdminTicketRow: View {
    let ticket: Ticket
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.Event?.title ?? "Unknown Event")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    Text("ID: \(ticket.id)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.textTertiary)
                }
                
                Spacer()
                
                statusBadge
            }
            
            Divider()
                .background(Color.divider)
            
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
                    Text("Purchase Date")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                    Text(ticket.purchaseDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                }
            }
            
            HStack {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Ticket", systemImage: "trash")
                        .font(.subheadline.bold())
                        .foregroundColor(.stateError)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.stateError.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.brandBorder, lineWidth: 1)
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
