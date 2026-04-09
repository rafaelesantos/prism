@testable import RyzeArchitecture

struct CounterState: RyzeState, Equatable {
    var count = 0
    var title = ""
}

enum CounterAction: RyzeAction, Equatable, Hashable {
    case increment
    case decrement
    case setReadyTitle
    case setTitle(String)
    case startReducerEffect
    case startMiddlewareEffect
    case longRunningEffect
}

enum SampleRoute: Hashable, Sendable, RyzeRoutable {
    case home
    case details(id: Int)
    case modal
    case fullScreen
}

@MainActor
struct CounterReducer: RyzeReducer {
    func reduce(
        into state: inout CounterState,
        action: CounterAction
    ) -> RyzeEffect<CounterAction> {
        switch action {
        case .increment:
            state.count += 1
            return .none

        case .decrement:
            state.count -= 1
            return .none

        case .setReadyTitle:
            state.title = "Ready"
            return .none

        case .setTitle(let title):
            state.title = title
            return .none

        case .startReducerEffect:
            return .sequence([.increment, .increment])

        case .startMiddlewareEffect:
            return .none

        case .longRunningEffect:
            return .run { send in
                try? await Task.sleep(for: .milliseconds(50))
                guard !Task.isCancelled else { return }
                send(.increment)
            }
        }
    }
}

@MainActor
func makeCounterReducer() -> RyzeReduce<CounterState, CounterAction> {
    CounterReducer().eraseToReduce()
}

func collectActions<Action: RyzeAction>(
    from effect: RyzeEffect<Action>
) async -> [Action] {
    var actions = [Action]()

    for await action in effect.actions {
        actions.append(action)
    }

    return actions
}

func settleTasks(iterations: Int = 10) async {
    for _ in 0..<iterations {
        await Task.yield()
    }

    try? await Task.sleep(for: .milliseconds(20))
}
