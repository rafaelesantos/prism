//
//  PrismSize.swift
//  Prism
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

/// Design system sizes.
public indirect enum PrismSize {
    /// No size (returns `nil`).
    case none
    /// Ultra-small size.
    case ultraSmall
    /// Ultra-small secondary size.
    case ultraSmall2
    /// Extra-small size.
    case extraSmall
    /// Extra-small secondary size.
    case extraSmall2
    /// Small size.
    case small
    /// Small secondary size.
    case small2
    /// Medium size.
    case medium
    /// Medium secondary size.
    case medium2
    /// Large size.
    case large
    /// Large secondary size.
    case large2
    /// Extra-large size.
    case extraLarge
    /// Extra-large secondary size.
    case extraLarge2
    /// Ultra-large size.
    case ultraLarge
    /// Maximum available size.
    case max

    /// Resolves this token to a concrete point value using the given size protocol, or `nil` for ``none``.
    func rawValue(for theme: PrismSizeProtocol) -> CGFloat? {
        switch self {
        case .none: return nil
        case .ultraSmall: return theme.ultraSmall
        case .ultraSmall2: return theme.ultraSmall2
        case .extraSmall: return theme.extraSmall
        case .extraSmall2: return theme.extraSmall2
        case .small: return theme.small
        case .small2: return theme.small2
        case .medium: return theme.medium
        case .medium2: return theme.medium2
        case .large: return theme.large
        case .large2: return theme.large2
        case .extraLarge: return theme.extraLarge
        case .extraLarge2: return theme.extraLarge2
        case .ultraLarge: return theme.ultraLarge
        case .max: return theme.max
        }
    }
}
