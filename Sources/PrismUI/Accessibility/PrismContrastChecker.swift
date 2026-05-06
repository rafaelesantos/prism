import SwiftUI

public enum PrismContrastLevel: String, Sendable, CaseIterable, Hashable {
    case aa
    case aaa
    case aaLargeText
    case aaaLargeText

    public var minimumRatio: Double {
        switch self {
        case .aa: return 4.5
        case .aaa: return 7.0
        case .aaLargeText: return 3.0
        case .aaaLargeText: return 4.5
        }
    }
}

public struct PrismContrastChecker: Sendable {

    public static func contrastRatio(between color1: Color, and color2: Color) -> Double {
        let l1 = relativeLuminance(of: color1)
        let l2 = relativeLuminance(of: color2)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    public static func meetsLevel(
        _ level: PrismContrastLevel,
        foreground: Color,
        background: Color
    ) -> Bool {
        contrastRatio(between: foreground, and: background) >= level.minimumRatio
    }

    public static func suggestAccessibleColor(
        for foreground: Color,
        on background: Color,
        level: PrismContrastLevel
    ) -> Color {
        if meetsLevel(level, foreground: foreground, background: background) {
            return foreground
        }

        let resolved = foreground.resolve(in: EnvironmentValues())
        var r = Double(resolved.red)
        var g = Double(resolved.green)
        var b = Double(resolved.blue)
        let a = Double(resolved.opacity)
        let bgLuminance = relativeLuminance(of: background)

        // Determine whether to darken or lighten based on background luminance
        let shouldDarken = bgLuminance > 0.5
        let step = 0.01

        for _ in 0..<200 {
            if shouldDarken {
                r = max(r - step, 0)
                g = max(g - step, 0)
                b = max(b - step, 0)
            } else {
                r = min(r + step, 1)
                g = min(g + step, 1)
                b = min(b + step, 1)
            }
            let candidate = Color(red: r, green: g, blue: b, opacity: a)
            if meetsLevel(level, foreground: candidate, background: background) {
                return candidate
            }
        }

        // Fallback: return black or white depending on background
        return shouldDarken
            ? Color(red: 0, green: 0, blue: 0, opacity: a)
            : Color(red: 1, green: 1, blue: 1, opacity: a)
    }

    public static func relativeLuminance(of color: Color) -> Double {
        let resolved = color.resolve(in: EnvironmentValues())
        let r = linearize(Double(resolved.red))
        let g = linearize(Double(resolved.green))
        let b = linearize(Double(resolved.blue))
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    private static func linearize(_ value: Double) -> Double {
        value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }
}
