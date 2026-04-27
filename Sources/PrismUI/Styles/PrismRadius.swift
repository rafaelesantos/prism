//
//  PrismRadius.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

/// Design system border radii.
public enum PrismRadius: CaseIterable, Equatable {
    /// No rounding (sharp corners).
    case none
    /// Small corner radius.
    case small
    /// Medium corner radius.
    case medium
    /// Large corner radius.
    case large
    /// Extra-large corner radius.
    case extraLarge
    /// Fully circular radius.
    case circle
    /// Capsule shape radius (equivalent to ``circle``).
    case capsule

    /// Resolves this token to a concrete point value using the given radius protocol.
    func rawValue(for theme: PrismRadiusProtocol) -> CGFloat {
        switch self {
        case .none: return theme.none
        case .small: return theme.small
        case .medium: return theme.medium
        case .large: return theme.large
        case .extraLarge: return theme.extraLarge
        case .circle, .capsule: return theme.circle
        }
    }
}
