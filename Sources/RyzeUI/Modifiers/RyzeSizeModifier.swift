//
//  RyzeSizeModifier.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

struct RyzeSizeModifier: RyzeViewModifier {
    @Environment(\.theme) var theme

    let width: RyzeSize?
    let height: RyzeSize?
    let alignment: Alignment

    init(width: RyzeSize?, height: RyzeSize?, alignment: Alignment) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }

    var widthValue: CGFloat? { width?.rawValue(for: theme.size) }
    var heightValue: CGFloat? { height?.rawValue(for: theme.size) }

    func body(content: Content) -> some View {
        content
            .ryze(if: width == .max && height == .max) {
                $0.frame(
                    maxWidth: widthValue,
                    maxHeight: heightValue,
                    alignment: alignment
                )
            }
            .ryze(if: width == .max && height != .max) {
                $0.frame(
                    maxWidth: widthValue,
                    alignment: alignment
                ).frame(
                    height: heightValue,
                    alignment: alignment
                )
            }
            .ryze(if: width != .max && height == .max) {
                $0.frame(
                    maxHeight: heightValue,
                    alignment: alignment
                ).frame(
                    width: widthValue,
                    alignment: alignment
                )
            }
            .ryze(if: width != .max && height != .max) {
                $0.frame(
                    width: widthValue,
                    height: heightValue,
                    alignment: alignment
                )
            }
    }

    static func mocked() -> some View {
        Image(systemName: "square.and.arrow.up")
            .resizable()
            .scaledToFit()
            .ryze(width: .medium, height: .medium, alignment: .center)
    }
}

#Preview {
    RyzeSizeModifier.mocked()
}
