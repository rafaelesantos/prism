//
//  RyzeColor.swift
//  Ryze
//
//  Created by Rafael Escaleira on 01/07/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzeColor: ShapeStyle, @unchecked Sendable {
    private enum Storage {
        case themed(KeyPath<RyzeColorProtocol, Color>)
        case custom(Color)
    }

    private let storage: Storage

    init(keyPath: KeyPath<RyzeColorProtocol, Color>) {
        self.storage = .themed(keyPath)
    }

    public init(rawValue: Color) {
        self.storage = .custom(rawValue)
    }

    public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        switch storage {
        case .themed(let keyPath):
            return environment.theme.color[keyPath: keyPath]
        case .custom(let color):
            return color
        }
    }

    public func color(using theme: RyzeColorProtocol) -> Color {
        switch storage {
        case .themed(let keyPath):
            return theme[keyPath: keyPath]
        case .custom(let color):
            return color
        }
    }
}
