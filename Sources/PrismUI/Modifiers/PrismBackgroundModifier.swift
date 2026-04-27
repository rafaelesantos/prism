//
//  PrismBackgroundModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

/// Default background modifier for the PrismUI Design System.
///
/// `PrismBackgroundModifier` applies the theme background color:
/// - Uses `theme.color.background` for consistency
/// - Automatic integration with light/dark mode
///
/// ## Basic Usage
/// ```swift
/// PrismVStack {
///     PrismText("Content")
/// }
/// .prismBackground()
/// ```
///
/// - Note: Use as the root of screens to ensure consistent background.
public struct PrismBackgroundModifier: ViewModifier {
    @Environment(\.theme) private var theme

    public func body(content: Content) -> some View {
        content
            .background(theme.color.background)
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prism(width: .max, height: .max)
            .prismPadding()
            .prismBackground()
    }
}

#Preview {
    PrismBackgroundModifier.mocked()
}
