//
//  PrismResourceString.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

import SwiftUI

/// A protocol for localizable strings.
public protocol PrismResourceString {
    var localized: LocalizedStringKey { get }
    var value: String { get }
}
