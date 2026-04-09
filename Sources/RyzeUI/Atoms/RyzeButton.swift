//
//  RyzeButton.swift
//  Ryze
//
//  Created by Rafael Escaleira on 18/06/25.
//

import SwiftUI

public struct RyzeButton: RyzeView {
    @Environment(\.theme) var theme

    let role: ButtonRole?
    let action: () async -> Void
    let label: any View

    public var accessibility: RyzeAccessibility?

    public init(
        _ accessibility: RyzeAccessibility? = nil,
        role: ButtonRole? = .none,
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> some View
    ) {
        self.accessibility = accessibility
        self.role = role
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(role: role) {
            #if os(iOS)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            Task { await action() }
        } label: {
            AnyView(label)
        }
        .ryze(accessibility: accessibility)
    }

    public static func mocked() -> some View {
        RyzeButton {

        } label: {
            RyzeText.mocked()
        }
    }
}

#Preview {
    RyzeButton.mocked()
}
