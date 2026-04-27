//
//  PrismSpacing.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

/// Design system spacing.
public indirect enum PrismSpacing {
    /// Zero spacing.
    case zero
    /// Extra-small spacing.
    case extraSmall
    /// Small spacing.
    case small
    /// Medium spacing.
    case medium
    /// Large spacing.
    case large
    /// Extra-large spacing.
    case extraLarge
    /// Ultra-large spacing.
    case ultraLarge
    /// Section-level spacing.
    case section
    /// Negated spacing value, useful for insets or pull-backs.
    case negative(PrismSpacing)
    /// An arbitrary custom spacing value in points.
    case custom(CGFloat)

    /// Resolves this token to a concrete point value using the given spacing protocol.
    func rawValue(for theme: PrismSpacingProtocol) -> CGFloat {
        switch self {
        case .zero: return theme.none
        case .extraSmall: return theme.extraSmall
        case .small: return theme.small
        case .medium: return theme.medium
        case .large: return theme.large
        case .extraLarge: return theme.extraLarge
        case .ultraLarge: return theme.ultraLarge
        case .section: return theme.section
        case .negative(let spacing): return -spacing.rawValue(for: theme)
        case .custom(let spacing): return spacing
        }
    }
}
