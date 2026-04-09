//
//  RyzeDefaultRadius.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

struct RyzeDefaultRadius: RyzeRadiusProtocol {
    var none: CGFloat
    var small: CGFloat
    var medium: CGFloat
    var large: CGFloat
    var extraLarge: CGFloat
    var circle: CGFloat

    init(
        none: CGFloat = .zero,
        small: CGFloat = 4,
        medium: CGFloat = 8,
        large: CGFloat = 16,
        extraLarge: CGFloat = 24,
        circle: CGFloat = .infinity
    ) {
        self.none = none
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
        self.circle = circle
    }
}
