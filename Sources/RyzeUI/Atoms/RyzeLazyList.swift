//
//  RyzeLazyList.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

public struct RyzeLazyList: RyzeView {
    @Environment(\.theme) var theme
    let content: any View

    public init(@ViewBuilder content: () -> some View) {
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.medium) {
                AnyView(content)
            }
            .ryzePadding()
        }
    }

    public static func mocked() -> some View {
        RyzeLazyList {
            RyzeText.mocked()
            RyzeHStack.mocked()
            RyzeText.mocked()
            RyzeVStack.mocked()
        }
    }
}

#Preview {
    RyzeLazyList.mocked()
}
