//
//  PrismBackgroundRowModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 31/07/25.
//

import SwiftUI

/// Row background modifier for the PrismUI Design System.
///
/// `PrismBackgroundRowModifier` applies adaptive background for list rows:
/// - Dark mode: Uses `backgroundSecondary` for contrast
/// - Light mode: Uses default `background`
/// - Ideal for selectable or highlightable rows
///
/// ## Basic Usage
/// ```swift
/// PrismHStack {
///     PrismSymbol("gear")
///     PrismText("Settings")
/// }
/// .prismBackgroundRow()
/// ```
///
/// - Note: The modifier reads `colorScheme` from the environment to determine the appropriate background.
public struct PrismBackgroundRowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        content
            .prism(background: colorScheme == .dark ? .backgroundSecondary : .background)
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prism(width: .max, height: .max)
            .prismPadding()
            .prismBackgroundRow()
    }
}

#Preview {
    PrismBackgroundModifier.mocked()
}
