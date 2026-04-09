//
//  RyzeTestStore.swift
//  Ryze
//
//  Created by Rafael Escaleira on 08/04/26.
//

import Foundation

@MainActor
public final class RyzeTestStore<State: Sendable & Equatable, Action: Sendable> {
    public let store: RyzeStore<State, Action>

    private let clock = ContinuousClock()

    public var state: State {
        store.state
    }

    public init<Reducer: RyzeReducer>(
        initialState: State,
        reducer: Reducer
    )
    where
        Reducer.State == State,
        Reducer.Action == Action
    {
        self.store = RyzeStore(
            initialState: initialState,
            reducer: reducer
        )
    }

    public convenience init(
        initialState: State,
        reduce: @escaping @MainActor @Sendable (inout State, Action) -> RyzeEffect<Action>
    ) {
        self.init(
            initialState: initialState,
            reducer: RyzeReduce(reduce)
        )
    }

    public init<Reducer: RyzeReducer, Middleware: RyzeMiddleware>(
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
        self.store = RyzeStore(
            initialState: initialState,
            reducer: reducer,
            middleware: middleware
        )
    }

    @discardableResult
    public func send(_ action: Action) -> State {
        store.send(action)
        return store.state
    }

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
