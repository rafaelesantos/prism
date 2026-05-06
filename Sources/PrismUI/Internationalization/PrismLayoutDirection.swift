import SwiftUI

public enum PrismLayoutDirection: Sendable, CaseIterable {
    case leftToRight
    case rightToLeft
    case auto
}

public enum PrismDirectionalEdge: Sendable, CaseIterable {
    case leading
    case trailing

    public func resolved(for direction: LayoutDirection) -> Edge {
        switch (self, direction) {
        case (.leading, .leftToRight), (.trailing, .rightToLeft):
            return .leading
        case (.trailing, .leftToRight), (.leading, .rightToLeft):
            return .trailing
        @unknown default:
            return .leading
        }
    }
}

// MARK: - View Modifier

extension View {

    public func prismLayoutDirection(_ direction: PrismLayoutDirection) -> some View {
        modifier(PrismLayoutDirectionModifier(direction: direction))
    }
}

private struct PrismLayoutDirectionModifier: ViewModifier {
    let direction: PrismLayoutDirection
    @Environment(\.locale) private var locale

    func body(content: Content) -> some View {
        switch direction {
        case .leftToRight:
            content.environment(\.layoutDirection, .leftToRight)
        case .rightToLeft:
            content.environment(\.layoutDirection, .rightToLeft)
        case .auto:
            content.environment(\.layoutDirection, resolvedDirection)
        }
    }

    private var resolvedDirection: LayoutDirection {
        let language = locale.language.languageCode?.identifier ?? "en"
        let rtlLanguages: Set<String> = ["ar", "he", "fa", "ur", "ps", "sd", "yi", "ku"]
        return rtlLanguages.contains(language) ? .rightToLeft : .leftToRight
    }
}

// MARK: - Bidirectional Stack

public struct PrismBidirectionalStack<Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    private let alignment: VerticalAlignment
    private let spacing: CGFloat?
    private let content: Content

    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: alignment, spacing: spacing) {
            content
        }
        .environment(\.layoutDirection, layoutDirection)
    }
}
