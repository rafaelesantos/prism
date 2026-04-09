//
//  RyzeList.swift
//  Ryze
//
//  Created by Rafael Escaleira on 05/06/25.
//

import SwiftUI

public struct RyzeList<SelectionValue: Hashable>: RyzeView {
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
        RyzeList {
            RyzeBodyText.mocked()
            RyzePrimaryButton.mocked()
            RyzeSection.mocked()
            RyzeFootnoteText.mocked()
            RyzeSecondaryButton.mocked()
        }
    }
}

extension RyzeList where SelectionValue == Never {
    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
        self.selection = nil
    }

    public static func mocked() -> some View {
        RyzeList {
            RyzeBodyText.mocked()
            RyzePrimaryButton.mocked()
            RyzeSection.mocked()
            RyzeFootnoteText.mocked()
            RyzeSecondaryButton.mocked()
        }
    }
}

#Preview {
    RyzeList.mocked()
}
