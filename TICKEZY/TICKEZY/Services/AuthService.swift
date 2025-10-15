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

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let baseURL = "http://localhost:3000/api/users"
    
    @Published var token: String? {
        didSet {
            if let token { saveToken(token) } else { deleteToken() }
        }
    }
    
    @Published var currentUser: User?
    
    private init() {
        self.token = getToken()
        if let token = token {
            currentUser = decodeJWT(token)
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
    
    // MARK: - Login
    func login(email: String, password: String) async throws {
        guard let url = URL(string: "\(baseURL)/login") else { throw URLError(.badURL) }
        let body = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        print("🟢 [LOGIN] Response:")
        printRawJSON(data)
        
        try handleResponse(data: data)
    }
    
    // MARK: - Register
    func register(name: String, email: String, password: String, phoneNumber: String) async throws {
        guard let url = URL(string: "\(baseURL)/register") else { throw URLError(.badURL) }
        let body = ["name": name, "email": email, "password": password, "phoneNumber": phoneNumber]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        print("🟢 [REGISTER] Response:")
        printRawJSON(data)
        
        try handleResponse(data: data)
    }
    
    // MARK: - Response Handling
    private func handleResponse(data: Data) throws {
        // Try decoding as AuthResponse
        if let result = try? JSONDecoder().decode(AuthResponse.self, from: data) {
            if result.success {
                self.token = result.token
                self.currentUser = result.data
            } else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: result.message])
            }
            return
        }
        
        // Try decoding as ErrorResponse
        if let errorResult = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorResult.message])
        }
        
        // Fallback
        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    // MARK: - Logout
    func logout() {
        token = nil
        currentUser = nil
        print("👋 User logged out")
    }
    
    // MARK: - JWT Decoding
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
        
        return User(id: id, email: email, name: name, role: role, createdAt: Date())
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
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.tickezy.app",
            kSecAttrAccount as String: "jwtToken",
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        if let data = result as? Data { return String(data: data, encoding: .utf8) }
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
