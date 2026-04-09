//
//  RyzeReducer.swift
//  Ryze
//
//  Created by Rafael Escaleira on 12/04/25.
//

@MainActor
public protocol RyzeReducer: Sendable {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    func reduce(
        into state: inout State,
        action: Action
    ) -> RyzeEffect<Action>
}

extension RyzeReducer {
    public func eraseToReduce() -> RyzeReduce<State, Action> {
        RyzeReduce(self.reduce)
    }

    public func handling<Middleware: RyzeMiddleware>(
        with middleware: Middleware
    ) -> RyzeReduce<State, Action>
    where
        Middleware.State == State,
        Middleware.Action == Action
    {
        RyzeReduce { state, action in
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
