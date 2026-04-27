//
//  PrismTextInputAutocapitalization.swift
//  Prism
//
//  Created by Rafael Escaleira on 13/06/25.
//

import SwiftUI

/// Autocapitalization types for text fields.
public enum PrismTextInputAutocapitalization {
    /// No automatic capitalization.
    case never
    /// Capitalize the first letter of each word.
    case words
    /// Capitalize the first letter of each sentence.
    case sentences
    /// Capitalize all characters.
    case characters

    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        /// The corresponding `TextInputAutocapitalization` for this type.
        public var rawValue: TextInputAutocapitalization {
            switch self {
            case .never: return .never
            case .words: return .words
            case .sentences: return .sentences
            case .characters: return .characters
            }
        }
    #endif
}
