//
//  RyzeStore+Binding.swift
//  Ryze
//
//  Created by Rafael Escaleira on 08/04/26.
//

import RyzeArchitecture
import SwiftUI

extension RyzeStore {
    public func binding<Value: Sendable>(
        for keyPath: KeyPath<State, Value>,
        send action: @escaping @Sendable (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: {
                MainActor.assumeIsolated {
                    self.state[keyPath: keyPath]
                }
            },
            set: { newValue in
                Task { @MainActor in
                    self.send(action(newValue))
                }
            }
        )
    }
}
