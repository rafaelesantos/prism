//
//  RyzeFootnoteText.swift
//  Ryze
//
//  Created by Rafael Escaleira on 03/07/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzeFootnoteText: RyzeView {
    let text: String?
    public var accessibility: RyzeAccessibility?

    public init(
        _ localized: RyzeResourceString?,
        _ accessibility: RyzeAccessibility? = nil,
    ) {
        self.text = localized?.value
    }

    public var body: some View {
        RyzeText(
            text,
            accessibility
        )
        .ryze(font: .footnote)
        .ryze(color: .textSecondary)
    }

    public static func mocked() -> some View {
        RyzeFootnoteText(RyzeUIString.ryzePreviewDescription)
    }
}

#Preview {
    RyzeFootnoteText.mocked().ryzePadding()
}
