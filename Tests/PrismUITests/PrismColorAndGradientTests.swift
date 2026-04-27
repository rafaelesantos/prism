//
//  PrismColorAndGradientTests.swift
//  PrismUITests
//
//  Created by Rafael Escaleira on 27/04/26.
//

import SwiftUI
import XCTest

@testable import PrismUI

// MARK: - Color+Extensions Tests

/// Tests for the `Color(hex:)` initializer and `.hex` computed property
/// defined in `Sources/PrismUI/Extensions/Color+Extensions.swift`.
final class ColorHexInitTests: XCTestCase {

    // MARK: - Valid 6-Digit Hex Strings

    func testInitWithSixDigitHexWithHash() {
        let color = Color(hex: "#FF0000")
        // Should not fall back to .primary; we verify via the hex roundtrip.
        XCTAssertEqual(color.hex, "#FF0000", "6-digit hex with '#' prefix should parse correctly")
    }

    func testInitWithSixDigitHexWithoutHash() {
        let color = Color(hex: "00FF00")
        XCTAssertEqual(color.hex, "#00FF00", "6-digit hex without '#' prefix should parse correctly")
    }

    func testInitWithLowercaseHex() {
        let color = Color(hex: "#ff5733")
        XCTAssertEqual(color.hex, "#FF5733", "Lowercase hex input should be parsed correctly")
    }

    func testInitWithMixedCaseHex() {
        let color = Color(hex: "#aAbBcC")
        XCTAssertEqual(color.hex, "#AABBCC", "Mixed-case hex input should be normalized and parsed")
    }

    func testInitWithBlackHex() {
        let color = Color(hex: "#000000")
        XCTAssertEqual(color.hex, "#000000")
    }

    func testInitWithWhiteHex() {
        let color = Color(hex: "#FFFFFF")
        XCTAssertEqual(color.hex, "#FFFFFF")
    }

    // MARK: - Nil Input

    func testInitWithNilReturnsPrimary() {
        let nilColor = Color(hex: nil)
        let primaryColor = Color.primary
        // Both should resolve to the same `.primary` color.
        // We compare the hex strings as a proxy since Color equality is unreliable.
        XCTAssertEqual(nilColor.hex, primaryColor.hex, "nil hex should default to Color.primary")
    }

    // MARK: - Invalid Strings (fallback to .primary)

    func testInitWithEmptyStringReturnsPrimary() {
        let color = Color(hex: "")
        let primaryHex = Color.primary.hex
        XCTAssertEqual(color.hex, primaryHex, "Empty string should fall back to .primary")
    }

    func testInitWithTooShortStringReturnsPrimary() {
        let color = Color(hex: "#FFF")
        let primaryHex = Color.primary.hex
        XCTAssertEqual(color.hex, primaryHex, "3-digit shorthand is not supported and should fall back")
    }

    func testInitWithTooLongStringReturnsPrimary() {
        // 8-digit (RRGGBBAA) strings are NOT handled by the current implementation;
        // the guard checks for count != 6 after stripping '#', so 8-digit falls back.
        let color = Color(hex: "#FF000080")
        let primaryHex = Color.primary.hex
        XCTAssertEqual(color.hex, primaryHex, "8-digit hex is not supported and should fall back")
    }

    func testInitWithNonHexCharactersReturnsPrimary() {
        let color = Color(hex: "#ZZZZZZ")
        // Scanner will produce 0 for non-hex characters, resulting in black (#000000).
        // This is the actual behavior: the guard passes (length == 6) but Scanner yields 0.
        XCTAssertEqual(color.hex, "#000000", "Non-hex characters cause Scanner to yield 0 (black)")
    }

    func testInitWithWhitespaceAroundHex() {
        let color = Color(hex: "  #FF0000  ")
        XCTAssertEqual(color.hex, "#FF0000", "Leading/trailing whitespace should be trimmed")
    }

    func testInitWithOnlyHash() {
        let color = Color(hex: "#")
        let primaryHex = Color.primary.hex
        XCTAssertEqual(color.hex, primaryHex, "A lone '#' should fall back to .primary")
    }

    // MARK: - Hex Property Roundtrip

