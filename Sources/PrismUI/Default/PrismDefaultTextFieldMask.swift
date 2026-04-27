//
//  PrismDefaultTextFieldMask.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/06/25.
//

import Foundation
import SwiftUI

/// Built-in input masks for common Brazilian and payment field formats.
enum PrismDefaultTextFieldMask: PrismTextFieldMask {
    /// Brazilian phone number mask (mobile and landline variants).
    case phoneNumber
    /// Brazilian CPF (individual taxpayer) mask: `###.###.###-##`.
    case cpf
    /// Brazilian CNPJ (corporate taxpayer) mask: `##.###.###/####-##`.
    case cnpj
    /// Brazilian postal code (CEP) mask: `#####-###`.
    case cep
    /// Credit card number mask: `#### #### #### ####`.
    case creditCardNumber
    /// Credit card expiration date mask: `##/##`.
    case creditCardExpirationDate
    /// Credit card CVV mask: `###`.
    case creditCardCVV

    /// The format patterns for this mask, where `#` represents a digit placeholder.
    var rawValues: [String]? {
        switch self {
        case .phoneNumber:
            return ["(##) # ####-####", "(##) ####-####", "+## (##) # ####-####"]
        case .cpf:
            return ["###.###.###-##"]
        case .cnpj:
            return ["##.###.###/####-##"]
        case .cep:
            return ["#####-###"]
        case .creditCardNumber:
            return ["#### #### #### ####"]
        case .creditCardExpirationDate:
            return ["##/##"]
        case .creditCardCVV:
            return ["###"]
        }
    }
}
