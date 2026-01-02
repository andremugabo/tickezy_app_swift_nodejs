//
//  PaymentService.swift
//  TICKEZY
//
//  Created by M.A on 11/04/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class PaymentService: ObservableObject {
    static let shared = PaymentService()
    private init() {}
    
    private let baseURL = "http://localhost:3000/api/payments"
    
    @Published var payments: [Payment] = []
    @Published var selectedPayment: Payment?
    @Published var errorMessage: String?
    
    // MARK: - Response Models
    
    struct CreatePaymentResponse: Codable {
        let message: String
        let payment: Payment
    }
    
    struct MessageResponse: Codable {
        let message: String
    }
    
    // MARK: - Create Payment
    
    func createPayment(
        eventId: String,
        ticketId: String,
        amount: Double,
        paymentMethod: String,
        token: String
    ) async throws {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "eventId": eventId,
            "ticketId": ticketId,
            "amount": amount,
            "paymentMethod": paymentMethod
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("💳 Create Payment Status Code:", httpResponse.statusCode)
        print("💳 Response:", String(data: data, encoding: .utf8) ?? "")
        
        switch httpResponse.statusCode {
        case 201:
            let decoder = JSONDecoder.tickezyDecoder
            let result = try decoder.decode(CreatePaymentResponse.self, from: data)
            print("✅ Payment created successfully:", result.message)
            self.errorMessage = nil
        default:
            if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to create payment"])
            }
        }
    }
    
    // MARK: - Fetch All Payments
    
    func fetchPayments(token: String) async {
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
            
            print("📦 Fetch Payments Status Code:", httpResponse.statusCode)
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder.tickezyDecoder
                self.payments = try decoder.decode([Payment].self, from: data)
                self.errorMessage = nil
            default:
                if let error = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                    self.errorMessage = error.message
                } else {
                    self.errorMessage = "Failed to fetch payments"
                }
            }
        } catch {
            print("❌ Fetch payments error:", error)
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Fetch Payment by ID
    
    func fetchPaymentById(id: String, token: String) async {
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
            
            print("📋 Fetch Payment by ID Status Code:", httpResponse.statusCode)
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder.tickezyDecoder
                self.selectedPayment = try decoder.decode(Payment.self, from: data)
                self.errorMessage = nil
            default:
                if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                } else {
                    self.errorMessage = "Failed to fetch payment"
                }
            }
        } catch {
            print("❌ Fetch payment error:", error)
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Update Payment Status (Admin/Staff)
    
    func updatePaymentStatus(id: String, status: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(id)/status") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["status": status]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🔄 Update Payment Status Code:", httpResponse.statusCode)
        
        switch httpResponse.statusCode {
        case 200:
            print("✅ Payment status updated successfully")
            self.errorMessage = nil
        default:
            if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to update payment status"])
            }
        }
    }
    
    // MARK: - Delete Payment (Admin only)
    
    func deletePayment(id: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🗑️ Delete Payment Status Code:", httpResponse.statusCode)
        
        switch httpResponse.statusCode {
        case 200:
            print("✅ Payment deleted successfully")
            self.errorMessage = nil
        default:
            if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to delete payment"])
            }
        }
    }
    
    // MARK: - Filter Payments (Admin only)
    
    func filterPayments(
        status: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        token: String
    ) async {
        do {
            var components = URLComponents(string: "\(baseURL)/filter/search")!
            var queryItems: [URLQueryItem] = []
            
            if let status = status {
                queryItems.append(URLQueryItem(name: "status", value: status))
            }
            if let startDate = startDate {
                let formatter = ISO8601DateFormatter()
                queryItems.append(URLQueryItem(name: "startDate", value: formatter.string(from: startDate)))
            }
            if let endDate = endDate {
                let formatter = ISO8601DateFormatter()
                queryItems.append(URLQueryItem(name: "endDate", value: formatter.string(from: endDate)))
            }
            
            components.queryItems = queryItems
            
            guard let url = components.url else { throw URLError(.badURL) }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("🔍 Filter Payments Status Code:", httpResponse.statusCode)
            
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder.tickezyDecoder
                self.payments = try decoder.decode([Payment].self, from: data)
                self.errorMessage = nil
            default:
                if let errorResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                    self.errorMessage = errorResponse.message
                } else {
                    self.errorMessage = "Failed to filter payments"
                }
            }
        } catch {
            print("Filter payments error:", error)
            self.errorMessage = error.localizedDescription
        }
    }
}
