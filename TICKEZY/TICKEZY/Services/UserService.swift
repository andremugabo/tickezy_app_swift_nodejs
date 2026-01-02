//
//  UserService.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import Foundation
import Combine



@MainActor
class UserService: ObservableObject {
    static let shared = UserService()
    
    private let baseURL = "http://localhost:3000/api/users"
    
    @Published var currentUserProfile: User?
    @Published var allUsers: [User] = []
    
    private init() {}
    
    // MARK: - Response Structs
    struct ProfileResponse: Codable {
        let success: Bool
        let data: User
    }
    
    struct AllUsersResponse: Codable {
        let success: Bool
        let data: [User]
    }
    
    struct BackendErrorResponse: Codable {
        let success: Bool
        let message: String
        let details: [String]?
    }
    
    // MARK: - Fetch current user profile
    func fetchProfile(token: String) async throws {
        guard let url = URL(string: "\(baseURL)/profile") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        switch httpResponse.statusCode {
        case 200:
            let result = try JSONDecoder.tickezyDecoder.decode(ProfileResponse.self, from: data)
            currentUserProfile = result.data
        default:
            if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
        }
    }
    
    // MARK: - Fetch all users (Admin only)
    func fetchAllUsers(token: String) async throws {
        guard let url = URL(string: "\(baseURL)/all") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        switch httpResponse.statusCode {
        case 200:
            let result = try JSONDecoder.tickezyDecoder.decode(AllUsersResponse.self, from: data)
            allUsers = result.data
        default:
            if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
        }
    }
    
    // MARK: - Update user profile
    func updateProfile(name: String, phoneNumber: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/profile") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["name": name, "phoneNumber": phoneNumber]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        switch httpResponse.statusCode {
        case 200:
            let result = try JSONDecoder.tickezyDecoder.decode(ProfileResponse.self, from: data)
            currentUserProfile = result.data
        default:
            if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
        }
    }
    
    // MARK: - Change password
    func changePassword(current: String, new: String, token: String) async throws {
        guard let url = URL(string: "\(baseURL)/profile/password") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["currentPassword": current, "newPassword": new]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        
        switch httpResponse.statusCode {
        case 200:
            return
        default:
            if let errorResponse = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
            } else {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
        }
    }
}
