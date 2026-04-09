//
//  RyzeDefaultColor.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import SwiftUI

struct RyzeDefaultColor: RyzeColorProtocol {
    private static func asset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }

    var primary: Color
    var secondary: Color
    var background: Color
    var backgroundSecondary: Color
    var shadow: Color
    var surface: Color
    var text: Color
    var textSecondary: Color
    var border: Color
    var error: Color
    var success: Color
    var warning: Color
    var info: Color
    var disabled: Color
    var hover: Color
    var pressed: Color
    var white: Color
    var black: Color

    init(
        primary: Color = Self.asset("Primary"),
        secondary: Color = Self.asset("Secondary"),
        background: Color = Self.asset("Background"),
        backgroundSecondary: Color = Self.asset("BackgroundSecondary"),
        shadow: Color = Self.asset("Shadow"),
        surface: Color = Self.asset("Surface"),
        text: Color = .primary,
        textSecondary: Color = Color.secondary,
        border: Color = Self.asset("Border"),
        error: Color = Self.asset("Error"),
        success: Color = Self.asset("Success"),
        warning: Color = Self.asset("Warning"),
        info: Color = Self.asset("Info"),
        disabled: Color = Self.asset("Disabled"),
        hover: Color = Self.asset("Hover"),
        pressed: Color = Self.asset("Pressed"),
        white: Color = .white,
        black: Color = .black
    ) {
        self.primary = primary
        self.secondary = secondary
        self.background = background
        self.backgroundSecondary = backgroundSecondary
        self.shadow = shadow
        self.surface = surface
        self.text = text
        self.textSecondary = textSecondary
        self.border = border
        self.error = error
        self.success = success
        self.warning = warning
        self.info = info
        self.disabled = disabled
        self.hover = hover
        self.pressed = pressed
        self.white = white
        self.black = black
    }
}
