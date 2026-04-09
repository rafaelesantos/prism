//
//  RyzeBackgroundRowModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 31/07/25.
//

import SwiftUI

struct RyzeBackgroundRowModifier: RyzeViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .ryze(background: colorScheme == .dark ? .backgroundSecondary : .background)
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryze(width: .max, height: .max)
            .ryzePadding()
            .ryzeBackgroundRow()
    }
}

#Preview {
    RyzeBackgroundModifier.mocked()
}
