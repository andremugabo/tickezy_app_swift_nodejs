//
//  TicketService.swift
//  TICKEZY
//
//  Created by M.A on 10/19/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TicketService: ObservableObject {
    static let shared = TicketService()
    private init() {}
    
    private let baseURL = "http://localhost:3000/api/tickets"
    
    @Published var tickets: [Ticket] = []
    @Published var selectedTicket: Ticket?
    @Published var errorMessage: String?
    
    // MARK: - Response Models
    
    struct CreateTicketResponse: Codable {
        let message: String
        let ticket: Ticket
    }
    
    struct TicketResponse: Codable {
        let ticket: Ticket
        
        // Support both wrapped and direct responses
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let ticket = try? container.decode(Ticket.self) {
                self.ticket = ticket
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ticket response")
            }
        }
    }
    
    struct MessageResponse: Codable {
        let message: String
    }
    
    // MARK: - Fetch All Tickets (My Tickets for regular users, All for admin)
    
    func fetchMyTickets(token: String) async {
        do {
            guard let url = URL(string: baseURL) else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("📫 Fetch Tickets Status Code:", httpResponse.statusCode)
            print("📫 Response:", String(data: data, encoding: .utf8) ?? "")
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                // Backend returns array directly, not wrapped
                self.tickets = try decoder.decode([Ticket].self, from: data)
                self.errorMessage = nil
                print("✅ Fetched \(self.tickets.count) tickets")
            default:
                if let errorMessage = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                    self.errorMessage = errorMessage.message
                } else {
                    self.errorMessage = "Failed to fetch tickets"
                }
            }
        } catch {
            print("❌ Fetch tickets error:", error)
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Purchase Ticket
    
    func purchaseTicket(eventId: String, quantity: Int, token: String) async throws {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "eventId": eventId,
            "quantity": quantity
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🎫 Purchase Ticket Status Code:", httpResponse.statusCode)
        print("🎫 Response:", String(data: data, encoding: .utf8) ?? "")
        
        switch httpResponse.statusCode {
        case 201:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(CreateTicketResponse.self, from: data)
            print("✅ Ticket purchased: \(result.message)")
            self.errorMessage = nil
        default:
            if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to purchase ticket"])
            }
        }
    }
    
    // MARK: - Get Ticket by ID
    
    func fetchTicketById(_ id: String, token: String) async {
        do {
            guard let url = URL(string: "\(baseURL)/\(id)") else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("📋 Fetch Ticket by ID Status:", httpResponse.statusCode)
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                // Backend returns ticket directly
                self.selectedTicket = try decoder.decode(Ticket.self, from: data)
                self.errorMessage = nil
            default:
                if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                } else {
                    self.errorMessage = "Failed to fetch ticket"
                }
            }
        } catch {
            print("❌ Fetch ticket error:", error)
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Update Ticket Status (Admin/Staff only)
    
    func updateTicketStatus(ticketId: String, status: TicketStatus, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(ticketId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["status": status.rawValue]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🔄 Update Ticket Status Code:", httpResponse.statusCode)
        
        switch httpResponse.statusCode {
        case 200:
            print("✅ Ticket status updated")
            self.errorMessage = nil
        default:
            if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to update ticket"])
            }
        }
    }
    
    // MARK: - Delete Ticket (Admin only)
    
    func deleteTicket(ticketId: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(ticketId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🗑️ Delete Ticket Status Code:", httpResponse.statusCode)
        
        switch httpResponse.statusCode {
        case 200:
            print("✅ Ticket deleted")
            self.errorMessage = nil
        default:
            if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete ticket"])
            }
        }
    }
}