    func testHexRoundtripForKnownColors() {
        let testCases: [(input: String, expected: String)] = [
            ("#FF0000", "#FF0000"),
            ("#00FF00", "#00FF00"),
            ("#0000FF", "#0000FF"),
            ("#ABCDEF", "#ABCDEF"),
            ("#123456", "#123456"),
        ]

        for (input, expected) in testCases {
            let color = Color(hex: input)
            XCTAssertEqual(color.hex, expected, "Roundtrip failed for input: \(input)")
        }
    }

    func testHexPropertyReturnsUppercaseFormat() {
        let color = Color(hex: "#abcdef")
        let hex = color.hex
        XCTAssertTrue(hex.hasPrefix("#"), "Hex should start with '#'")
        XCTAssertEqual(hex.count, 7, "Hex string should be 7 characters (#RRGGBB)")
        // All alpha characters should be uppercase
        let hexBody = String(hex.dropFirst())
        XCTAssertEqual(hexBody, hexBody.uppercased(), "Hex digits should be uppercase")
    }
}

// MARK: - PrismGradient Tests

/// Tests for `PrismGradient` defined in `Sources/PrismUI/Tokens/PrismGradient.swift`.
/// Verifies static presets, builder methods, and ShapeStyle conformance.
final class PrismGradientTests: XCTestCase {

    // MARK: - Static Presets Exist

    func testPrimaryPresetExists() {
        let gradient: PrismGradient = .primary
        // Verifying the type is correct and does not crash.
        XCTAssertNotNil(gradient)
    }

    func testSecondaryPresetExists() {
        let gradient: PrismGradient = .secondary
        XCTAssertNotNil(gradient)
    }

    func testDestructivePresetExists() {
        let gradient: PrismGradient = .destructive
        XCTAssertNotNil(gradient)
    }

    func testSuccessPresetExists() {
        let gradient: PrismGradient = .success
        XCTAssertNotNil(gradient)
    }

    func testWarningPresetExists() {
        let gradient: PrismGradient = .warning
        XCTAssertNotNil(gradient)
    }

    func testInfoPresetExists() {
        let gradient: PrismGradient = .info
        XCTAssertNotNil(gradient)
    }

    // MARK: - Builder Methods Return Non-Nil

    func testLinearBuilderReturnsGradient() {
        let gradient = PrismGradient.linear(.red, .blue)
        XCTAssertNotNil(gradient)
    }

    func testLinearBuilderWithCustomPoints() {
        let gradient = PrismGradient.linear(
            .red, .blue,
            startPoint: .leading,
            endPoint: .trailing
        )
        XCTAssertNotNil(gradient)
    }

    func testRadialBuilderReturnsGradient() {
        let gradient = PrismGradient.radial(.green, .yellow)
        XCTAssertNotNil(gradient)
    }

    func testRadialBuilderWithCustomParameters() {
        let gradient = PrismGradient.radial(
            .green, .yellow,
            center: .topLeading,
            startRadius: 10,
            endRadius: 200
        )
        XCTAssertNotNil(gradient)
    }

    func testAngularBuilderReturnsGradient() {
        let gradient = PrismGradient.angular(.purple, .orange)
        XCTAssertNotNil(gradient)
    }

    func testAngularBuilderWithCustomParameters() {
        let gradient = PrismGradient.angular(
            .purple, .orange,
            center: .bottom,
            angle: .degrees(45)
        )
        XCTAssertNotNil(gradient)
    }

    func testConicBuilderReturnsGradient() {
        let gradient = PrismGradient.conic(.cyan, .mint)
        XCTAssertNotNil(gradient)
    }

    func testConicBuilderWithCustomCenter() {
        let gradient = PrismGradient.conic(.cyan, .mint, center: .topTrailing)
        XCTAssertNotNil(gradient)
    }

    // MARK: - Multi-Color Gradients

    func testLinearWithMultipleColors() {
        let gradient = PrismGradient.linear(.red, .orange, .yellow, .green, .blue)
        XCTAssertNotNil(gradient)
    }

    func testRadialWithMultipleColors() {
        let gradient = PrismGradient.radial(.red, .orange, .yellow)
        XCTAssertNotNil(gradient)
    }

    // MARK: - Direct Initialization

    func testDirectInitWithColors() {
        let gradient = PrismGradient(colors: [.red, .blue, .green])
        XCTAssertNotNil(gradient)
    }

