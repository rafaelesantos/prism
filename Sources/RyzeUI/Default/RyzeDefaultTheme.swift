//
//  RyzeDefaultTheme.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import RyzeFoundation
import SwiftUI

struct RyzeDefaultTheme: RyzeThemeProtocol {
    var color: RyzeColorProtocol
    var spacing: RyzeSpacingProtocol
    var radius: RyzeRadiusProtocol
    var size: RyzeSizeProtocol
    var locale: RyzeLocale
    var animation: Animation?
    var feedback: SensoryFeedback
    var colorScheme: ColorScheme?

    init(
        color: RyzeColorProtocol = RyzeDefaultColor(),
        spacing: RyzeSpacingProtocol = RyzeDefaultSpacing(),
        radius: RyzeRadiusProtocol = RyzeDefaultRadius(),
        size: RyzeSizeProtocol = RyzeDefaultSize(),
        locale: RyzeLocale = .current,
        animation: Animation? = .interactiveSpring(duration: 0.8),
        feedback: SensoryFeedback = .impact,
        colorScheme: ColorScheme? = nil
    ) {
        self.color = color
        self.spacing = spacing
        self.radius = radius
        self.size = size
        self.locale = locale
        self.animation = animation
        self.feedback = feedback
        self.colorScheme = colorScheme
    }
}
