//
//  RyzeShape.swift
//  Ryze
//
//  Created by Rafael Escaleira on 26/04/25.
//

import SwiftUI

public struct RyzeShape: Shape {
    var base: @Sendable (CGRect) -> Path

    public init<S: Shape>(shape: S) {
        base = shape.path(in:)
    }

    public func path(in rect: CGRect) -> Path {
        base(rect)
    }

    public static var capsule: RyzeShape {
        .init(shape: .capsule)
    }

    public static var circle: RyzeShape {
        .init(shape: .circle)
    }

    public static func rounded(radius: CGFloat) -> RyzeShape {
        .init(shape: .rect(cornerRadius: radius))
    }
}
