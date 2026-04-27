//
//  PrismStore+Binding.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/04/26.
//

import PrismArchitecture
import SwiftUI

extension PrismStore {
    /// Creates a SwiftUI `Binding` that reads from the store's state and dispatches an action on write.
    ///
    /// This bridges the unidirectional PrismStore architecture with SwiftUI's two-way binding model.
    ///
    /// - Parameters:
    ///   - keyPath: A key path into the store's state to read.
    ///   - action: A closure that converts the new value into an action to dispatch.
    /// - Returns: A `Binding<Value>` connected to the store.
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
