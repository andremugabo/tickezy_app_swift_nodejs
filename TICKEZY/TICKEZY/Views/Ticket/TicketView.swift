//
//  TicketView.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI

struct TicketView: View {
    @StateObject private var ticketService = TicketService.shared
    @EnvironmentObject var auth: AuthService
    @State private var selectedTicket: Ticket?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if ticketService.tickets.isEmpty {
                    emptyStateView
                } else {
                    ticketsList
                }
            }
            .navigationTitle("My Tickets")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadTickets()
            }
            .sheet(item: $selectedTicket) { ticket in
                TicketDetailView(ticket: ticket)
            }
            .task {
                await loadTickets()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.brandPrimary)
                .scaleEffect(1.2)
            Text("Loading tickets...")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
    
    private var ticketsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(ticketService.tickets) { ticket in
                    Button {
                        selectedTicket = ticket
                    } label: {
                        TicketCardView(ticket: ticket)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text("No Tickets Yet")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text("Purchase tickets to see them here")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            NavigationLink {
                EventView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                    Text("Browse Events")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.brandPrimary, Color.brandSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 40)
    }
    
    private func loadTickets() async {
        guard let token = auth.token else {
            isLoading = false
            return
        }
        
        isLoading = true
        await ticketService.fetchMyTickets(token: token)
        isLoading = false
    }
}

#Preview {
    TicketView()
        .environmentObject(AuthService.shared)
}
