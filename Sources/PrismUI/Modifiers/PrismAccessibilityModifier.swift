//
//  PrismAccessibilityModifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Modifier that applies all accessibility properties in a unified manner.
struct PrismAccessibilityModifier: ViewModifier {
    let properties: PrismAccessibilityProperties

    public func body(content: Content) -> some View {
        let identifiedContent: some View = Group {
            if properties.testID.isEmpty {
                content
            } else {
                content.accessibilityIdentifier(properties.testID)
            }
        }

        let base =
            identifiedContent
            .accessibilityAddTraits(properties.traits)
            .accessibilityValue(properties.value ?? "")
            .accessibilityHidden(properties.isHidden)
            .accessibilityLabel(properties.label)
            .accessibilityHint(properties.hint)

        return properties.actions.reduce(base) { view, action in
            view.accessibilityAction(named: action.name) {
                _ = action.handler()
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// Applies complete accessibility properties to a view.
    ///
    /// - Parameter properties: Accessibility configuration.
    /// - Returns: View modified with all accessibility properties.
    public func prism(accessibility properties: PrismAccessibilityProperties) -> some View {
        modifier(PrismAccessibilityModifier(properties: properties))
    }

    /// Applies accessibility properties using builder pattern.
    ///
    /// - Parameter builder: Closure that configures PrismAccessibilityConfig.
    /// - Returns: View modified with all accessibility properties.
    ///
    /// ## Example:
    /// ```swift
    /// PrismTextField(text: $email)
    ///     .prism(accessibility: {
    ///         $0.label("Email")
    ///             .hint("Digite seu email")
    ///             .testID("email_field")
    ///             .asSearchField()
    ///     })
    /// ```
    public func prism(accessibility builder: (PrismAccessibilityConfig) -> PrismAccessibilityConfig) -> some View {
        let config = builder(PrismAccessibilityConfig())
        return prism(accessibility: config.build())
    }

    /// Shortcut to set only testID.
    public func prism(testID: String) -> some View {
        prism(accessibility: PrismAccessibility.custom(label: "", testID: testID))
    }

    /// Shortcut to set only accessibility label.
    public func prism(accessibilityLabel label: LocalizedStringKey) -> some View {
        prism(accessibility: PrismAccessibility.custom(label: label, testID: ""))
    }

    /// Shortcut to set label and hint.
    public func prism(accessibilityLabel label: LocalizedStringKey, hint: LocalizedStringKey) -> some View {
        prism(accessibility: PrismAccessibility.custom(label: label, testID: "", hint: hint))
    }
}

// MARK: - Accessibility Action Conveniences

extension View {
    /// Adds delete action for accessibility.
    public func prismAccessibilityDelete(handler: @escaping () -> Bool) -> some View {
        accessibilityAction(named: "Delete") {
            _ = handler()
        }
    }

    /// Adds adjust action for accessibility.
    public func prismAccessibilityAdjust(handler: @escaping () -> Bool) -> some View {
        accessibilityAction(named: "Adjust") {
            _ = handler()
        }
    }
}
