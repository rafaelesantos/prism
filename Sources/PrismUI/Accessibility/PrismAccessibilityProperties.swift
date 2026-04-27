//
//  PrismAccessibilityProperties.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Modern accessibility properties for PrismUI components.
///
/// This struct unifies all accessibility properties into a single type,
/// simplifying UI testing (XCUITest) and VoiceOver/TalkBack support.
///
/// ## Basic Usage:
/// ```swift
/// PrismButton(
///     accessibility: .button(label: "Sign In", testID: "login_button")
/// ) {
///     PrismText("Sign In")
/// }
/// ```
///
/// ## Builder Usage:
/// ```swift
/// PrismTextField(
///     text: $email,
///     accessibility: PrismAccessibilityConfig()
///         .label("Email")
///         .hint("Enter your email")
///         .testID("email_field")
///         .traits([.searchField])
///         .build()
/// )
/// ```
public struct PrismAccessibilityProperties {
    /// Descriptive label for VoiceOver.
    public var label: LocalizedStringKey

    /// Additional hint (optional).
    public var hint: LocalizedStringKey

    /// Stable identifier for XCUITest (non-localizable).
    public var testID: String

    /// Accessibility traits (.button, .header, .image, etc.).
    public var traits: AccessibilityTraits

    /// Custom accessibility actions.
    public var actions: [PrismAccessibilityAction]

    /// Input labels for forms (accessibilityInputLabel).
    public var inputLabels: [LocalizedStringKey]

    /// Current value (for elements that change).
    public var value: LocalizedStringKey?

    /// Whether the element should be hidden from accessibility.
    public var isHidden: Bool

    /// Creates a new set of accessibility properties.
    ///
    /// - Parameters:
    ///   - label: The VoiceOver label.
    ///   - hint: An optional hint. Defaults to an empty string.
    ///   - testID: A stable identifier for XCUITest.
    ///   - traits: Accessibility traits. Defaults to none.
    ///   - actions: Custom accessibility actions. Defaults to an empty array.
    ///   - inputLabels: Input labels for forms. Defaults to an empty array.
    ///   - value: An optional current value string.
    ///   - isHidden: Whether to hide the element from accessibility. Defaults to `false`.
    public init(
        label: LocalizedStringKey,
        hint: LocalizedStringKey = "",
        testID: String,
        traits: AccessibilityTraits = [],
        actions: [PrismAccessibilityAction] = [],
        inputLabels: [LocalizedStringKey] = [],
        value: LocalizedStringKey? = nil,
        isHidden: Bool = false
    ) {
        self.label = label
        self.hint = hint
        self.testID = testID
        self.traits = traits
        self.actions = actions
        self.inputLabels = inputLabels
        self.value = value
        self.isHidden = isHidden
    }
}

/// Custom accessibility action for gestures and special interactions.
public struct PrismAccessibilityAction {
    /// The localized name announced by VoiceOver for this action.
    public let name: LocalizedStringKey
    /// The handler invoked when the action is triggered. Returns `true` if handled.
    public let handler: @Sendable () -> Bool

    /// Creates a custom accessibility action.
    ///
    /// - Parameters:
    ///   - name: The localized action name.
    ///   - handler: A closure that performs the action and returns whether it was handled.
    public init(name: LocalizedStringKey, handler: @Sendable @escaping () -> Bool) {
        self.name = name
        self.handler = handler
    }

    // MARK: - Presets

    /// Creates a "Delete" accessibility action preset.
    public static func delete(handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: "Delete", handler: handler)
    }

    /// Creates an "Adjust" accessibility action preset.
    public static func adjust(handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: "Adjust", handler: handler)
    }

    /// Creates an "Expand" accessibility action preset.
    public static func expand(handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: "Expand", handler: handler)
    }

    /// Creates a "Collapse" accessibility action preset.
    public static func collapse(handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: "Collapse", handler: handler)
    }

    /// Creates a custom-named accessibility action.
    ///
    /// - Parameters:
    ///   - name: The localized action name.
    ///   - handler: A closure that performs the action and returns whether it was handled.
    public static func custom(_ name: LocalizedStringKey, handler: @Sendable @escaping () -> Bool) -> Self {
        Self(name: name, handler: handler)
    }
}

// MARK: - Static Convenience Methods

/// Static factory methods for creating common ``PrismAccessibilityProperties`` configurations.
///
/// Provides presets for buttons, text fields, headers, images, text, groups, and hidden elements.
public enum PrismAccessibility {

    // MARK: - Buttons

