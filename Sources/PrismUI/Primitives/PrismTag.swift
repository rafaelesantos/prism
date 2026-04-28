import SwiftUI

/// Small badge/chip for status indicators, labels, and categories.
public struct PrismTag: View {
    @Environment(\.prismTheme) private var theme

    private let text: LocalizedStringKey
    private let style: Style
    private let icon: String?

    public init(
        _ text: LocalizedStringKey,
        style: Style = .default,
        icon: String? = nil
    ) {
        self.text = text
        self.style = style
        self.icon = icon
    }

    public var body: some View {
        HStack(spacing: SpacingToken.xs.rawValue) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(TypographyToken.caption.font(weight: .medium))
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, SpacingToken.sm.rawValue)
        .padding(.vertical, SpacingToken.xs.rawValue)
        .background(backgroundColor, in: Capsule())
        .accessibilityElement(children: .combine)
    }

    private var foregroundColor: Color {
        switch style {
        case .default: theme.color(.onBackgroundSecondary)
        case .success: theme.color(.success)
        case .warning: theme.color(.warning)
        case .error: theme.color(.error)
        case .info: theme.color(.info)
        case .brand: theme.color(.onBrand)
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default: theme.color(.surfaceSecondary)
        case .success: theme.color(.success).opacity(0.12)
        case .warning: theme.color(.warning).opacity(0.12)
        case .error: theme.color(.error).opacity(0.12)
        case .info: theme.color(.info).opacity(0.12)
        case .brand: theme.color(.brand)
        }
    }
}

// MARK: - Style

extension PrismTag {

    public enum Style: Sendable {
        case `default`
        case success
        case warning
        case error
        case info
        case brand
    }
}
