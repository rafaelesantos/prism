//
//  PrismLayoutTier.swift
//  Prism
//
//  Created by Rafael Escaleira on 09/04/26.
//

import SwiftUI

/// Layout tiers: compact, regular, expansive.
public enum PrismLayoutTier: String, CaseIterable, Equatable, Sendable {
    /// Compact tier for phone-sized viewports.
    case compact
    /// Regular tier for tablet-sized viewports.
    case regular
    /// Expansive tier for desktop-sized viewports.
    case expansive

    /// The recommended SwiftUI `ControlSize` for this layout tier.
    public var controlSize: ControlSize {
        switch self {
        case .compact:
            .regular
        case .regular:
            .large
        case .expansive:
            .extraLarge
        }
    }

    /// The horizontal content padding in points for this layout tier.
    public var horizontalPadding: CGFloat {
        switch self {
        case .compact:
            16
        case .regular:
            20
        case .expansive:
            24
        }
    }

    /// The vertical content padding in points for this layout tier.
    public var verticalPadding: CGFloat {
        switch self {
        case .compact:
            10
        case .regular:
            12
        case .expansive:
            14
        }
    }
}
