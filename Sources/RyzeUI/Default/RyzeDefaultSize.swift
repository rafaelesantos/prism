//
//  RyzeDefaultSize.swift
//  Ryze
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

struct RyzeDefaultSize: RyzeSizeProtocol {
    var ultraSmall: CGFloat
    var ultraSmall2: CGFloat
    var extraSmall: CGFloat
    var extraSmall2: CGFloat
    var small: CGFloat
    var small2: CGFloat
    var medium: CGFloat
    var medium2: CGFloat
    var large: CGFloat
    var large2: CGFloat
    var extraLarge: CGFloat
    var extraLarge2: CGFloat
    var ultraLarge: CGFloat
    var max: CGFloat

    init(
        ultraSmall: CGFloat = 12,
        ultraSmall2: CGFloat = 16,
        extraSmall: CGFloat = 24,
        extraSmall2: CGFloat = 36,
        small: CGFloat = 56,
        small2: CGFloat = 72,
        medium: CGFloat = 96,
        medium2: CGFloat = 120,
        large: CGFloat = 144,
        large2: CGFloat = 176,
        extraLarge: CGFloat = 208,
        extraLarge2: CGFloat = 232,
        ultraLarge: CGFloat = 256,
        max: CGFloat = .infinity
    ) {
        self.ultraSmall = ultraSmall
        self.ultraSmall2 = ultraSmall2
        self.extraSmall = extraSmall
        self.extraSmall2 = extraSmall2
        self.small = small
        self.small2 = small2
        self.medium = medium
        self.medium2 = medium2
        self.large = large
        self.large2 = large2
        self.extraLarge = extraLarge
        self.extraLarge2 = extraLarge2
        self.ultraLarge = ultraLarge
        self.max = max
    }
}
