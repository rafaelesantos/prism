//
//  PrismSpacingModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Semantic padding modifier for the PrismUI Design System.
///
/// `PrismSpacingModifier` applies padding using semantic tokens:
/// - Configurable edges (`.all`, `.horizontal`, `.vertical`, etc.)
/// - Spacing via `PrismSpacing` tokens
/// - Integration with `theme.spacing` for consistency
///
/// ## Basic Usage
/// ```swift
/// PrismText("Content")
///     .prismPadding()  // .medium on all sides
/// ```
///
/// ## Horizontal Padding
/// ```swift
/// PrismTextField(text: $text)
///     .prismPadding(.horizontal, .large)
/// ```
///
/// ## Custom Padding
/// ```swift
/// PrismVStack {
///     PrismText("Title")
///     PrismText("Content")
/// }
/// .prismPadding(.all, .extraLarge)
/// ```
///
/// ## Available Tokens
/// - `.zero`, `.small`, `.medium`, `.large`, `.extraLarge`, `.extraExtraLarge`
/// - `.negative(.medium)` - Negative padding (outdent)
///
/// - Note: Use `.negative()` to create overlay effects or compensate for parent padding.
public struct PrismSpacingModifier: ViewModifier {
    @Environment(\.theme) private var theme
    private let edges: Edge.Set
    private let spacing: PrismSpacing

    init(
        edges: Edge.Set,
        spacing: PrismSpacing
    ) {
        self.edges = edges
        self.spacing = spacing
    }

    public func body(content: Content) -> some View {
        content.padding(
            edges,
            spacing.rawValue(for: theme.spacing)
        )
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prismPadding()
    }
}

#Preview {
    PrismSpacingModifier.mocked()
}
