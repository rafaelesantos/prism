//
//  PrismSymbol.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import PrismFoundation
import SwiftUI

/// SF Symbols icon for the PrismUI Design System.
///
/// `PrismSymbol` is a wrapper around the native `Image(systemName:)` with:
/// - Rendering mode support (monochrome, hierarchical, palette)
/// - Symbol variants (.fill, .circle, .square, etc.)
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
/// - Integration with animated symbol effects
///
/// ## Basic Usage
/// ```swift
/// PrismSymbol("star.fill")
/// ```
///
/// ## With Hierarchical Rendering Mode
/// ```swift
/// PrismSymbol("star.fill", mode: .hierarchical)
///     .prism(color: .primary)
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismSymbol(
///     "person.circle.fill",
///     testID: "profile_icon"
/// )
/// ```
///
/// ## With Animated Effect
/// ```swift
/// PrismSymbol("wifi")
///     .prismSymbol(effect: .variableColor.cumulative)
/// ```
///
/// ## Available Rendering Modes
/// - `.monochrome` - Single color
/// - `.hierarchical` - Color hierarchy based on foregroundStyle
/// - `.palette` - Specific color palette
///
/// ## Available Variants
/// - `.fill`, `.circle`, `.square`, `.slash`, `.crop`, etc.
///
/// - Note: Use `PrismSymbol.mocked()` for previews and unit tests.
public struct PrismSymbol: PrismView {
    @Environment(\.isLoading) var isLoading

    let name: String
    let mode: SymbolRenderingMode
    let variants: SymbolVariants
    public var accessibility: PrismAccessibilityProperties?

    public init(
        _ name: String = "infinity",
        mode: SymbolRenderingMode = .monochrome,
        variants: SymbolVariants = .none,
        accessibility: PrismAccessibilityProperties? = nil
    ) {
        self.name = name
        self.mode = mode
        self.variants = variants
        self.accessibility = accessibility
    }

    public init(
        _ name: String,
        testID: String,
        mode: SymbolRenderingMode = .monochrome,
        variants: SymbolVariants = .none
    ) {
        self.name = name
        self.mode = mode
        self.variants = variants
        self.accessibility = PrismAccessibility.image(LocalizedStringKey(name), testID: testID)
    }

    public var body: some View {
        let content = Image(systemName: name)
            .symbolRenderingMode(mode)
            .symbolVariant(variants)
            .prismSkeleton()

        if let accessibility {
            content.prism(accessibility: accessibility)
        } else {
            content
        }
    }

    public static func mocked() -> some View {
        PrismSymbol(
            "wifi",
            variants: .fill
        )
        .prismSymbol(effect: .variableColor.cumulative.dimInactiveLayers.reversing)
    }
}

#Preview {
    PrismSymbol.mocked()
}
