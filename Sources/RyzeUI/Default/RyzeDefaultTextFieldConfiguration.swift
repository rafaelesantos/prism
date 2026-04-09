//
//  RyzeDefaultTextFieldConfiguration.swift
//  Ryze
//
//  Created by Rafael Escaleira on 15/06/25.
//

import Foundation
import RyzeFoundation
import SwiftUI

enum RyzeDefaultTextFieldConfiguration: RyzeTextFieldConfiguration {
    case email

    var placeholder: RyzeResourceString {
        switch self {
        case .email: return RyzeUIString.placeholderEmail
        }
    }

    var mask: RyzeTextFieldMask? {
        nil
    }

    var icon: String? {
        switch self {
        case .email: return "envelope.fill"
        }
    }

    var contentType: RyzeTextFieldContentType {
        switch self {
        case .email: return .emailAddress
        }
    }

    var autocapitalizationType: RyzeTextInputAutocapitalization {
        switch self {
        case .email: return .never
        }
    }

    var submitLabel: SubmitLabel {
        switch self {
        case .email: return .next
        }
    }

    func validate(text: String) throws {
        guard !text.isEmpty else { return }
        switch self {
        case .email:
            let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
            let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
            if !emailPredicate.evaluate(with: text) {
                throw RyzeUIError.emailValidationFailed
            }
        }
    }
}
