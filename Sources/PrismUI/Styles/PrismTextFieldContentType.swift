//
//  PrismTextFieldContentType.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/06/25.
//

import SwiftUI

/// Content types for text fields.
public enum PrismTextFieldContentType {
    /// Default keyboard type.
    case `default`
    /// ASCII-capable keyboard.
    case asciiCapable
    /// Numbers and punctuation keyboard.
    case numbersAndPunctuation
    /// URL-optimized keyboard with `.` and `/` keys.
    case URL
    /// Numeric-only pad.
    case numberPad
    /// Phone dialer pad.
    case phonePad
    /// Name and phone number pad.
    case namePhonePad
    /// Email-optimized keyboard with `@` and `.` keys.
    case emailAddress
    /// Decimal number pad with a decimal separator.
    case decimalPad
    /// Keyboard optimized for Twitter/social media input.
    case twitter
    /// Keyboard optimized for web search queries.
    case webSearch
    /// ASCII-capable number pad.
    case asciiCapableNumberPad
    /// Alphabetic keyboard.
    case alphabet

    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        /// The corresponding `UIKeyboardType` for this content type.
        public var rawValue: UIKeyboardType {
            switch self {
            case .default: return .default
            case .asciiCapable: return .asciiCapable
            case .numbersAndPunctuation: return .numbersAndPunctuation
            case .URL: return .URL
            case .numberPad: return .numberPad
            case .phonePad: return .phonePad
            case .namePhonePad: return .namePhonePad
            case .emailAddress: return .emailAddress
            case .decimalPad: return .decimalPad
            case .twitter: return .twitter
            case .webSearch: return .webSearch
            case .asciiCapableNumberPad: return .asciiCapableNumberPad
            case .alphabet: return .alphabet
            }
        }
    #endif
}
