//
//  PrismReducer.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/04/25.
//

/// A protocol for reducers that process actions and mutate state.
///
/// Conforming types implement the core business logic of a feature by handling
/// actions and optionally returning effects for asynchronous work.
@MainActor
public protocol PrismReducer: Sendable {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    /// Processes an action by mutating the current state and returning an effect.
    ///
    /// - Parameters:
    ///   - state: The current state, mutated in place.
    ///   - action: The action to handle.
    /// - Returns: A ``PrismEffect`` describing any asynchronous work to perform.
    func reduce(
        into state: inout State,
        action: Action
    ) -> PrismEffect<Action>
}

extension PrismReducer {
    /// Type-erases this reducer into a ``PrismReduce`` value.
    ///
    /// - Returns: A ``PrismReduce`` instance that delegates to this reducer's ``reduce(into:action:)`` method.
    public func eraseToReduce() -> PrismReduce<State, Action> {
        PrismReduce(self.reduce)
    }

    /// Composes this reducer with a middleware, merging both sets of effects.
    ///
    /// The returned reducer first applies this reducer, then runs the middleware,
    /// and merges their resulting effects.
    ///
    /// - Parameter middleware: The middleware to run after each reduction.
    /// - Returns: A ``PrismReduce`` that combines the reducer and middleware effects.
    public func handling<Middleware: PrismMiddleware>(
        with middleware: Middleware
    ) -> PrismReduce<State, Action>
    where
        Middleware.State == State,
        Middleware.Action == Action
    {
        PrismReduce { state, action in
            let reducerEffect = reduce(
                into: &state,
                action: action
            )
            let middlewareEffect = middleware.run(
                state: state,
                action: action
            )

            return .merge(
                reducerEffect,
                middlewareEffect
            )
        }
    }
}
