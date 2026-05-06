import SwiftUI

extension View {

    public func prismAccessibility(
        label: LocalizedStringKey,
        hint: LocalizedStringKey? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        let modified =
            self
            .accessibilityLabel(label)
            .accessibilityAddTraits(traits)

        if let hint {
            return AnyView(modified.accessibilityHint(hint))
        }
        return AnyView(modified)
    }

    public func prismTestID(_ id: String) -> some View {
        accessibilityIdentifier(id)
    }

    public func prismAccessibilityHidden() -> some View {
        accessibilityHidden(true)
    }
}
