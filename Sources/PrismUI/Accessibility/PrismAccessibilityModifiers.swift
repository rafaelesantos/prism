import SwiftUI

extension View {

    public func prismAccessibility(
        label: Text? = nil,
        hint: Text? = nil,
        value: Text? = nil,
        traits: AccessibilityTraits = [],
        isHidden: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label ?? Text(""))
            .accessibilityHint(hint ?? Text(""))
            .accessibilityValue(value ?? Text(""))
            .accessibilityAddTraits(traits)
            .accessibilityHidden(isHidden)
    }

    public func prismAccessibilityHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }

    public func prismAccessibilityGroup(label: Text) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }

    public func prismAccessibilityAction(_ name: Text, action: @escaping () -> Void) -> some View {
        self.accessibilityAction(named: name, action)
    }

    public func prismAccessibilitySortPriority(_ priority: Double) -> some View {
        self.accessibilitySortPriority(priority)
    }

    public static func prismAnnounce(_ message: String) {
        #if canImport(UIKit)
            UIAccessibility.post(notification: .announcement, argument: message)
        #elseif canImport(AppKit)
            NSAccessibility.post(
                element: NSApp as Any, notification: .announcementRequested, userInfo: [.announcement: message])
        #endif
    }
}
