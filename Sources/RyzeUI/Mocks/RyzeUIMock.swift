//
//  RyzeUIMock.swift
//  Ryze
//
//  Created by Rafael Escaleira on 12/06/25.
//

import SwiftUI

@MainActor
public protocol RyzeUIMock {
    associatedtype MockView: View
    static func mocked() -> MockView
}
