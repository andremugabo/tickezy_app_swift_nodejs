//
//  AuthService.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation
import SwiftUI
import Security
import Combine

// MARK: - Custom Errors
enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case serverError(String)
    case decodingError
    case invalidResponse
    case tokenExpired
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .networkError: return "Network connection failed"
        case .serverError(let message): return message
        case .decodingError: return "Failed to parse server response"
        case .invalidResponse: return "Invalid response from server"
        case .tokenExpired: return "Session expired. Please login again"
        }
    }
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private var baseURL: String {
        #if DEBUG
        // For iOS Simulator use localhost, for real device use your Mac's IP
        return "http://localhost:3000/api/users"
        #else
        return "https://api.yourapp.com/api/users"
        #endif
    }
    
    @Published var token: String? {
        didSet {
            if let token { saveToken(token) } else { deleteToken() }
        }
    }
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    
    private var urlSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }
    
    private init() {
        self.token = getToken()
        if let token = token {
            if !isTokenExpired(token) {
                currentUser = decodeJWT(token)
                isAuthenticated = true
            } else {
                self.token = nil
                print("⚠️ Token expired, user logged out")
            }
        }
    }
    
    // MARK: - Response Structs
    struct AuthResponse: Codable {
        let success: Bool
        let message: String
        let token: String
        let data: User
    }
    
    struct ErrorResponse: Codable {
        let success: Bool
        let message: String
    }
    
    struct UserResponse: Codable {
        let success: Bool
        let data: User
    }
    
    // MARK: - Validation
    private func validateCredentials(email: String, password: String) throws {
        guard !email.isEmpty, email.contains("@") else {
            throw AuthError.serverError("Please enter a valid email")
        }
        guard password.count >= 6 else {
            throw AuthError.serverError("Password must be at least 6 characters")
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws {
        try validateCredentials(email: email, password: password)
        
        guard let url = URL(string: "\(baseURL)/login") else {
            throw URLError(.badURL)
        }
        
        let body = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await urlSession.data(for: request)
        
        print("🟢 [LOGIN] Response:")
        printRawJSON(data)
        
        try handleResponse(data: data, response: response)
        isAuthenticated = true
    }
    
    // MARK: - Register
    func register(name: String, email: String, password: String, phoneNumber: String) async throws {
        try validateCredentials(email: email, password: password)
        
        guard !name.isEmpty else {
            throw AuthError.serverError("Name is required")
        }
        
        guard let url = URL(string: "\(baseURL)/register") else {
            throw URLError(.badURL)
        }
        
        let body = [
            "name": name,
            "email": email,
            "password": password,
            "phoneNumber": phoneNumber
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await urlSession.data(for: request)
        
        print("🟢 [REGISTER] Response:")
        printRawJSON(data)
        
        try handleResponse(data: data, response: response)
        isAuthenticated = true
    }
    
    // MARK: - Fetch Current User
    func fetchCurrentUser() async throws {
        guard let token = token else {
            throw AuthError.invalidCredentials
        }
        
        guard let url = URL(string: "\(baseURL)/me") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await urlSession.data(for: request)
        
        let result = try JSONDecoder().decode(UserResponse.self, from: data)
        self.currentUser = result.data
    }
    
    // MARK: - Response Handling
    private func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        // Check status codes
        switch httpResponse.statusCode {
        case 200...299:
            break // Success
        case 401:
            throw AuthError.invalidCredentials
        case 400:
            // Try to get error message from response
            if let errorResult = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw AuthError.serverError(errorResult.message)
            }
            throw AuthError.serverError("Bad request")
        case 500...599:
            throw AuthError.serverError("Server error occurred")
        default:
            throw AuthError.networkError
        }
        
        // Try decoding as AuthResponse
        if let result = try? JSONDecoder().decode(AuthResponse.self, from: data) {
            if result.success {
                self.token = result.token
                self.currentUser = result.data
            } else {
                throw AuthError.serverError(result.message)
            }
            return
        }
        
        // Try decoding as ErrorResponse
        if let errorResult = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            throw AuthError.serverError(errorResult.message)
        }
        
        throw AuthError.decodingError
    }
    
    // MARK: - Logout
    func logout() {
        token = nil
        currentUser = nil
        isAuthenticated = false
        print("👋 User logged out")
    }
    
    // MARK: - JWT Decoding & Validation
    private func isTokenExpired(_ token: String) -> Bool {
        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return true }
        
        let payloadSegment = segments[1]
        var base64 = String(payloadSegment)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let payload = json as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            return true
        }
        
        return Date().timeIntervalSince1970 >= exp
    }
    
    private func decodeJWT(_ jwt: String) -> User? {
        let segments = jwt.split(separator: ".")
        guard segments.count > 1 else { return nil }
        let payloadSegment = segments[1]
        
        var base64 = String(payloadSegment)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let payload = json as? [String: Any],
              let id = payload["id"] as? String,
              let email = payload["email"] as? String,
              let name = payload["name"] as? String,
              let roleString = payload["role"] as? String,
              let role = UserRole(rawValue: roleString)
        else { return nil }
        
        let phoneNumber = payload["phoneNumber"] as? String
        
        return User(
            id: id,
            email: email,
            name: name,
            role: role,
            createdAt: Date(),
            phoneNumber: phoneNumber,
            
        )
    }
    
    // MARK: - Keychain Token Management
    private func saveToken(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.tickezy.app",
            kSecAttrAccount as String: "jwtToken",
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("⚠️ Failed to save token: \(status)")
        }
    }
    
    private func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.tickezy.app",
            kSecAttrAccount as String: "jwtToken",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.tickezy.app",
            kSecAttrAccount as String: "jwtToken"
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Debug Print
    private func printRawJSON(_ data: Data) {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let formattedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: formattedData, encoding: .utf8) {
            print("🧾 Raw JSON:\n\(jsonString)")
        }
    }
}
