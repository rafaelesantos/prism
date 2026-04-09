//
//  RyzeReduce.swift
//  Ryze
//
//  Created by Rafael Escaleira on 08/04/26.
//

public struct RyzeReduce<State: Sendable, Action: Sendable>: RyzeReducer {
    private let body: @MainActor @Sendable (inout State, Action) -> RyzeEffect<Action>

    public init(
        _ body: @escaping @MainActor @Sendable (inout State, Action) -> RyzeEffect<Action>
    ) {
        self.body = body
    }

    public func reduce(
        into state: inout State,
        action: Action
    ) -> RyzeEffect<Action> {
        body(&state, action)
    }
}

extension RyzeReduce {
    public static func combine(_ reducers: Self...) -> Self {
        combine(reducers)
    }

    public static func combine(_ reducers: [Self]) -> Self {
        Self { state, action in
            var effects = [RyzeEffect<Action>]()

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
