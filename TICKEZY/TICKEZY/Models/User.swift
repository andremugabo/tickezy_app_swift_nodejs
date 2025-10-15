//
//  User.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation

enum UserRole: String, Codable {
    case ADMIN
    case CUSTOMER
}

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let name: String
    let role: UserRole
    let createdAt: Date?          
    let lastLoginAt: Date?
    let fcmToken: String?
    let profileImageURL: String?
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, role, createdAt, lastLoginAt, fcmToken, profileImageURL, phoneNumber
    }
    
    // Shared ISO8601 formatter
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    // Memberwise initializer
    init(
        id: String,
        email: String,
        name: String,
        role: UserRole,
        createdAt: Date? = nil,
        lastLoginAt: Date? = nil,
        fcmToken: String? = nil,
        profileImageURL: String? = nil,
        phoneNumber: String? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.fcmToken = fcmToken
        self.profileImageURL = profileImageURL
        self.phoneNumber = phoneNumber
    }
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        role = try container.decode(UserRole.self, forKey: .role)
        
        // Decode optional createdAt safely
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
           let date = User.isoFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = nil
        }
        
        // Decode optional lastLoginAt safely
        if let lastLoginString = try? container.decode(String.self, forKey: .lastLoginAt),
           let date = User.isoFormatter.date(from: lastLoginString) {
            lastLoginAt = date
        } else {
            lastLoginAt = nil
        }
        
        fcmToken = try? container.decode(String.self, forKey: .fcmToken)
        profileImageURL = try? container.decode(String.self, forKey: .profileImageURL)
        phoneNumber = try? container.decode(String.self, forKey: .phoneNumber)
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(role, forKey: .role)
        if let createdAt {
            try container.encode(User.isoFormatter.string(from: createdAt), forKey: .createdAt)
        }
        if let lastLoginAt {
            try container.encode(User.isoFormatter.string(from: lastLoginAt), forKey: .lastLoginAt)
        }
        try container.encodeIfPresent(fcmToken, forKey: .fcmToken)
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
    }
}
