//
//  RyzeColorProtocol.swift
//  Ryze
//
//  Created by Rafael Escaleira on 18/04/25.
//

import SwiftUI

public protocol RyzeColorProtocol: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
    var background: Color { get set }
    var backgroundSecondary: Color { get set }
    var shadow: Color { get set }
    var surface: Color { get set }
    var text: Color { get set }
    var textSecondary: Color { get set }
    var border: Color { get set }
    var error: Color { get set }
    var success: Color { get set }
    var warning: Color { get set }
    var info: Color { get set }
    var disabled: Color { get set }
    var hover: Color { get set }
    var pressed: Color { get set }
    var white: Color { get set }
    var black: Color { get set }
}
