//
//  NotificationService.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI
import Foundation
import Combine

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    private init() {}
    
    private let baseURL = "http://localhost:3000/api/users"
    
    @Published var notifications: [Notification] = []
    @Published var errorMessage: String?
    
    struct MessageResponse: Codable { let success: Bool?; let message: String }
    struct NotificationsResponse: Codable { let success: Bool; let data: [Notification] }
    
    // MARK: - Fetch notifications
    func fetchNotifications(token: String) async {
        do {
            guard let url = URL(string: "\(baseURL)/notifications") else { throw URLError(.badURL) }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let (data, resp) = try await URLSession.shared.data(for: request)
            guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }
            switch http.statusCode {
            case 200:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(NotificationsResponse.self, from: data)
                self.notifications = result.data
                self.errorMessage = nil
            default:
                if let err = try? JSONDecoder().decode(MessageResponse.self, from: data) {
                    self.errorMessage = err.message
                } else {
                    self.errorMessage = "Failed to fetch notifications"
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Mark one as read
    func markRead(id: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/notifications/\(id)/read") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Mark all as read
    func markAllRead(token: String) async throws {
        guard let url = URL(string: "\(baseURL)/notifications/read-all") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Delete notification
    func deleteNotification(id: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/notifications/\(id)") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Send device token to backend
    func updateDeviceToken(_ tokenValue: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/device-token") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["fcmToken": tokenValue]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
