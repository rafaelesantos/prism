//
//  RyzePrimaryButton.swift
//  Ryze
//
//  Created by Rafael Escaleira on 29/06/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzePrimaryButton: RyzeView {
    @Environment(\.theme) var theme

    let text: String?
    let role: ButtonRole?
    let action: () -> Void

    public var accessibility: RyzeAccessibility?

    public init(
        _ text: String?,
        _ accessibility: RyzeAccessibility? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.accessibility = accessibility
        self.role = role
        self.action = action
    }

    public init(
        _ localized: RyzeResourceString?,
        _ accessibility: RyzeAccessibility? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.text = localized?.value
        self.accessibility = accessibility
        self.role = role
        self.action = action
    }

    var tint: RyzeColor {
        switch role {
        case .destructive: return .error
        default: return .primary
        }
    }

    public var body: some View {
        RyzeButton(
            accessibility,
            role: role,
            action: action
        ) {
            RyzeText(text)
        }
        .ryze(tint: tint)
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .buttonBorderShape(.capsule)
    }

    public static func mocked() -> some View {
        RyzePrimaryButton(
            .ryzePreviewTitle,
            role: .cancel
        ) {
        }
        .ryze(font: .body)
    }
}

#Preview {
    RyzePrimaryButton.mocked().ryzePadding()
}
