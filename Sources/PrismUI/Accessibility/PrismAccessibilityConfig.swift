//
//  PrismAccessibilityConfig.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Fluent builder for creating accessibility properties.
///
/// ## Usage Example:
/// ```swift
/// PrismTextField(
///     text: $email,
///     accessibility: PrismAccessibilityConfig()
///         .label("Email")
///         .hint("Enter your corporate email")
///         .testID("email_field")
///         .traits([.searchField, .updatesFrequently])
///         .build()
/// )
/// ```
public struct PrismAccessibilityConfig {
    private var label: LocalizedStringKey = ""
    private var hint: LocalizedStringKey = ""
    private var testID: String = ""
    private var traits: AccessibilityTraits = []
    private var actions: [PrismAccessibilityAction] = []
    private var inputLabels: [LocalizedStringKey] = []
    private var value: LocalizedStringKey?
    private var isHidden: Bool = false

    /// Creates an empty accessibility configuration builder.
    public init() {}

    // MARK: - Required

    /// Sets the VoiceOver label.
    ///
    /// - Parameter label: The localized accessibility label.
    /// - Returns: The updated configuration.
    @discardableResult
    public func label(_ label: LocalizedStringKey) -> Self {
        var copy = self
        copy.label = label
        return copy
    }

    /// Sets the stable test identifier for XCUITest.
    ///
    /// - Parameter testID: A non-localized identifier string.
    /// - Returns: The updated configuration.
    @discardableResult
    public func testID(_ testID: String) -> Self {
        var copy = self
        copy.testID = testID
        return copy
    }

    // MARK: - Optional

    /// Sets an additional VoiceOver hint describing the result of interacting with the element.
    ///
    /// - Parameter hint: The localized accessibility hint.
    /// - Returns: The updated configuration.
    @discardableResult
    public func hint(_ hint: LocalizedStringKey) -> Self {
        var copy = self
        copy.hint = hint
        return copy
    }

    /// Sets the accessibility traits for the element.
    ///
    /// - Parameter traits: The traits to apply (e.g., `.isButton`, `.isHeader`).
    /// - Returns: The updated configuration.
    @discardableResult
    public func traits(_ traits: AccessibilityTraits) -> Self {
        var copy = self
        copy.traits = traits
        return copy
    }

    /// Sets one or more accessibility traits using a variadic parameter.
    ///
    /// - Parameter traits: The traits to apply.
    /// - Returns: The updated configuration.
    @discardableResult
    public func traits(_ traits: AccessibilityTraits...) -> Self {
        var copy = self
        copy.traits = AccessibilityTraits(traits)
        return copy
    }

    /// Appends a single custom accessibility action.
    ///
    /// - Parameter action: The action to add.
    /// - Returns: The updated configuration.
    @discardableResult
    public func action(_ action: PrismAccessibilityAction) -> Self {
        var copy = self
        copy.actions.append(action)
        return copy
    }

    /// Appends multiple custom accessibility actions.
    ///
    /// - Parameter actions: An array of actions to add.
    /// - Returns: The updated configuration.
    @discardableResult
    public func actions(_ actions: [PrismAccessibilityAction]) -> Self {
        var copy = self
        copy.actions.append(contentsOf: actions)
        return copy
    }

    /// Sets the accessibility input labels for form elements.
    ///
    /// - Parameter labels: An array of localized input labels.
    /// - Returns: The updated configuration.
    @discardableResult
    public func inputLabels(_ labels: [LocalizedStringKey]) -> Self {
        var copy = self
        copy.inputLabels = labels
        return copy
    }

    /// Appends a single accessibility input label.
    ///
    /// - Parameter label: A localized input label.
    /// - Returns: The updated configuration.
    @discardableResult
    public func inputLabel(_ label: LocalizedStringKey) -> Self {
        var copy = self
        copy.inputLabels.append(label)
        return copy
    }

