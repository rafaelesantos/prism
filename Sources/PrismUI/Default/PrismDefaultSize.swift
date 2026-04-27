//
//  PrismDefaultSize.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import SwiftUI

/// Default implementation of sizes.
public struct PrismDefaultSize: PrismSizeProtocol {
    /// Ultra-small size (12pt default).
    public var ultraSmall: CGFloat
    /// Ultra-small secondary size (16pt default).
    public var ultraSmall2: CGFloat
    /// Extra-small size (24pt default).
    public var extraSmall: CGFloat
    /// Extra-small secondary size (36pt default).
    public var extraSmall2: CGFloat
    /// Small size (56pt default).
    public var small: CGFloat
    /// Small secondary size (72pt default).
    public var small2: CGFloat
    /// Medium size (96pt default).
    public var medium: CGFloat
    /// Medium secondary size (120pt default).
    public var medium2: CGFloat
    /// Large size (144pt default).
    public var large: CGFloat
    /// Large secondary size (176pt default).
    public var large2: CGFloat
    /// Extra-large size (208pt default).
    public var extraLarge: CGFloat
    /// Extra-large secondary size (232pt default).
    public var extraLarge2: CGFloat
    /// Ultra-large size (256pt default).
    public var ultraLarge: CGFloat
    /// Maximum available size (infinity).
    public var max: CGFloat

    /// Creates a default size scale with the given values.
    public init(
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
