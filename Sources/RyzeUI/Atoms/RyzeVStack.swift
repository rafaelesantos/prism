//
//  RyzeVStack.swift
//  Ryze
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

public struct RyzeVStack: RyzeView {
    @Environment(\.theme) private var theme

    let alignment: HorizontalAlignment
    let spacing: RyzeSpacing?
    let content: any View

    public var accessibility: RyzeAccessibility?

    public init(
        _ accessibility: RyzeAccessibility? = nil,
        alignment: HorizontalAlignment = .center,
        spacing: RyzeSpacing? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.accessibility = accessibility
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(
            alignment: alignment,
            spacing: spacing?.rawValue(for: theme.spacing)
        ) {
            AnyView(content)
        }
        .ryze(accessibility: accessibility)
    }

    public static func mocked() -> some View {
        RyzeVStack(alignment: .leading) {
            RyzeBodyText.mocked()
            RyzeFootnoteText.mocked()
        }
        .ryze(width: .max)
    }
}

#Preview {
    RyzeVStack.mocked()
}
