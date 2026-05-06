import SwiftUI

public enum RadiusToken: CGFloat, Sendable, CaseIterable {
    case none = 0
    case xs = 4
    case sm = 8
    case md = 12
    case lg = 16
    case xl = 24
    case full = 9999
}

extension RadiusToken {
    public var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: rawValue, style: .continuous)
    }

    public var clipShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: rawValue,
                bottomLeading: rawValue,
                bottomTrailing: rawValue,
                topTrailing: rawValue
            ),
            style: .continuous
        )
    }
}
