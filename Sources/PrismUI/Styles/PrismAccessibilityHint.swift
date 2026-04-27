//
//  PrismAccessibilityHint.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/07/25.
//

import PrismFoundation
import SwiftUI

/// Legacy accessibility protocol kept for backward compatibility.
///
/// Prefer ``PrismAccessibilityProperties`` for new code. This protocol provides
/// localized hint, label, and identifier strings via ``PrismResourceString``.
public protocol PrismAccessibilityHint: PrismResourceString {
    /// A localized hint describing the result of interacting with the element.
    var hint: PrismResourceString { get }
    /// A localized label identifying the element for VoiceOver.
    var label: PrismResourceString { get }
    /// A stable identifier string for UI testing.
    var identifier: PrismResourceString { get }
}