    /// Sets the current accessibility value for elements that change (e.g., sliders, toggles).
    ///
    /// - Parameter value: The localized current value string.
    /// - Returns: The updated configuration.
    @discardableResult
    public func value(_ value: LocalizedStringKey) -> Self {
        var copy = self
        copy.value = value
        return copy
    }

    /// Sets whether the element should be hidden from assistive technologies.
    ///
    /// - Parameter isHidden: `true` to hide the element from VoiceOver.
    /// - Returns: The updated configuration.
    @discardableResult
    public func isHidden(_ isHidden: Bool) -> Self {
        var copy = self
        copy.isHidden = isHidden
        return copy
    }

    // MARK: - Convenience

    /// Adds the `allowsDirectInteraction` trait, marking the element as a button.
    ///
    /// - Returns: The updated configuration.
    @discardableResult
    public func asButton() -> Self {
        var copy = self
        copy.traits.formUnion(.allowsDirectInteraction)
        return copy
    }

    /// Adds the `isHeader` trait, marking the element as a section header.
    ///
    /// - Parameter level: The heading level (reserved for future use). Defaults to `1`.
    /// - Returns: The updated configuration.
    @discardableResult
    public func asHeader(_ level: Int = 1) -> Self {
        var copy = self
        copy.traits.formUnion(.isHeader)
        return copy
    }

    /// Adds the `isImage` trait, marking the element as an image.
    ///
    /// - Returns: The updated configuration.
    @discardableResult
    public func asImage() -> Self {
        var copy = self
        copy.traits.formUnion(.isImage)
        return copy
    }

    /// Adds the `isStaticText` trait, marking the element as a search field.
    ///
    /// - Returns: The updated configuration.
    @discardableResult
    public func asSearchField() -> Self {
        var copy = self
        copy.traits.formUnion(.isStaticText)
        return copy
    }

    /// Adds the `updatesFrequently` trait, marking the element as adjustable.
    ///
    /// - Returns: The updated configuration.
    @discardableResult
    public func asAdjustable() -> Self {
        var copy = self
        copy.traits.formUnion(.updatesFrequently)
        return copy
    }

    /// Adds the `updatesFrequently` trait for elements whose value changes often (e.g., timers).
    ///
    /// - Returns: The updated configuration.
    @discardableResult
    public func updatesFrequently() -> Self {
        var copy = self
        copy.traits.formUnion(.updatesFrequently)
        return copy
    }

    // MARK: - Build

    /// Builds the final ``PrismAccessibilityProperties`` from the accumulated configuration.
    ///
    /// - Returns: A fully configured ``PrismAccessibilityProperties`` instance.
    public func build() -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            hint: hint,
            testID: testID,
            traits: traits,
            actions: actions,
            inputLabels: inputLabels,
            value: value,
            isHidden: isHidden
        )
    }
}

// MARK: - Result Builder

/// A result builder for declaratively composing arrays of ``PrismAccessibilityProperties``.
@resultBuilder
public enum PrismAccessibilityBuilder {
    /// Combines multiple accessibility properties into an array.
    public static func buildBlock(_ components: PrismAccessibilityProperties...) -> [PrismAccessibilityProperties] {
        components
    }

    /// Supports optional accessibility properties within the builder.
    public static func buildOptional(_ component: PrismAccessibilityProperties?) -> PrismAccessibilityProperties? {
        component
    }

    /// Supports the first branch of an `if-else` within the builder.
    public static func buildEither(first component: PrismAccessibilityProperties) -> PrismAccessibilityProperties {
        component
    }

    /// Supports the second branch of an `if-else` within the builder.
    public static func buildEither(second component: PrismAccessibilityProperties) -> PrismAccessibilityProperties {
        component
    }

    /// Supports `for-in` loops within the builder.
    public static func buildArray(_ components: [PrismAccessibilityProperties]) -> [PrismAccessibilityProperties] {
        components
    }
}