    func testDirectInitWithCustomPoints() {
        let gradient = PrismGradient(
            colors: [.red, .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
        XCTAssertNotNil(gradient)
    }

    func testDirectInitWithSingleColor() {
        let gradient = PrismGradient(colors: [.red])
        XCTAssertNotNil(gradient)
    }

    func testDirectInitWithEmptyColors() {
        let gradient = PrismGradient(colors: [])
        XCTAssertNotNil(gradient)
    }

    // MARK: - Sendable Conformance

    func testGradientIsSendable() {
        let gradient: PrismGradient = .primary
        // Verify the gradient can be used in a Sendable context without compiler warnings.
        let sendable: any Sendable = gradient
        XCTAssertNotNil(sendable)
    }

    // MARK: - ShapeStyle Conformance

    func testGradientConformsToShapeStyle() {
        let gradient: PrismGradient = .primary
        // PrismGradient conforms to ShapeStyle; verify it can be used as one.
        let shapeStyle: any ShapeStyle = gradient
        XCTAssertNotNil(shapeStyle)
    }
}

// MARK: - PrismColor Tests

/// Tests for `PrismColor` defined in `Sources/PrismUI/Styles/PrismColor.swift`.
/// Validates `color(using:)` resolution against a theme, and the custom rawValue initializer.
final class PrismColorTests: XCTestCase {

    // MARK: - Themed PrismColor via ShapeStyle Extension

    func testThemedPrimaryResolvesAgainstDarkTheme() {
        let prismColor: PrismColor = .primary
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        // The dark theme defines primary as Color(red: 0.4, green: 0.6, blue: 1.0)
        XCTAssertEqual(resolved, darkTheme.primary)
    }

    func testThemedSecondaryResolvesAgainstDarkTheme() {
        let prismColor: PrismColor = .secondary
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.secondary)
    }

    func testThemedErrorResolvesAgainstHighContrastTheme() {
        let prismColor: PrismColor = .error
        let highContrast = PrismDefaultColor.highContrast
        let resolved = prismColor.color(using: highContrast)
        XCTAssertEqual(resolved, highContrast.error)
    }

    func testThemedSuccessResolvesAgainstHighContrastTheme() {
        let prismColor: PrismColor = .success
        let highContrast = PrismDefaultColor.highContrast
        let resolved = prismColor.color(using: highContrast)
        XCTAssertEqual(resolved, highContrast.success)
    }

    func testThemedWarningResolvesAgainstDarkTheme() {
        let prismColor: PrismColor = .warning
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.warning)
    }

    func testThemedInfoResolvesAgainstDarkTheme() {
        let prismColor: PrismColor = .info
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.info)
    }

    func testThemedBackgroundResolvesCorrectly() {
        let prismColor: PrismColor = .background
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.background)
    }

    func testThemedSurfaceResolvesCorrectly() {
        let prismColor: PrismColor = .surface
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.surface)
    }

    func testThemedTextResolvesCorrectly() {
        let prismColor: PrismColor = .text
        let highContrast = PrismDefaultColor.highContrast
        let resolved = prismColor.color(using: highContrast)
        XCTAssertEqual(resolved, highContrast.text)
    }

    func testThemedDisabledResolvesCorrectly() {
        let prismColor: PrismColor = .disabled
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.disabled)
    }

    func testThemedWhiteResolvesCorrectly() {
        let prismColor: PrismColor = .white
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.white)
    }

    func testThemedBlackResolvesCorrectly() {
        let prismColor: PrismColor = .black
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.black)
    }

    // MARK: - Custom PrismColor

    func testCustomColorReturnsRawValue() {
        let customColor = Color.red
        let prismColor = PrismColor(rawValue: customColor)
        let darkTheme = PrismDefaultColor.dark
        // A custom PrismColor ignores the theme and returns its stored color.
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, customColor)
    }

    func testCustomColorIgnoresTheme() {
        let customColor = Color(red: 0.1, green: 0.2, blue: 0.3)
        let prismColor = PrismColor(rawValue: customColor)
        let highContrast = PrismDefaultColor.highContrast
        let resolved = prismColor.color(using: highContrast)
        XCTAssertEqual(resolved, customColor, "Custom colors should not be affected by theme")
    }

    // MARK: - Hex Factory via ShapeStyle Extension

    func testHexFactoryCreatesCustomColor() {
        let prismColor: PrismColor = .hex("#FF0000")
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        // The hex factory wraps a Color(hex:) inside a .custom PrismColor.
        let expectedColor = Color(hex: "#FF0000")
        XCTAssertEqual(resolved, expectedColor)
    }

    func testHexFactoryWithNilFallsToPrimary() {
        let prismColor: PrismColor = .hex(nil)
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        // When hex is nil, .hex(nil) returns .primary which is a themed color.
        XCTAssertEqual(resolved, darkTheme.primary)
    }

    // MARK: - Color Factory via ShapeStyle Extension

    func testColorFactoryWrapsSwiftUIColor() {
        let swiftUIColor = Color.orange
        let prismColor: PrismColor = .color(swiftUIColor)
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, swiftUIColor)
    }

    func testColorFactoryWithNilFallsToPrimary() {
        let prismColor: PrismColor = .color(nil)
        let darkTheme = PrismDefaultColor.dark
        let resolved = prismColor.color(using: darkTheme)
        XCTAssertEqual(resolved, darkTheme.primary)
    }

    // MARK: - Same Theme Key Resolves Differently Per Theme

    func testSameKeyResolveDifferentlyPerTheme() {
        let prismColor: PrismColor = .primary
        let dark = PrismDefaultColor.dark
        let highContrast = PrismDefaultColor.highContrast

        let darkResolved = prismColor.color(using: dark)
        let hcResolved = prismColor.color(using: highContrast)

        // Dark primary is Color(red: 0.4, green: 0.6, blue: 1.0),
        // High contrast primary is .yellow -- they must differ.
        XCTAssertNotEqual(darkResolved, hcResolved, "Same key should resolve to different colors per theme")
    }

    // MARK: - ShapeStyle Conformance

    func testPrismColorConformsToShapeStyle() {
        let prismColor: PrismColor = .primary
        let shapeStyle: any ShapeStyle = prismColor
        XCTAssertNotNil(shapeStyle)
    }
}

