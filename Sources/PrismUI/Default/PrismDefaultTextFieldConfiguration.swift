//
//  PrismDefaultTextFieldConfiguration.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/06/25.
//

import Foundation
import PrismFoundation
import SwiftUI

/// Built-in text field configurations with pre-set validation, icons, and keyboard types.
enum PrismDefaultTextFieldConfiguration: PrismTextFieldConfiguration {
    /// Email address input configuration with regex validation.
    case email

    /// The localized placeholder string for this configuration.
    var placeholder: PrismResourceString {
        switch self {
        case .email: return PrismUIString.placeholderEmail
        }
    }

    /// The optional input mask applied to this field, or `nil` for free-form input.
    var mask: PrismTextFieldMask? {
        nil
    }

    /// The SF Symbol name displayed as the field's leading icon, or `nil` for none.
    var icon: String? {
        switch self {
        case .email: return "envelope.fill"
        }
    }

    /// The keyboard content type for this field.
    var contentType: PrismTextFieldContentType {
        switch self {
        case .email: return .emailAddress
        }
    }

    /// The autocapitalization behavior for this field.
    var autocapitalizationType: PrismTextInputAutocapitalization {
        switch self {
        case .email: return .never
        }
    }

    /// The label shown on the keyboard's return key.
    var submitLabel: SubmitLabel {
        switch self {
        case .email: return .next
        }
    }

    /// Validates the given text against this configuration's rules.
    ///
    /// - Parameter text: The user-entered string to validate.
    /// - Throws: ``PrismUIError/emailValidationFailed`` if the email format is invalid.
    func validate(text: String) throws {
        guard !text.isEmpty else { return }
        switch self {
        case .email:
            let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
            let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
            if !emailPredicate.evaluate(with: text) {
                throw PrismUIError.emailValidationFailed
            }
        }
    }
}
