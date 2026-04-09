//
//  RyzeView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 12/06/25.
//

import SwiftUI

public protocol RyzeView: View, RyzeUIMock {
    var accessibility: RyzeAccessibility? { get }
    var canAppear: Bool { get }
}

extension RyzeView {
    public var accessibility: RyzeAccessibility? { nil }
    public var canAppear: Bool { true }
}
