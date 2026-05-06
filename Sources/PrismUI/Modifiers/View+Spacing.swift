import SwiftUI

extension View {

    public func prismPadding(_ token: SpacingToken) -> some View {
        padding(token.rawValue)
    }

    public func prismPadding(_ edges: Edge.Set, _ token: SpacingToken) -> some View {
        padding(edges, token.rawValue)
    }

    public func prismPadding(
        horizontal: SpacingToken,
        vertical: SpacingToken
    ) -> some View {
        padding(.horizontal, horizontal.rawValue)
            .padding(.vertical, vertical.rawValue)
    }

    public func prismSpacing(_ token: SpacingToken) -> some View {
        environment(\.prismStackSpacing, token)
    }
}

// MARK: - Stack Spacing Environment

private struct PrismStackSpacingKey: EnvironmentKey {
    static let defaultValue: SpacingToken = .md
}

extension EnvironmentValues {
    public var prismStackSpacing: SpacingToken {
        get { self[PrismStackSpacingKey.self] }
        set { self[PrismStackSpacingKey.self] = newValue }
    }
}
