//
//  RyzeMiddleware.swift
//  Ryze
//
//  Created by Rafael Escaleira on 12/04/25.
//

public protocol RyzeMiddleware: Sendable {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    func run(
        state: State,
        action: Action
    ) -> RyzeEffect<Action>
}

public struct RyzeSideEffect<State: Sendable, Action: Sendable>: RyzeMiddleware {
    private let operation: @Sendable (State, Action) -> RyzeEffect<Action>

    public init(
        _ operation: @escaping @Sendable (State, Action) -> RyzeEffect<Action>
    ) {
        self.operation = operation
    }

    public func run(
        state: State,
        action: Action
    ) -> RyzeEffect<Action> {
        operation(state, action)
    }
}

extension RyzeSideEffect {
    public static var none: Self {
        Self { _, _ in
            .none
        }
    }

    public static func combine(_ middlewares: Self...) -> Self {
        combine(middlewares)
    }

    public static func combine(_ middlewares: [Self]) -> Self {
        Self { state, action in
            .merge(
                middlewares.map {
                    $0.run(
                        state: state,
                        action: action
                    )
                }
            )
        }
    }
}

public struct AnyRyzeMiddleware<State: Sendable, Action: Sendable>: RyzeMiddleware {
    private let operation: @Sendable (State, Action) -> RyzeEffect<Action>

    public init<Middleware: RyzeMiddleware>(_ middleware: Middleware)
    where
        Middleware.State == State,
        Middleware.Action == Action
    {
        self.operation = { state, action in
            middleware.run(
                state: state,
                action: action
            )
        }
    }

    public func run(
        state: State,
        action: Action
    ) -> RyzeEffect<Action> {
        operation(state, action)
    }
}
