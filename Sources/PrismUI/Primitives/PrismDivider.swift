import SwiftUI

/// Themed separator with semantic color and configurable thickness.
public struct PrismDivider: View {
    @Environment(\.prismTheme) private var theme

    private let color: ColorToken
    private let thickness: CGFloat

    public init(
        color: ColorToken = .separator,
        thickness: CGFloat = 0.5
    ) {
        self.color = color
        self.thickness = thickness
    }

    public var body: some View {
        Rectangle()
            .fill(theme.color(color))
            .frame(height: thickness)
            .accessibilityHidden(true)
    }
}
