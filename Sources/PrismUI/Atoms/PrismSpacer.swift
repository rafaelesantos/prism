//
//  PrismSpacer.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/08/25.
//

import PrismFoundation
import SwiftUI

/// Semantic spacer for the PrismUI Design System.
///
/// `PrismSpacer` is a wrapper around the native `Spacer` with:
/// - Configurable minimum length via `PrismSpacing`
/// - Integration with the theme token system
/// - Consistent spacing usage across layouts
///
/// ## Basic Usage
/// ```swift
/// PrismHStack {
///     PrismText("Title")
///     PrismSpacer()  // Flexible spacing
///     PrismSymbol("star")
/// }
/// ```
///
/// ## With Custom Size
/// ```swift
/// PrismVStack {
///     PrismText("Top")
///     PrismSpacer(size: .large)  // Minimum of 24pt
///     PrismText("Bottom")
/// }
/// ```
///
/// ## Available Sizes
/// - `.zero` - No minimum spacing (default)
/// - `.small`, `.medium`, `.large`, `.extraLarge`, etc.
///
/// - Note: The spacer expands to fill available space while respecting the defined minimum.
public struct PrismSpacer: PrismView {
    @Environment(\.theme) var theme

    let size: PrismSpacing?

    public init(size: PrismSpacing? = .zero) {
        self.size = size
    }

    public var body: some View {
        Spacer(minLength: size?.rawValue(for: theme.spacing))
    }

    public static func mocked() -> some View {
        PrismSpacer()
    }
}

#Preview {
    PrismSymbol.mocked()
}
