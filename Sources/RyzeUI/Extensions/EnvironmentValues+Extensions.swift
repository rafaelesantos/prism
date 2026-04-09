//
//  EnvironmentValues+Extensions.swift
//  Ryze
//
//  Created by Rafael Escaleira on 19/04/25.
//

import RyzeFoundation
import SwiftUI

extension EnvironmentValues {
    @Entry public var isLoading: Bool = false
    @Entry public var isDisabled: Bool = false
    @Entry public var screenSize: CGSize = .zero
    @Entry public var scrollPosition: CGPoint = .zero
    @Entry public var isLargeScreen: Bool = false

    @Entry public var theme: RyzeThemeProtocol = RyzeDefaultTheme()
}
