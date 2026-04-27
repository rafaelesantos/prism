//
//  PrismReduce.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/04/26.
//

/// A closure-based reducer for state transformations.
///
/// Use `PrismReduce` when you want to define a reducer inline without creating a
/// dedicated type that conforms to ``PrismReducer``.
public struct PrismReduce<State: Sendable, Action: Sendable>: PrismReducer {
    private let body: @MainActor @Sendable (inout State, Action) -> PrismEffect<Action>

    /// Creates a reducer from a closure.
    ///
    /// - Parameter body: A closure that mutates state for a given action and returns an effect.
    public init(
        _ body: @escaping @MainActor @Sendable (inout State, Action) -> PrismEffect<Action>
    ) {
        self.body = body
    }

    /// Processes an action by delegating to the underlying closure.
    ///
    /// - Parameters:
    ///   - state: The current state, mutated in place.
    ///   - action: The action to handle.
    /// - Returns: A ``PrismEffect`` describing any asynchronous work to perform.
    public func reduce(
        into state: inout State,
        action: Action
    ) -> PrismEffect<Action> {
        body(&state, action)
    }
}

extension PrismReduce {
    /// Combines multiple reducers into a single reducer that runs them sequentially.
    ///
    /// Each reducer processes the action in order, mutating the same state.
    /// All resulting effects are merged and run concurrently.
    ///
    /// - Parameter reducers: A variadic list of reducers to combine.
    /// - Returns: A single ``PrismReduce`` that applies all reducers in order.
    public static func combine(_ reducers: Self...) -> Self {
        combine(reducers)
    }

    /// Combines an array of reducers into a single reducer that runs them sequentially.
    ///
    /// - Parameter reducers: An array of reducers to combine.
    /// - Returns: A single ``PrismReduce`` that applies all reducers in order.
    public static func combine(_ reducers: [Self]) -> Self {
        Self { state, action in
            var effects = [PrismEffect<Action>]()

            for reducer in reducers {
                effects.append(
                    reducer.reduce(
                        into: &state,
                        action: action
                    )
                )
            }

            return .merge(effects)
        }
    }
}
