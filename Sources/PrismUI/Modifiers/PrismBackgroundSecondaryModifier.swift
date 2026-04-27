//
//  PrismBackgroundSecondaryModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Secondary background modifier for the PrismUI Design System.
///
/// `PrismBackgroundSecondaryModifier` applies the secondary background color:
/// - Uses `theme.color.backgroundSecondary` for consistency
/// - Ideal for cards, highlighted sections, or elevated surfaces
/// - Automatic integration with light/dark mode
///
/// ## Basic Usage
/// ```swift
/// PrismVStack {
///     PrismText("Card content")
/// }
/// .prismBackgroundSecondary()
/// ```
///
/// - Note: The secondary background is typically a lighter/darker variation of the primary background.
public struct PrismBackgroundSecondaryModifier: ViewModifier {
    @Environment(\.theme) private var theme

    public func body(content: Content) -> some View {
        content
            .background(theme.color.backgroundSecondary)
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prism(width: .max, height: .max)
            .prismPadding()
            .prismBackgroundSecondary()
    }
}

#Preview {
    PrismBackgroundSecondaryModifier.mocked()
}
