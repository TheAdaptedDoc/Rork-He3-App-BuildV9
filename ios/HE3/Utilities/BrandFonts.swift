import SwiftUI

enum BrandFont {
    /// Bebas Neue — headlines, screen titles, button labels, results.
    static func display(_ size: CGFloat) -> Font {
        .custom("BebasNeue-Regular", size: size)
    }

    /// Oswald 700 — the HE³ logo wordmark only.
    static func logo(_ size: CGFloat) -> Font {
        .custom("Oswald", size: size).weight(.bold)
    }

    /// Playfair Display Medium Italic — pull quotes, taglines, emotional anchors.
    static func quote(_ size: CGFloat) -> Font {
        .custom("Playfair Display", size: size).weight(.medium)
    }

    static func body(_ size: CGFloat, weight: BrandFontWeight = .light) -> Font {
        .custom(weight.garamondName, size: size)
    }

    static func mono(_ size: CGFloat, weight: MonoWeight = .regular) -> Font {
        .custom(weight.monoName, size: size)
    }

    enum BrandFontWeight {
        case light, regular, medium, semiBold, bold

        var garamondName: String {
            switch self {
            case .light: "CormorantGaramond-Light"
            case .regular: "CormorantGaramond-Regular"
            case .medium: "CormorantGaramond-Medium"
            case .semiBold: "CormorantGaramond-SemiBold"
            case .bold: "CormorantGaramond-Bold"
            }
        }
    }

    enum MonoWeight {
        case light, regular, medium

        var monoName: String {
            switch self {
            case .light: "DMMono-Light"
            case .regular: "DMMono-Regular"
            case .medium: "DMMono-Medium"
            }
        }
    }
}