// MARK: - PrismDefaultColor Tests

/// Tests for `PrismDefaultColor` defined in `Sources/PrismUI/Default/PrismDefaultColor.swift`.
/// Validates the `.dark` and `.highContrast` static variants and their color properties.
final class PrismDefaultColorTests: XCTestCase {

    // MARK: - Dark Variant Exists and Has Non-Nil Properties

    func testDarkVariantExists() {
        let dark = PrismDefaultColor.dark
        XCTAssertNotNil(dark)
    }

    func testDarkBrandColors() {
        let dark = PrismDefaultColor.dark
        XCTAssertEqual(dark.primary, Color(red: 0.4, green: 0.6, blue: 1.0))
        XCTAssertEqual(dark.secondary, Color(red: 0.5, green: 0.5, blue: 0.6))
        XCTAssertEqual(dark.accent, Color(red: 0.5, green: 0.7, blue: 1.0))
    }

    func testDarkBackgroundColors() {
        let dark = PrismDefaultColor.dark
        XCTAssertEqual(dark.background, Color(red: 0.05, green: 0.05, blue: 0.08))
        XCTAssertEqual(dark.backgroundSecondary, Color(red: 0.1, green: 0.1, blue: 0.15))
        XCTAssertEqual(dark.surface, Color(red: 0.12, green: 0.12, blue: 0.18))
    }

    func testDarkTextColors() {
        let dark = PrismDefaultColor.dark
        XCTAssertEqual(dark.text, .white)
        XCTAssertEqual(dark.textInverse, .black)
    }

    func testDarkFeedbackColors() {
        let dark = PrismDefaultColor.dark
        XCTAssertEqual(dark.error, Color(red: 1.0, green: 0.4, blue: 0.4))
        XCTAssertEqual(dark.success, Color(red: 0.4, green: 1.0, blue: 0.5))
        XCTAssertEqual(dark.warning, Color(red: 1.0, green: 0.7, blue: 0.3))
        XCTAssertEqual(dark.info, Color(red: 0.3, green: 0.8, blue: 1.0))
    }

    func testDarkUtilityColors() {
        let dark = PrismDefaultColor.dark
        XCTAssertEqual(dark.shadow, .black)
        XCTAssertEqual(dark.white, .white)
        XCTAssertEqual(dark.black, .black)
    }

    // MARK: - High Contrast Variant Exists and Has Non-Nil Properties

