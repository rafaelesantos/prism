import SwiftUI

/// Token-based gradient views using theme colors.
///
/// ```swift
/// PrismLinearGradient(from: .brand, to: .interactive)
/// PrismRadialGradient(colors: [.brand, .interactive, .background])
/// ```
public struct PrismLinearGradient: View {
    @Environment(\.prismTheme) private var theme

    private let colors: [ColorToken]
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint

    public init(
        from start: ColorToken,
        to end: ColorToken,
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) {
        self.colors = [start, end]
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    public init(
        colors: [ColorToken],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    public var body: some View {
        LinearGradient(
            colors: colors.map { theme.color($0) },
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

/// Token-based radial gradient.
public struct PrismRadialGradient: View {
    @Environment(\.prismTheme) private var theme

    private let colors: [ColorToken]
    private let center: UnitPoint
    private let startRadius: CGFloat
    private let endRadius: CGFloat

    public init(
        colors: [ColorToken],
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 200
    ) {
        self.colors = colors
        self.center = center
        self.startRadius = startRadius
        self.endRadius = endRadius
    }

    public var body: some View {
        RadialGradient(
            colors: colors.map { theme.color($0) },
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
}

/// Token-based angular gradient.
public struct PrismAngularGradient: View {
    @Environment(\.prismTheme) private var theme

    private let colors: [ColorToken]
    private let center: UnitPoint

    public init(
        colors: [ColorToken],
        center: UnitPoint = .center
    ) {
        self.colors = colors
        self.center = center
    }

    public var body: some View {
        AngularGradient(
            colors: colors.map { theme.color($0) },
            center: center
        )
    }
}

/// Material wrapper with PrismUI token naming.
public enum PrismMaterial: Sendable {
    case ultraThin
    case thin
    case regular
    case thick
    case ultraThick
    case bar

    public var material: Material {
        switch self {
        case .ultraThin: .ultraThinMaterial
        case .thin: .thinMaterial
        case .regular: .regularMaterial
        case .thick: .thickMaterial
        case .ultraThick: .ultraThickMaterial
        case .bar: .bar
        }
    }
}

extension View {

    /// Applies a themed material background.
    public func prismMaterial(_ material: PrismMaterial, in shape: some Shape = Rectangle()) -> some View {
        self.background(material.material, in: shape)
    }
}
