//
//  Color.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

// MARK: - Core Color Extension
extension Color {
    
    // MARK: - Hex Initializer
    /// Initialize a Color from a hex string (supports 3, 6, or 8-digit hex, with or without #)
    /// - Parameter hex: Hex string, e.g., "2A4FFF", "#2A4FFF", "FFF"
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
            (a, r, g, b) = (255, 0, 0, 0) // fallback to black
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
    static let brandPrimary   = Color(hex: "2A4FFF")
    static let brandSecondary = Color(hex: "6572FF")
    static let brandAccent    = Color(hex: "00D1FF")
    
    // MARK: - Backgrounds
    static let backgroundPrimary   = Color(hex: "091746")
    static let backgroundSecondary = Color(hex: "0F225C")
    static let surface             = Color(hex: "1C2A5E")
    static let surfaceAlt          = Color(hex: "223371")
    
    // MARK: - Text Colors
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.75)
    static let textTertiary  = Color.white.opacity(0.55)
    static let textInverse   = Color(hex: "0A102C")
    
    // MARK: - State Colors
    static let stateError   = Color(hex: "FF3B30")
    static let stateSuccess = Color(hex: "34C759")
    static let stateWarning = Color(hex: "FFCC00")
    static let stateInfo    = Color(hex: "5AC8FA")
    
    // MARK: - Controls
    static let buttonPrimary       = brandPrimary
    static let buttonPrimaryText   = Color.white
    static let buttonSecondary     = surface
    static let buttonSecondaryText = textPrimary
    static let border              = brandPrimary.opacity(0.3)
    static let divider             = Color.white.opacity(0.12)
    static let overlay             = Color.black.opacity(0.4)
    
    // MARK: - Gradients
    static let brandGradient      = LinearGradient(colors: [brandPrimary, brandSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let accentGradient     = LinearGradient(colors: [brandSecondary, brandAccent], startPoint: .leading, endPoint: .trailing)
    static let backgroundGradient = LinearGradient(colors: [backgroundPrimary, backgroundSecondary], startPoint: .top, endPoint: .bottom)
    static let successGradient    = LinearGradient(colors: [stateSuccess, stateSuccess.lighter(by: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    // MARK: - Legacy Aliases
    @available(*, deprecated, renamed: "brandPrimary")   static let brandBlue      = brandPrimary
    @available(*, deprecated, renamed: "backgroundPrimary") static let appBackground = backgroundPrimary
    @available(*, deprecated, renamed: "backgroundSecondary") static let colorGreen = backgroundSecondary
    @available(*, deprecated, renamed: "textPrimary") static let primaryText = textPrimary
    @available(*, deprecated, renamed: "textSecondary") static let secondaryText = textSecondary
    @available(*, deprecated, renamed: "stateError")   static let errorRed    = stateError
    @available(*, deprecated, renamed: "stateSuccess") static let successGreen = stateSuccess
    @available(*, deprecated, renamed: "stateWarning") static let warningYellow = stateWarning
    @available(*, deprecated, renamed: "surface")      static let cardBackground = surface
    @available(*, deprecated, renamed: "border")       static let borderColor    = border
    
    // MARK: - Helper Methods
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        adjustBrightness(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 0.2) -> Color {
        adjustBrightness(by: -abs(percentage))
    }
    
    func withOpacity(_ opacity: Double) -> Color { self.opacity(opacity) }
    
    private func adjustBrightness(by percentage: CGFloat) -> Color {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: Double(clamp(r + percentage)), green: Double(clamp(g + percentage)), blue: Double(clamp(b + percentage)), opacity: Double(a))
        #elseif canImport(AppKit)
        guard let nsColor = NSColor(self).usingColorSpace(.deviceRGB) else { return self }
        return Color(red: Double(clamp(nsColor.redComponent + percentage)),
                     green: Double(clamp(nsColor.greenComponent + percentage)),
                     blue: Double(clamp(nsColor.blueComponent + percentage)),
                     opacity: Double(nsColor.alphaComponent))
        #else
        return self
        #endif
    }
    
    private func clamp(_ value: CGFloat) -> CGFloat { min(max(value, 0), 1) }
    
    // MARK: - Accessibility
    static func meetsContrastRequirements(foreground: Color, background: Color) -> Bool {
        contrastRatio(between: foreground, and: background) >= 4.5
    }
    
    static func contrastRatio(between color1: Color, and color2: Color) -> CGFloat {
        let lighter = max(relativeLuminance(of: color1), relativeLuminance(of: color2))
        let darker  = min(relativeLuminance(of: color1), relativeLuminance(of: color2))
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private static func relativeLuminance(of color: Color) -> CGFloat {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: nil)
        func comp(_ c: CGFloat) -> CGFloat { c <= 0.03928 ? c/12.92 : pow((c + 0.055)/1.055, 2.4) }
        return 0.2126*comp(r) + 0.7152*comp(g) + 0.0722*comp(b)
        #else
        return 0.5
        #endif
    }
}

// MARK: - Accessible Color Pairs
extension Color {
    struct AccessiblePairs {
        static let primaryOnBackground = (text: Color.textPrimary, background: Color.backgroundPrimary)
        static let primaryOnSurface    = (text: Color.textPrimary, background: Color.surface)
        static let brandOnBackground   = (text: Color.brandPrimary, background: Color.backgroundPrimary)
        static let errorOnBackground   = (text: Color.stateError, background: Color.backgroundPrimary)
        static let successOnBackground = (text: Color.stateSuccess, background: Color.backgroundPrimary)
    }
}
