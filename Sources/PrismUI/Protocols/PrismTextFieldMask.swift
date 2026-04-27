//
//  PrismTextFieldMask.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/06/25.
//

import SwiftUI

/// Protocolo para máscara de campos de texto.
public protocol PrismTextFieldMask {
    var rawValues: [String]? { get }
}
