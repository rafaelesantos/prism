//
//  RyzeRoutable.swift
//  Ryze
//
//  Created by Rafael Escaleira on 03/04/25.
//

public protocol RyzeRoutable: Hashable, Identifiable, Sendable {}

extension RyzeRoutable {
    public var id: Self {
        self
    }
}
