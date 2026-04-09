import Testing

@testable import RyzeArchitecture

@MainActor
struct RyzeReducerAndMiddlewareTests {
    @Test
    func combinedReducersMutateStateAndMergeEffects() async {
        let incrementReducer = RyzeReduce<CounterState, CounterAction> { state, action in
            guard action == .increment else { return .none }
            state.count += 1
            return .send(.setReadyTitle)
        }
        let titleReducer = RyzeReduce<CounterState, CounterAction> { state, action in
            guard action == .setReadyTitle else { return .none }
            state.title = "Ready"
            return .none
        }
        let reducer = RyzeReduce.combine(
            incrementReducer,
            titleReducer
        )
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: reducer
        )

        store.send(.increment)
        await settleTasks()

        #expect(store.state.count == 1)
        #expect(store.state.title == "Ready")
    }

    @Test
    func combinedMiddlewaresMergeTheirEffects() async {
        let first = RyzeSideEffect<CounterState, CounterAction> { _, action in
            guard action == .startMiddlewareEffect else { return .none }
            return .send(.increment)
        }
        let second = RyzeSideEffect<CounterState, CounterAction> { _, action in
            guard action == .startMiddlewareEffect else { return .none }
            return .send(.setReadyTitle)
        }
        let middleware = RyzeSideEffect.combine(
            first,
            second
        )
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer(),
            middleware: middleware
        )

        store.send(.startMiddlewareEffect)
        await settleTasks()

        #expect(store.state.count == 1)
        #expect(store.state.title == "Ready")
    }

    @Test
    func erasedMiddlewareAndNoneMiddlewareBehaveAsExpected() async {
        let noneEffect = await collectActions(
            from: AnyRyzeMiddleware(
                RyzeSideEffect<CounterState, CounterAction>.none
            ).run(
                state: CounterState(),
                action: .increment
            )
        )
        let middleware = AnyRyzeMiddleware(
            RyzeSideEffect<CounterState, CounterAction> { _, action in
                guard action == .startMiddlewareEffect else { return .none }
                return .send(.setReadyTitle)
            }
        )
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer(),
            middleware: middleware
        )

        store.send(.startMiddlewareEffect)
        await settleTasks()

        #expect(noneEffect.isEmpty)
        #expect(store.state.title == "Ready")
    }
}
