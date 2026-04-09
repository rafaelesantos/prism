//
//  RyzeRadius.swift
//  Ryze
//
//  Created by Rafael Escaleira on 01/07/25.
//

import SwiftUI

public enum RyzeRadius: CaseIterable, Equatable {
    case none
    case small
    case medium
    case large
    case extraLarge
    case circle
    case capsule

    func rawValue(for theme: RyzeRadiusProtocol) -> CGFloat {
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
