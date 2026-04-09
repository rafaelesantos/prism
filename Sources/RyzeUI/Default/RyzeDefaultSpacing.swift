//
//  RyzeDefaultSpacing.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

struct RyzeDefaultSpacing: RyzeSpacingProtocol {
    var none: CGFloat = .zero
    var extraSmall: CGFloat
    var small: CGFloat
    var medium: CGFloat
    var large: CGFloat
    var extraLarge: CGFloat
    var ultraLarge: CGFloat
    var section: CGFloat

    init(
        extraSmall: CGFloat = 4,
        small: CGFloat = 8,
        medium: CGFloat = 16,
        large: CGFloat = 24,
        extraLarge: CGFloat = 32,
        ultraLarge: CGFloat = 48,
        section: CGFloat = 64
    ) {
        self.extraSmall = extraSmall
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
        self.ultraLarge = ultraLarge
        self.section = section
    }
}
