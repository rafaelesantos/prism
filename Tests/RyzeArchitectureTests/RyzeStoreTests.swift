import RyzeUI
import Testing

@testable import RyzeArchitecture

@MainActor
struct RyzeStoreTests {
    @Test
    func sendMutatesStateImmediately() {
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )

        store.send(.increment)

        #expect(store.state.count == 1)
    }

    @Test
    func reduceInitializerBuildsStoreFromClosure() {
        let store = RyzeStore<CounterState, CounterAction>(initialState: CounterState()) { state, action in
            guard action == .increment else { return .none }
            state.count = 10
            return .none
        }

        store.send(.increment)

        #expect(store.state.count == 10)
    }

    @Test
    func reducerEffectsDispatchFollowUpActions() async {
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )

        store.send(.startReducerEffect)
        await settleTasks()

        #expect(store.state.count == 2)
    }

    @Test
    func middlewareEffectsCanEmitAdditionalActions() async {
        let middleware = RyzeSideEffect<CounterState, CounterAction> { _, action in
            switch action {
            case .startMiddlewareEffect:
                .send(.setReadyTitle)
            default:
                .none
            }
        }
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer(),
            middleware: middleware
        )

        store.send(.startMiddlewareEffect)
        await settleTasks()

        #expect(store.state.title == "Ready")
    }

    @Test
    func scopedStoresStayInSyncAndMapLocalActions() {
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )
        let countStore = store.scope(state: \.count)
        let titleStore = store.scope(
            state: \.title,
            action: CounterAction.setTitle
        )

        countStore.send(.increment)
        titleStore.send("Scoped")

        #expect(store.state.count == 1)
        #expect(store.state.title == "Scoped")
        #expect(countStore.state == 1)
        #expect(titleStore.state == "Scoped")

        store.send(.increment)

        #expect(countStore.state == 2)
        #expect(titleStore.state == "Scoped")
    }

    @Test
    func scopedStoreCleanupReleasesObserversSafely() async {
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )
        weak var weakScopedStore: RyzeStore<Int, CounterAction>?

        do {
            var scopedStore: RyzeStore<Int, CounterAction>? = store.scope(state: \.count)
            weakScopedStore = scopedStore

            #expect(scopedStore?.state == 0)

            scopedStore = nil
        }

        await settleTasks()
        store.send(.increment)

        #expect(weakScopedStore == nil)
        #expect(store.state.count == 1)
    }

    @Test
    func bindingHelpersSendActionsInsteadOfMutatingStateDirectly() async {
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )
        let titleBinding = store.binding(
            for: \.title,
            send: CounterAction.setTitle
        )

        titleBinding.wrappedValue = "Partial"
        await settleTasks()

        #expect(store.state.title == "Partial")
    }

    @Test
    func cancelEffectsStopsLongRunningWork() async {
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )

        store.send(.longRunningEffect)
        store.cancelEffects()

        try? await Task.sleep(for: .milliseconds(80))

        #expect(store.state.count == 0)
    }

    @Test
    func dispatchCompatibilityMethodDelegatesToSend() async {
        let store = RyzeStore(
            initialState: CounterState(),
            reducer: makeCounterReducer()
        )

        await store.dispatch(action: .increment)

        #expect(store.state.count == 1)
    }
}
