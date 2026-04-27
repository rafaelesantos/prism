//
//  PrismDefaultRadius.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

/// Default implementation of border radii.
public struct PrismDefaultRadius: PrismRadiusProtocol {
    /// No rounding (0pt).
    public var none: CGFloat
    /// Small corner radius (4pt default).
    public var small: CGFloat
    /// Medium corner radius (8pt default).
    public var medium: CGFloat
    /// Large corner radius (16pt default).
    public var large: CGFloat
    /// Extra-large corner radius (24pt default).
    public var extraLarge: CGFloat
    /// Fully circular radius (infinity).
    public var circle: CGFloat

    /// Creates a default radius scale with the given values.
    public init(
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
