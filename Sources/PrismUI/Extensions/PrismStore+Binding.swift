import PrismArchitecture
import SwiftUI

extension PrismStore {

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
