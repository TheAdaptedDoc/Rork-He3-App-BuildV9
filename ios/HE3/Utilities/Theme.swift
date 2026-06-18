import SwiftUI

/// HE³ Brand System v2.2 — editorial bone / obsidian / crimson.
/// Crimson is the single loud accent. Ember is a quiet depth tone.
/// No gold. No other colors. No rounded corners. No shadows.
enum HE3Theme {
    // MARK: - Exact brand tokens
    static let bone = Color(hex: 0xF2EFE8)        // app background / paper
    static let obsidian = Color(hex: 0x0C0C0E)    // hero type, structural fills, primary button
    static let crimson = Color(hex: 0xA81C1C)     // primary accent, CTA fill, EGO, focus/active
    static let ember = Color(hex: 0x8B4513)       // tertiary / depth, INNATE, warm secondary
    static let ash = Color(hex: 0x3C3A3C)         // body text
    static let ashLight = Color(hex: 0x6E6C6E)    // secondary text
    static let paperDark = Color(hex: 0xDCD8D0)   // dividers, bars, inactive track
    static let paper = Color(hex: 0xEAE5DC)       // subtle card fill on bone

    // MARK: - Semantic roles
    static let background = bone
    static let surface = paper
    static let cardBackground = paper
    static let cardBorder = paperDark

    static let textPrimary = obsidian
    static let textSecondary = ash
    static let textTertiary = ashLight

    static let destructive = crimson

    // MARK: - Legacy aliases (remapped to the new editorial palette)
    // Kept so existing views adopt the rebrand without per-file edits.
    static let charcoal = paper
    static let iron = paper
    static let steel = paperDark
    static let goldDeep = crimson
    static let gold = crimson
    static let goldFire = crimson
    static let goldLight = crimson
    static let bodyText = ash

    static let goldGradient = LinearGradient(
        colors: [crimson, crimson],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let crimsonGradient = goldGradient

    static func voiceColor(_ voice: Voice) -> Color {
        switch voice {
        case .ego: crimson
        case .selfVoice: obsidian
        case .innate: ember
        }
    }

    static func pillarAccent(_ pillar: PillarID) -> Color {
        // Crimson is the single loud accent across the system.
        switch pillar {
        case .suppressed: ember
        case .awakening: crimson
        case .integration: obsidian
        case .rising: crimson
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
