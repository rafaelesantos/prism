//
//  RyzeSkeletonModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

struct RyzeSkeletonModifier: RyzeViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.isLoading) private var isLoading

    init() {}

    func body(content: Content) -> some View {
        RyzeZStack {
            if isLoading {
                content
                    .redacted(reason: .placeholder)
                    .transition(.blurReplace)
            } else {
                content
                    .transition(.blurReplace)
            }
        }
        .animation(theme.animation, value: isLoading)
    }

    static func mocked() -> some View {
        RyzeHStack.mocked()
            .ryzeSkeleton()
            .ryzePadding()
            .ryze(loading: true)
    }
}

#Preview {
    RyzeSkeletonModifier.mocked()
}
