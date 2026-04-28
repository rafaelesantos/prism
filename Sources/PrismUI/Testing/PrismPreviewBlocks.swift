import SwiftUI

/// Collection of preview helpers for rapid visual testing.
///
/// ```swift
/// #Preview("Button Variants") {
///     PrismPreviewBlocks.buttonVariants()
/// }
/// ```
@MainActor
public enum PrismPreviewBlocks {

    /// All button variants in a vertical stack.
    public static func buttonVariants() -> some View {
        VStack(spacing: SpacingToken.md.rawValue) {
            PrismButton("Filled", variant: .filled) {}
            PrismButton("Tinted", variant: .tinted) {}
            PrismButton("Bordered", variant: .bordered) {}
            PrismButton("Plain", variant: .plain) {}
        }
        .padding()
        .prismTheme(DefaultTheme())
    }

    /// Typography scale preview.
    public static func typographyScale() -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            ForEach(TypographyToken.allCases, id: \.self) { token in
                Text(String(describing: token))
                    .font(token.font)
            }
        }
        .padding()
        .prismTheme(DefaultTheme())
    }

    /// Color token swatches.
    public static func colorSwatches() -> some View {
        let theme = DefaultTheme()
        return LazyVGrid(columns: [.init(.adaptive(minimum: 60))], spacing: 8) {
            ForEach(ColorToken.allCases, id: \.self) { token in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.color(token))
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                    Text(token.rawValue)
                        .font(.system(size: 8))
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .prismTheme(theme)
    }

    /// Spacing token visualization.
    public static func spacingScale() -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            ForEach(SpacingToken.allCases, id: \.self) { token in
                HStack {
                    Text(String(describing: token))
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: token.rawValue, height: 16)
                    Text("\(Int(token.rawValue))pt")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    /// All themes side by side on a card.
    public static func themeComparison() -> some View {
        HStack(spacing: SpacingToken.md.rawValue) {
            themeCard(DefaultTheme(), name: "Default")
            themeCard(DarkTheme(), name: "Dark")
            themeCard(HighContrastTheme(), name: "High Contrast")
        }
        .padding()
    }

    private static func themeCard<T: PrismTheme>(_ theme: T, name: String) -> some View {
        VStack(spacing: SpacingToken.sm.rawValue) {
            Text(name)
                .font(TypographyToken.headline.font)
                .foregroundStyle(theme.color(.onBackground))
            PrismButton("Action", variant: .filled) {}
            PrismCard {
                Text("Card content")
                    .font(TypographyToken.body.font)
                    .foregroundStyle(theme.color(.onSurface))
            }
        }
        .padding()
        .background(theme.color(.background))
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.lg.rawValue))
        .prismTheme(theme)
    }

    /// Radius token visualization.
    public static func radiusScale() -> some View {
        HStack(spacing: SpacingToken.md.rawValue) {
            ForEach(RadiusToken.allCases, id: \.self) { token in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: token.rawValue)
                        .fill(Color.accentColor.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: token.rawValue)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                    Text(String(describing: token))
                        .font(.system(size: 9))
                }
            }
        }
        .padding()
    }
}
