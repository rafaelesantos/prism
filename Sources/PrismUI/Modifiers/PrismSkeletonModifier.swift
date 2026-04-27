//
//  PrismSkeletonModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Loading state (skeleton) modifier for the PrismUI Design System.
///
/// `PrismSkeletonModifier` applies a skeleton effect when `isLoading` is active:
/// - Uses `.redacted(reason: .placeholder)` for native effect
/// - `.blurReplace` transition for smooth animation
/// - Animation configured via `theme.animation`
///
/// ## Basic Usage
/// ```swift
/// PrismText("Content")
///     .prismSkeleton()  // Applies skeleton when isLoading = true
/// ```
///
/// ## With Loading State
/// ```swift
/// @State var isLoading = true
/// PrismVStack {
///     PrismText("Title")
///     PrismText("Description")
/// }
/// .prism(loading: isLoading)
/// ```
///
/// - Note: The modifier reads the `\.isLoading` environment to determine the state.
public struct PrismSkeletonModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.isLoading) private var isLoading

    init() {}

    public func body(content: Content) -> some View {
        PrismZStack {
            if isLoading {
                content
                    .redacted(reason: .placeholder)
                    .transition(.blurReplace)
            } else {
                content
                    .transition(.blurReplace)
            }
        }
        .animation(theme.animation, value: isLoading)
    }

    static func mocked() -> some View {
        PrismHStack.mocked()
            .prismSkeleton()
            .prismPadding()
            .prism(loading: true)
    }
}

#Preview {
    PrismSkeletonModifier.mocked()
}
