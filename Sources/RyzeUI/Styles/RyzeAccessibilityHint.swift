//
//  RyzeAccessibility.swift
//  Ryze
//
//  Created by Rafael Escaleira on 02/07/25.
//

import RyzeFoundation
import SwiftUI

public protocol RyzeAccessibility: RyzeResourceString {
    var hint: RyzeResourceString { get }
    var label: RyzeResourceString { get }
    var identifier: RyzeResourceString { get }
}
