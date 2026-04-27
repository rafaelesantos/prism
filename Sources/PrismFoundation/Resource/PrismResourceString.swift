//
//  PrismResourceString.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

import SwiftUI

/// Protocolo para strings localizáveis.
public protocol PrismResourceString {
    var localized: LocalizedStringKey { get }
    var value: String { get }
}
