//
//  PrismSizeModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Size modifier for the PrismUI Design System.
///
/// `PrismSizeModifier` applies dimensions using semantic tokens:
/// - Width and height via `PrismSize` tokens
/// - `.max` support for full fill
/// - Configurable alignment
/// - Integration with `theme.size` for consistency
///
/// ## Basic Usage
/// ```swift
/// PrismShape(.circle)
///     .prism(width: .large, height: .large)
/// ```
///
/// ## Maximum Width
/// ```swift
/// PrismTextField(text: $text)
///     .prism(width: .max)  // Takes full available width
/// ```
///
/// ## Fixed Size
/// ```swift
/// PrismSymbol("star")
///     .prism(width: .medium, height: .medium)
/// ```
///
/// ## Available Sizes
/// - `.small`, `.medium`, `.large`, `.extraLarge`, `.extraExtraLarge`
/// - `.max` - Maximum fill
///
/// - Note: The modifier combines multiple `.frame()` calls to properly support `.max`.
public struct PrismSizeModifier: ViewModifier {
    @Environment(\.theme) var theme

    let width: PrismSize?
    let height: PrismSize?
    let alignment: Alignment

    init(width: PrismSize?, height: PrismSize?, alignment: Alignment) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }

    var widthValue: CGFloat? { width?.rawValue(for: theme.size) }
    var heightValue: CGFloat? { height?.rawValue(for: theme.size) }

    public func body(content: Content) -> some View {
        content
            .prism(if: width == .max && height == .max) {
                $0.frame(
                    maxWidth: widthValue,
                    maxHeight: heightValue,
                    alignment: alignment
                )
            }
            .prism(if: width == .max && height != .max) {
                $0.frame(
                    maxWidth: widthValue,
                    alignment: alignment
                ).frame(
                    height: heightValue,
                    alignment: alignment
                )
            }
            .prism(if: width != .max && height == .max) {
                $0.frame(
                    maxHeight: heightValue,
                    alignment: alignment
                ).frame(
                    width: widthValue,
                    alignment: alignment
                )
            }
            .prism(if: width != .max && height != .max) {
                $0.frame(
                    width: widthValue,
                    height: heightValue,
                    alignment: alignment
                )
            }
    }

    static func mocked() -> some View {
        Image(systemName: "square.and.arrow.up")
            .resizable()
            .scaledToFit()
            .prism(width: .medium, height: .medium, alignment: .center)
    }
}

#Preview {
    PrismSizeModifier.mocked()
}
