//
//  RyzePreview.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzePreview<Content: RyzeView>: View {
    let colorSchemes: [ColorScheme] = [.light, .dark]
    let locales: [RyzeLocale] = [.portugueseBR, .englishUS]
    let orientations: [InterfaceOrientation] = [.portrait, .landscapeRight]
    let layouts: [PreviewLayout] = [.sizeThatFits, .device]
    let content: Content.Type

    public init(content: Content.Type) {
        self.content = content
    }

    public var body: some View {
        Group {
            ForEach(locales.indices, id: \.self) {
                let locale = locales[$0]
                ForEach(orientations.indices, id: \.self) {
                    let orientation = orientations[$0]
                    ForEach(layouts.indices, id: \.self) {
                        let layout = layouts[$0]
                        ForEach(colorSchemes.indices, id: \.self) {
                            let colorScheme = colorSchemes[$0]
                            content.mocked()
                                .ryzePreview(
                                    layout: layout,
                                    orientation: orientation,
                                    colorScheme: colorScheme,
                                    locale: locale
                                )
                        }
                    }
                }
            }
        }
    }
}
