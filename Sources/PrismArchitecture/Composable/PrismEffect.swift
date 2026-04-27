//
//  PrismEffect.swift
//  Prism
//
//  Created by Rafael Escaleira on 08/04/26.
//

import Foundation

/// A description of side effects that can produce zero or more actions asynchronously.
///
/// Effects are the primary way to perform asynchronous work (network requests, timers,
/// etc.) in the Prism architecture. A reducer returns an effect after processing an action,
/// and the store executes it, feeding any emitted actions back into the reducer.
///
/// ```swift
/// // Returning an effect from a reducer
/// func reduce(into state: inout State, action: Action) -> PrismEffect<Action> {
///     switch action {
///     case .fetchData:
///         return .run { send in
///             let data = try await api.load()
///             send(.dataLoaded(data))
///         }
///     case .dataLoaded(let data):
///         state.data = data
///         return .none
///     }
/// }
/// ```
public struct PrismEffect<Action: Sendable>: Sendable {
    private let isKnownEmpty: Bool
    private let makeActions: @Sendable () -> AsyncStream<Action>

    /// Creates an effect from a closure that produces an `AsyncStream` of actions.
    ///
    /// - Parameters:
    ///   - isEmpty: A hint indicating whether this effect will produce no actions.
    ///   - makeActions: A closure that returns an `AsyncStream` of actions to emit.
    public init(
        isEmpty: Bool = false,
        _ makeActions: @escaping @Sendable () -> AsyncStream<Action>
    ) {
        self.isKnownEmpty = isEmpty
        self.makeActions = makeActions
    }

    /// An asynchronous stream of actions produced by this effect.
    public var actions: AsyncStream<Action> {
        makeActions()
    }

    var isEmpty: Bool {
        isKnownEmpty
    }
}

extension PrismEffect {
    /// An effect that produces no actions and completes immediately.
    public static var none: Self {
        Self(isEmpty: true) {
            AsyncStream { continuation in
                continuation.finish()
            }
        }
    }

    /// Creates an effect that emits a single action.
    ///
    /// - Parameter action: The action to emit.
    /// - Returns: An effect that yields the given action and then completes.
    public static func send(_ action: Action) -> Self {
        sequence([action])
    }

    /// Creates an effect that emits a sequence of actions in order.
    ///
    /// - Parameter actions: A sequence of actions to emit.
    /// - Returns: An effect that yields each action in order and then completes.
    public static func sequence<S: Sequence>(
        _ actions: S
    ) -> Self where S.Element == Action {
        let values = Array(actions)

        return Self(isEmpty: values.isEmpty) {
            AsyncStream { continuation in
                for action in values {
                    continuation.yield(action)
                }
                continuation.finish()
            }
        }
    }

    /// Creates an effect that performs asynchronous work and emits actions via a send closure.
    ///
    /// Use this factory to wrap async operations such as network requests. The task
    /// is automatically cancelled when the effect is terminated by the store.
    ///
    /// - Parameters:
    ///   - priority: The priority of the underlying `Task`. Defaults to `nil`.
    ///   - operation: An async closure that receives a `send` callback for emitting actions.
    /// - Returns: An effect backed by the asynchronous operation.
    public static func run(
        priority: TaskPriority? = nil,
        _ operation: @escaping @Sendable (@escaping @Sendable (Action) -> Void) async -> Void
    ) -> Self {
        Self {
            AsyncStream { continuation in
                let task = Task(priority: priority) {
                    await operation { action in
                        continuation.yield(action)
                    }
                    continuation.finish()
                }

                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
    }

    /// Merges multiple effects into a single effect that runs them all concurrently.
    ///
    /// - Parameter effects: A variadic list of effects to merge.
    /// - Returns: An effect that runs all provided effects concurrently and completes when all finish.
    public static func merge(_ effects: Self...) -> Self {
        merge(effects)
    }

    /// Merges an array of effects into a single effect that runs them all concurrently.
    ///
    /// - Parameter effects: An array of effects to merge.
    /// - Returns: An effect that runs all provided effects concurrently and completes when all finish.
    public static func merge(_ effects: [Self]) -> Self {
        let nonEmptyEffects = effects.filter { !$0.isEmpty }

        if nonEmptyEffects.isEmpty {
            return .none
        }

        if nonEmptyEffects.count == 1, let effect = nonEmptyEffects.first {
            return effect
        }

        return Self {
            AsyncStream { continuation in
                let task = Task {
                    await withTaskGroup(of: Void.self) { group in
                        for effect in nonEmptyEffects {
                            group.addTask {
                                for await action in effect.actions {
                                    continuation.yield(action)
                                }
                            }
                        }

                        await group.waitForAll()
                        continuation.finish()
                    }
                }

                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
        }
    }
}
