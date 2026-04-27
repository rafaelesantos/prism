//
//  PrismList.swift
//  Prism
//
//  Created by Rafael Escaleira on 05/06/25.
//

import SwiftUI

/// Row list for the PrismUI Design System.
///
/// `PrismList` is a wrapper around the native `List` with:
/// - Optional multiple selection support
/// - Integration with `PrismSection` for grouping
/// - Consistent Design System styling
///
/// ## Basic Usage
/// ```swift
/// PrismList {
///     PrismSection {
///         PrismBodyText("Item 1")
///         PrismBodyText("Item 2")
///     }
/// }
/// ```
///
/// ## With Selection
/// ```swift
/// @State var selected: Set<String> = []
/// PrismList(selection: $selected) {
///     PrismBodyText("Item 1")
///         .tag("item1")
///     PrismBodyText("Item 2")
///         .tag("item2")
/// }
/// ```
///
/// - Note: Use `PrismSection` inside the list to group content with header/footer.
public struct PrismList<SelectionValue: Hashable>: PrismView {
    let content: any View
    let selection: Binding<Set<SelectionValue>>?

    public init(
        selection: Binding<Set<SelectionValue>>? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.content = content()
        self.selection = selection
    }

    public var body: some View {
        List(selection: selection) {
            AnyView(content)
        }
    }

    public static func mocked() -> some View {
        PrismList {
            PrismBodyText.mocked()
            PrismPrimaryButton.mocked()
            PrismSection.mocked()
            PrismFootnoteText.mocked()
            PrismSecondaryButton.mocked()
        }
    }
}

extension PrismList where SelectionValue == Never {
    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
        self.selection = nil
    }

    public static func mocked() -> some View {
        PrismList {
            PrismBodyText.mocked()
            PrismPrimaryButton.mocked()
            PrismSection.mocked()
            PrismFootnoteText.mocked()
            PrismSecondaryButton.mocked()
        }
    }
}

#Preview {
    PrismList.mocked()
}
