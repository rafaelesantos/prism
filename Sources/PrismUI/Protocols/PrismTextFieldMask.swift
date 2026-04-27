//
//  PrismTextFieldMask.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/06/25.
//

import SwiftUI

/// Protocol for text field masks.
public protocol PrismTextFieldMask {
    var rawValues: [String]? { get }
}
