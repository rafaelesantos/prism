//
//  PrismDefaultSpacing.swift
//  Prism
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

/// Default implementation of spacing.
public struct PrismDefaultSpacing: PrismSpacingProtocol {
    /// Zero spacing (0pt).
    public var none: CGFloat = .zero
    /// Extra-small spacing (4pt default).
    public var extraSmall: CGFloat
    /// Small spacing (8pt default).
    public var small: CGFloat
    /// Medium spacing (16pt default).
    public var medium: CGFloat
    /// Large spacing (24pt default).
    public var large: CGFloat
    /// Extra-large spacing (32pt default).
    public var extraLarge: CGFloat
    /// Ultra-large spacing (48pt default).
    public var ultraLarge: CGFloat
    /// Section-level spacing (64pt default).
    public var section: CGFloat

    /// Creates a default spacing scale with the given values.
    public init(
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
