//
//  RyzeBodyText.swift
//  Ryze
//
//  Created by Rafael Escaleira on 03/07/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzeBodyText: RyzeView {
    let text: String?
    public var accessibility: RyzeAccessibility?

    public init(
        _ localized: RyzeResourceString?,
        _ accessibility: RyzeAccessibility? = nil
    ) {
        self.text = localized?.value
        self.accessibility = accessibility
    }

    public var body: some View {
        RyzeText(
            text,
            accessibility
        )
        .ryze(font: .body)
        .ryze(color: .text)
    }

    public static func mocked() -> some View {
        RyzeBodyText(RyzeUIString.ryzePreviewDescription)
    }
}

#Preview {
    RyzeBodyText.mocked().ryzePadding()
}
