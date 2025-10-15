//
//  Color.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import Foundation
import SwiftUI

extension Color {
    /// Initialize Color from hex string (supports 3, 6, and 8-digit hex values)
    /// - Parameter hex: Hex color string (with or without # prefix)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            a = 255
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
            a = 255
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black on invalid input
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Brand Colors
    static let brandPrimary = Color(hex: "2A4FFF")
    static let brandSecondary = Color(hex: "6572FF")
    static let brandAccent = Color(hex: "00D1FF")
    
    // MARK: - Backgrounds
    static let backgroundPrimary = Color(hex: "091746")
    static let backgroundSecondary = Color(hex: "0F225C")
    static let surface = Color(hex: "1C2A5E") // cards, sheets
    static let surfaceAlt = Color(hex: "223371")
    
    // MARK: - Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.75)
    static let textTertiary = Color.white.opacity(0.55)
    static let textInverse = Color(hex: "0A102C")
    
    // MARK: - States
    static let stateError = Color(hex: "FF3B30")
    static let stateSuccess = Color(hex: "34C759")
    static let stateWarning = Color(hex: "FFCC00")
    static let stateInfo = Color(hex: "5AC8FA")
    
    // MARK: - Controls
    static let buttonPrimary = brandPrimary
    static let buttonPrimaryText = Color.white
    static let buttonSecondary = surface
    static let buttonSecondaryText = textPrimary
    static let border = brandPrimary.opacity(0.3)
    static let divider = Color.white.opacity(0.12)
    static let overlay = Color.black.opacity(0.4)
    
    // MARK: - Legacy aliases (for backwards compatibility)
    static let brandBlue = brandPrimary
    static let appBackground = backgroundPrimary
    static let colorGreen = backgroundSecondary // previously misnamed; keeping alias to avoid breakage
    static let primaryText = textPrimary
    static let secondaryText = textSecondary
    static let errorRed = stateError
    static let successGreen = stateSuccess
    static let warningYellow = stateWarning
    static let cardBackground = surface
    static let borderColor = border
    
    // MARK: - Helper Methods
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        self.adjustBrightness(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 0.2) -> Color {
        self.adjustBrightness(by: -abs(percentage))
    }
    
    private func adjustBrightness(by percentage: CGFloat) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(
            red: Double(min(max(red + percentage, 0), 1)),
            green: Double(min(max(green + percentage, 0), 1)),
            blue: Double(min(max(blue + percentage, 0), 1)),
            opacity: Double(alpha)
        )
    }
}

// MARK: - Preview Provider
struct Color_Preview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            colorSwatch(.brandPrimary, name: "Brand Primary")
            colorSwatch(.backgroundPrimary, name: "Background Primary")
            colorSwatch(.surface, name: "Surface")
            colorSwatch(.stateError, name: "Error")
            
            HStack {
                colorSwatch(.brandPrimary.lighter(), name: "Lighter")
                colorSwatch(.brandPrimary, name: "Original")
                colorSwatch(.brandPrimary.darker(), name: "Darker")
            }
        }
        .padding()
        .background(Color.backgroundPrimary)
    }
    
    static func colorSwatch(_ color: Color, name: String) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 100, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            Text(name)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}
