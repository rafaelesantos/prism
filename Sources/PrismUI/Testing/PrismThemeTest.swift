import SwiftUI

@MainActor
public enum PrismThemeTest {

    public static func validateAllColors(_ theme: some PrismTheme) -> [ColorToken] {
        ColorToken.allCases.filter { token in
            theme.color(token) == .clear
        }
    }

    public static func validateFeedbackColorsDistinct(_ theme: some PrismTheme) -> Bool {
        let feedbackTokens: [ColorToken] = [.success, .warning, .error, .info]
        let colors = feedbackTokens.map { theme.color($0).description }
        return Set(colors).count == feedbackTokens.count
    }

    public static func validateInteractiveStates(_ theme: some PrismTheme) -> Bool {
        let base = theme.color(.interactive).description
        let hover = theme.color(.interactiveHover).description
        let pressed = theme.color(.interactivePressed).description
        let disabled = theme.color(.interactiveDisabled).description
        return Set([base, hover, pressed, disabled]).count >= 3
    }
}
