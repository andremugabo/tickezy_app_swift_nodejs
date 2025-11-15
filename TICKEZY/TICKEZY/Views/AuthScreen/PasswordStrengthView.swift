//
//  PasswordStrengthView.swift
//  TICKEZY
//
//  Created by M.A on 11/15/25.
//

import SwiftUI

struct PasswordStrengthView: View {
    let password: String

    private var strength: PasswordStrength {
        let length = password.count
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil

        var score = 0
        if length >= 8 { score += 1 }
        if length >= 12 { score += 1 }
        if hasUppercase && hasLowercase { score += 1 }
        if hasNumber { score += 1 }
        if hasSpecial { score += 1 }

        switch score {
        case 0...1: return .weak
        case 2...3: return .medium
        default: return .strong
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < strength.rawValue ? strength.color : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: strength.icon).font(.caption2)
                Text(strength.text).font(.caption)
            }
            .foregroundColor(strength.color)
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    enum PasswordStrength: Int {
        case weak = 1
        case medium = 2
        case strong = 3

        var color: Color {
            switch self {
            case .weak: return .stateWarning
            case .medium: return .orange
            case .strong: return .stateSuccess
            }
        }

        var text: String {
            switch self {
            case .weak: return "Weak password"
            case .medium: return "Medium strength"
            case .strong: return "Strong password"
            }
        }

        var icon: String {
            switch self {
            case .weak: return "exclamationmark.triangle.fill"
            case .medium: return "checkmark.circle.fill"
            case .strong: return "checkmark.shield.fill"
            }
        }
    }
}