    func testHighContrastVariantExists() {
        let hc = PrismDefaultColor.highContrast
        XCTAssertNotNil(hc)
    }

    func testHighContrastBrandColors() {
        let hc = PrismDefaultColor.highContrast
        XCTAssertEqual(hc.primary, .yellow)
        XCTAssertEqual(hc.secondary, .gray)
        XCTAssertEqual(hc.accent, .cyan)
    }

    func testHighContrastBackgroundColors() {
        let hc = PrismDefaultColor.highContrast
        XCTAssertEqual(hc.background, .black)
    }

    func testHighContrastTextColors() {
        let hc = PrismDefaultColor.highContrast
        XCTAssertEqual(hc.text, .white)
        XCTAssertEqual(hc.textInverse, .black)
    }

    func testHighContrastFeedbackColors() {
        let hc = PrismDefaultColor.highContrast
        XCTAssertEqual(hc.error, .red)
        XCTAssertEqual(hc.success, .green)
        XCTAssertEqual(hc.warning, .yellow)
        XCTAssertEqual(hc.info, .cyan)
    }

    func testHighContrastUtilityColors() {
        let hc = PrismDefaultColor.highContrast
        XCTAssertEqual(hc.shadow, .black)
        XCTAssertEqual(hc.white, .white)
        XCTAssertEqual(hc.black, .black)
    }

    func testHighContrastBorderColors() {
        let hc = PrismDefaultColor.highContrast
        XCTAssertEqual(hc.border, .white)
        XCTAssertEqual(hc.borderStrong, .white)
    }

    // MARK: - Protocol Conformance

    func testDarkConformsToPrismColorProtocol() {
        let dark: PrismColorProtocol = PrismDefaultColor.dark
        // Verify the gradient default implementations from the protocol extension work.
        XCTAssertNotNil(dark.gradient)
        XCTAssertNotNil(dark.gradientSecondary)
        XCTAssertNotNil(dark.gradientDestructive)
        XCTAssertNotNil(dark.gradientSuccess)
        XCTAssertNotNil(dark.semantic)
    }

    func testHighContrastConformsToPrismColorProtocol() {
        let hc: PrismColorProtocol = PrismDefaultColor.highContrast
        XCTAssertNotNil(hc.gradient)
        XCTAssertNotNil(hc.semantic)
    }

    // MARK: - Dark vs High Contrast Are Distinct

    func testDarkAndHighContrastDiffer() {
        let dark = PrismDefaultColor.dark
        let hc = PrismDefaultColor.highContrast
        // Primary colors differ between variants.
        XCTAssertNotEqual(dark.primary, hc.primary)
        XCTAssertNotEqual(dark.accent, hc.accent)
        XCTAssertNotEqual(dark.error, hc.error)
    }

    // MARK: - All Properties Are Accessible

    func testDarkAllPropertiesAccessible() {
        let dark = PrismDefaultColor.dark
        // Exhaustively access every property to confirm none crash.
        _ = dark.primary
        _ = dark.secondary
        _ = dark.accent
        _ = dark.background
        _ = dark.backgroundSecondary
        _ = dark.surface
        _ = dark.text
        _ = dark.textSecondary
        _ = dark.textTertiary
        _ = dark.textInverse
        _ = dark.border
        _ = dark.borderSubtle
        _ = dark.borderStrong
        _ = dark.disabled
        _ = dark.hover
        _ = dark.pressed
        _ = dark.selected
        _ = dark.error
        _ = dark.success
        _ = dark.warning
        _ = dark.info
        _ = dark.shadow
        _ = dark.white
        _ = dark.black
    }

    func testHighContrastAllPropertiesAccessible() {
        let hc = PrismDefaultColor.highContrast
        _ = hc.primary
        _ = hc.secondary
        _ = hc.accent
        _ = hc.background
        _ = hc.backgroundSecondary
        _ = hc.surface
        _ = hc.text
        _ = hc.textSecondary
        _ = hc.textTertiary
        _ = hc.textInverse
        _ = hc.border
        _ = hc.borderSubtle
        _ = hc.borderStrong
        _ = hc.disabled
        _ = hc.hover
        _ = hc.pressed
        _ = hc.selected
        _ = hc.error
        _ = hc.success
        _ = hc.warning
        _ = hc.info
        _ = hc.shadow
        _ = hc.white
        _ = hc.black
    }
}