    /// Creates accessibility properties configured for a button.
    ///
    /// - Parameters:
    ///   - label: The VoiceOver label describing the button's purpose.
    ///   - testID: A stable identifier for UI testing.
    ///   - hint: An optional hint describing the result of the action.
    /// - Returns: Accessibility properties with the `allowsDirectInteraction` trait.
    public static func button(
        _ label: LocalizedStringKey,
        testID: String,
        hint: LocalizedStringKey? = nil
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            hint: hint ?? "",
            testID: testID,
            traits: [.allowsDirectInteraction]
        )
    }

    // MARK: - Text Fields

    /// Creates accessibility properties configured for a text field.
    ///
    /// - Parameters:
    ///   - label: The VoiceOver label describing the field.
    ///   - testID: A stable identifier for UI testing.
    ///   - hint: An optional hint (e.g., expected format).
    ///   - value: An optional current value to announce.
    /// - Returns: Accessibility properties with the `isStaticText` trait.
    public static func textField(
        _ label: LocalizedStringKey,
        testID: String,
        hint: LocalizedStringKey? = nil,
        value: LocalizedStringKey? = nil
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            hint: hint ?? "",
            testID: testID,
            traits: [.isStaticText],
            value: value
        )
    }

    // MARK: - Headers

    /// Creates accessibility properties configured for a header element.
    ///
    /// - Parameters:
    ///   - label: The VoiceOver label for the header.
    ///   - testID: A stable identifier for UI testing.
    ///   - level: The heading level (reserved for future use). Defaults to `1`.
    /// - Returns: Accessibility properties with the `isHeader` trait.
    public static func header(
        _ label: LocalizedStringKey,
        testID: String,
        level: Int = 1
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            testID: testID,
            traits: [.isHeader]
        )
    }

    // MARK: - Images

    /// Creates accessibility properties configured for an image.
    ///
    /// - Parameters:
    ///   - label: A descriptive VoiceOver label for the image.
    ///   - testID: A stable identifier for UI testing.
    /// - Returns: Accessibility properties with no additional traits.
    public static func image(
        _ label: LocalizedStringKey,
        testID: String
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            testID: testID,
            traits: []
        )
    }

    // MARK: - Text

    /// Creates accessibility properties configured for a text element.
    ///
    /// - Parameters:
    ///   - label: The VoiceOver label.
    ///   - testID: A stable identifier for UI testing.
    ///   - isHeader: Whether the text should be treated as a header. Defaults to `false`.
    /// - Returns: Accessibility properties, optionally with the `isHeader` trait.
    public static func text(
        _ label: LocalizedStringKey,
        testID: String,
        isHeader: Bool = false
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            testID: testID,
            traits: isHeader ? [.isHeader] : []
        )
    }

    // MARK: - Groups

    /// Creates accessibility properties configured for a container/group element.
    ///
    /// - Parameters:
    ///   - testID: A stable identifier for UI testing.
    ///   - label: An optional VoiceOver label for the group.
    /// - Returns: Accessibility properties with no additional traits.
    public static func group(
        testID: String,
        label: LocalizedStringKey? = nil
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label ?? "",
            testID: testID,
            traits: []
        )
    }

    // MARK: - Custom

    /// Creates fully customizable accessibility properties.
    ///
    /// - Parameters:
    ///   - label: The VoiceOver label.
    ///   - testID: A stable identifier for UI testing.
    ///   - hint: An optional hint. Defaults to an empty string.
    ///   - traits: Accessibility traits to apply. Defaults to none.
    /// - Returns: Accessibility properties with the specified configuration.
    public static func custom(
        label: LocalizedStringKey,
        testID: String,
        hint: LocalizedStringKey = "",
        traits: AccessibilityTraits = []
    ) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: label,
            hint: hint,
            testID: testID,
            traits: traits
        )
    }

    // MARK: - Hidden

    /// Creates accessibility properties that hide the element from VoiceOver.
    ///
    /// The `testID` is still set so the element remains findable in UI tests.
    ///
    /// - Parameter testID: A stable identifier for UI testing.
    /// - Returns: Accessibility properties with `isHidden` set to `true`.
    public static func hidden(testID: String) -> PrismAccessibilityProperties {
        PrismAccessibilityProperties(
            label: "",
            testID: testID,
            isHidden: true
        )
    }
}

// MARK: - Preview Support

#if DEBUG
    extension PrismAccessibilityProperties {
        /// A sample accessibility configuration for use in Xcode previews.
        public static var preview: Self {
            PrismAccessibilityProperties(
                label: "Preview Label",
                testID: "preview_test_id"
            )
        }
    }
#endif
