//
//  PrismMiddleware.swift
//  Prism
//
//  Created by Rafael Escaleira on 12/04/25.
//

/// A protocol for middleware that observes actions after reduction and may produce additional effects.
///
/// Middleware is ideal for cross-cutting concerns such as logging, analytics, or
/// triggering side effects that should not live inside the reducer.
public protocol PrismMiddleware: Sendable {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    /// Runs the middleware logic for a given state and action pair.
    ///
    /// - Parameters:
    ///   - state: The current state after the reducer has processed the action.
    ///   - action: The action that was dispatched.
    /// - Returns: A ``PrismEffect`` describing any additional side effects to execute.
    func run(
        state: State,
        action: Action
    ) -> PrismEffect<Action>
}

/// A closure-based middleware for side effects.
///
/// Use `PrismSideEffect` when you want to define middleware inline without creating
/// a dedicated type that conforms to ``PrismMiddleware``.
public struct PrismSideEffect<State: Sendable, Action: Sendable>: PrismMiddleware {
    private let operation: @Sendable (State, Action) -> PrismEffect<Action>

    /// Creates a side-effect middleware from a closure.
    ///
    /// - Parameter operation: A closure that receives the current state and the dispatched action, returning an effect.
    public init(
        _ operation: @escaping @Sendable (State, Action) -> PrismEffect<Action>
    ) {
        self.operation = operation
    }

    /// Runs the middleware logic for a given state and action pair.
    ///
    /// - Parameters:
    ///   - state: The current state after reduction.
    ///   - action: The action that was dispatched.
    /// - Returns: A ``PrismEffect`` describing any additional side effects to execute.
    public func run(
        state: State,
        action: Action
    ) -> PrismEffect<Action> {
        operation(state, action)
    }
}

extension PrismSideEffect {
    /// A no-op side effect that always returns ``PrismEffect/none``.
    public static var none: Self {
        Self { _, _ in
            .none
        }
    }

    /// Combines multiple side-effect middlewares into one that merges their effects.
    ///
    /// - Parameter middlewares: A variadic list of side-effect middlewares.
    /// - Returns: A single ``PrismSideEffect`` that runs all provided middlewares concurrently.
    public static func combine(_ middlewares: Self...) -> Self {
        combine(middlewares)
    }

    /// Combines an array of side-effect middlewares into one that merges their effects.
    ///
    /// - Parameter middlewares: An array of side-effect middlewares.
    /// - Returns: A single ``PrismSideEffect`` that runs all provided middlewares concurrently.
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

/// A type-erased wrapper for any ``PrismMiddleware``.
///
/// Use `AnyPrismMiddleware` to store heterogeneous middleware instances
/// in a uniform collection or to hide a concrete middleware type.
public struct AnyPrismMiddleware<State: Sendable, Action: Sendable>: PrismMiddleware {
    private let operation: @Sendable (State, Action) -> PrismEffect<Action>

    /// Creates a type-erased middleware by wrapping a concrete ``PrismMiddleware``.
    ///
    /// - Parameter middleware: The middleware to wrap.
    public init<Middleware: PrismMiddleware>(_ middleware: Middleware)
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

    /// Runs the wrapped middleware logic for a given state and action pair.
    ///
    /// - Parameters:
    ///   - state: The current state after reduction.
    ///   - action: The action that was dispatched.
    /// - Returns: A ``PrismEffect`` describing any additional side effects to execute.
    public func run(
        state: State,
        action: Action
    ) -> PrismEffect<Action> {
        operation(state, action)
    }
}
