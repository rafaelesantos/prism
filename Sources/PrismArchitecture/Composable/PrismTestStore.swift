//
//  PrismTestStore.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/04/26.
//

import Foundation

/// A testing wrapper around ``PrismStore`` that provides synchronous assertions and effect-waiting utilities.
///
/// Use `PrismTestStore` in unit tests to send actions, inspect resulting state, and
/// wait for asynchronous effects to complete before making assertions.
@MainActor
public final class PrismTestStore<State: Sendable & Equatable, Action: Sendable> {
    /// The underlying ``PrismStore`` being tested.
    public let store: PrismStore<State, Action>

    private let clock = ContinuousClock()

    /// The current state of the underlying store.
    public var state: State {
        store.state
    }

    /// Creates a test store with the given initial state and a typed reducer.
    ///
    /// - Parameters:
    ///   - initialState: The initial value of the store's state.
    ///   - reducer: A ``PrismReducer`` that processes actions and returns effects.
    public init<Reducer: PrismReducer>(
        initialState: State,
        reducer: Reducer
    )
    where
        Reducer.State == State,
        Reducer.Action == Action
    {
        self.store = PrismStore(
            initialState: initialState,
            reducer: reducer
        )
    }

    /// Creates a test store with the given initial state and a closure-based reducer.
    ///
    /// - Parameters:
    ///   - initialState: The initial value of the store's state.
    ///   - reduce: A closure that mutates state in response to an action and returns an effect.
    public convenience init(
        initialState: State,
        reduce: @escaping @MainActor @Sendable (inout State, Action) -> PrismEffect<Action>
    ) {
        self.init(
            initialState: initialState,
            reducer: PrismReduce(reduce)
        )
    }

    /// Creates a test store with the given initial state, a typed reducer, and middleware.
    ///
    /// - Parameters:
    ///   - initialState: The initial value of the store's state.
    ///   - reducer: A ``PrismReducer`` that processes actions and returns effects.
    ///   - middleware: A ``PrismMiddleware`` that runs after each action is reduced.
    public init<Reducer: PrismReducer, Middleware: PrismMiddleware>(
        initialState: State,
        reducer: Reducer,
        middleware: Middleware
    )
    where
        Reducer.State == State,
        Reducer.Action == Action,
        Middleware.State == State,
        Middleware.Action == Action
    {
        self.store = PrismStore(
            initialState: initialState,
            reducer: reducer,
            middleware: middleware
        )
    }

    /// Sends an action to the store and returns the resulting state.
    ///
    /// - Parameter action: The action to process.
    /// - Returns: The state after the action has been reduced.
    @discardableResult
    public func send(_ action: Action) -> State {
        store.send(action)
        return store.state
    }

    /// Waits until all in-flight effects in the store have completed.
    ///
    /// - Parameters:
    ///   - timeout: The maximum duration to wait before returning `false`. Defaults to 1 second.
    ///   - pollInterval: The interval between polling checks. Defaults to 10 milliseconds.
    /// - Returns: `true` if all effects completed within the timeout, `false` otherwise.
    @discardableResult
    public func waitForEffects(
        timeout: Duration = .seconds(1),
        pollInterval: Duration = .milliseconds(10)
    ) async -> Bool {
        let deadline = clock.now.advanced(by: timeout)

        while store.hasInFlightEffects {
            if clock.now >= deadline {
                return false
            }

            try? await Task.sleep(for: pollInterval)
        }

        return true
    }

    /// Waits until a predicate on the store's state becomes `true`.
    ///
    /// - Parameters:
    ///   - predicate: A closure evaluated against the current state on each poll.
    ///   - timeout: The maximum duration to wait before returning `false`. Defaults to 1 second.
    ///   - pollInterval: The interval between polling checks. Defaults to 10 milliseconds.
    /// - Returns: `true` if the predicate was satisfied within the timeout, `false` otherwise.
    @discardableResult
    public func waitUntil(
        _ predicate: @escaping @Sendable (State) -> Bool,
        timeout: Duration = .seconds(1),
        pollInterval: Duration = .milliseconds(10)
    ) async -> Bool {
        let deadline = clock.now.advanced(by: timeout)

        while !predicate(store.state) {
            if clock.now >= deadline {
                return false
            }

            try? await Task.sleep(for: pollInterval)
        }

        return true
    }
}
