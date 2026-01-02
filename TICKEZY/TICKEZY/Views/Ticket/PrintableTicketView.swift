//
//  PrintableTicketView.swift
//  TICKEZY
//
//  Created by Antigravity on 12/30/25.
//

import SwiftUI

struct PrintableTicketView: View {
    let ticket: Ticket
    let qrCodeImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Main Ticket Content
            VStack(spacing: 32) {
                // Event Info
                if let event = ticket.Event {
                    eventDetailsSection(event: event)
                }
                
                // Divider with "perforation" holes
                perforationDivider
                
                // QR Code Section
                qrCodeSection
                
                // Footer / Terms
                footerSection
            }
            .padding(40)
            .background(Color.white)
        }
        .frame(width: 595, height: 842) // A4 Size at 72dpi
        .background(Color.white)
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TICKEZY")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Official Event Ticket")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Image(systemName: "ticket.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
        .background(
            LinearGradient(
                colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    private func eventDetailsSection(event: Event) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(event.title)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.black)
            
            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("DATE", systemImage: "calendar")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    Text(event.eventDate.formatted(date: .long, time: .omitted))
                        .font(.system(size: 18, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("TIME", systemImage: "clock")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                    Text(event.eventDate.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("LOCATION", systemImage: "mappin.and.ellipse")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                Text(event.location)
                    .font(.system(size: 18, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var perforationDivider: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 2)
                .padding(.horizontal, 10)
            
            HStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(x: -10)
                Spacer()
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(x: 10)
            }
        }
        .padding(.vertical, 10)
    }
    
    private var qrCodeSection: some View {
        VStack(spacing: 20) {
            if let image = qrCodeImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .padding(15)
                    .border(Color.black, width: 2)
            } else {
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .frame(width: 220, height: 220)
                    .overlay(Text("QR Code Data").foregroundColor(.gray))
            }
            
            VStack(spacing: 4) {
                Text("SCAN THIS CODE AT ENTRANCE")
                    .font(.system(size: 12, weight: .black))
                    .tracking(2)
                Text("Ticket ID: \(ticket.id.uppercased())")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("TERMS & CONDITIONS")
                .font(.system(size: 12, weight: .bold))
            Text("This ticket is non-transferable and subject to the event organizer's rules. Please arrive 30 minutes before the event starts. Tickezy is not responsible for lost or stolen tickets.")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Text("© 2025 TICKEZY. ALL RIGHTS RESERVED.")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.top, 40)
    }
}
