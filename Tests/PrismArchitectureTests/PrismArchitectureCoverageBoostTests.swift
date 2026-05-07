import Foundation
import Testing

@testable import PrismArchitecture

// MARK: - Test Helpers (local to this file)

private struct SimpleState: PrismState, Equatable, Codable {
    var value: Int = 0
    var label: String = ""
}

private enum SimpleAction: PrismAction, Equatable {
    case increment
    case setLabel(String)
}

/// Thread-safe collector for use in @Sendable closures.
private final class SendableCollector<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var _values: [T] = []

    var values: [T] {
        lock.withLock { _values }
    }

    var count: Int {
        lock.withLock { _values.count }
    }

    func append(_ value: T) {
        lock.withLock { _values.append(value) }
    }
}

/// Thread-safe counter for use in @Sendable closures.
private final class SendableCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Int = 0

    var value: Int {
        lock.withLock { _value }
    }

    func increment() {
        lock.withLock { _value += 1 }
    }
}

/// Thread-safe flag for use in @Sendable closures.
private final class SendableFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Bool = false

    var value: Bool {
        lock.withLock { _value }
    }

    func set() {
        lock.withLock { _value = true }
    }
}

@MainActor
private func makeSimpleReducer() -> PrismReduce<SimpleState, SimpleAction> {
    PrismReduce { state, action in
        switch action {
        case .increment:
            state.value += 1
            return .none
        case .setLabel(let text):
            state.label = text
            return .none
        }
    }
}

// MARK: - PrismDerivedStore Tests

@Suite("PrismDerivedStore Coverage Boost")
@MainActor
struct PrismDerivedStoreCoverageBoostTests {

    @Test
    func initSetsInitialValueFromTransform() {
        let parentState = SimpleState(value: 42, label: "hello")
        let derived = PrismDerivedStore<SimpleState, Int>(
            initialState: parentState,
            transform: { $0.value }
        )
        #expect(derived.value == 42)
    }

    @Test
    func updateChangesValueWhenTransformResultDiffers() {
        let derived = PrismDerivedStore<SimpleState, Int>(
            initialState: SimpleState(value: 0),
            transform: { $0.value }
        )
        #expect(derived.value == 0)

        derived.update(from: SimpleState(value: 10))
        #expect(derived.value == 10)
    }

    @Test
    func updateDoesNotChangeValueWhenTransformResultIsSame() {
        let derived = PrismDerivedStore<SimpleState, Int>(
            initialState: SimpleState(value: 5),
            transform: { $0.value }
        )
        #expect(derived.value == 5)

        derived.update(from: SimpleState(value: 5))
        #expect(derived.value == 5)
    }

    @Test
    func valuePropertyReflectsLatestUpdate() {
        let derived = PrismDerivedStore<SimpleState, String>(
            initialState: SimpleState(value: 0, label: "a"),
            transform: { $0.label }
        )
        #expect(derived.value == "a")

        derived.update(from: SimpleState(value: 0, label: "b"))
        #expect(derived.value == "b")

        derived.update(from: SimpleState(value: 0, label: "c"))
        #expect(derived.value == "c")
    }
}

// MARK: - PrismStoreScope Tests

@Suite("PrismStoreScope Coverage")
@MainActor
struct PrismStoreScopeTests {

    @Test
    func initSetsLocalStateFromParent() {
        let parentState = SimpleState(value: 7, label: "scope")
        let scope = PrismStoreScope<SimpleState, Int, SimpleAction>(
            parentState: parentState,
            toLocalState: { $0.value },
            sendAction: { _ in }
        )
        #expect(scope.state == 7)
    }

    @Test
    func sendForwardsActionToParent() {
        var receivedActions: [SimpleAction] = []
        let scope = PrismStoreScope<SimpleState, Int, SimpleAction>(
            parentState: SimpleState(value: 0),
            toLocalState: { $0.value },
            sendAction: { action in receivedActions.append(action) }
        )

        scope.send(.increment)
        scope.send(.setLabel("test"))

        #expect(receivedActions.count == 2)
        #expect(receivedActions[0] == .increment)
        #expect(receivedActions[1] == .setLabel("test"))
    }

    @Test
    func updateChangesStateWhenDifferent() {
        let scope = PrismStoreScope<SimpleState, Int, SimpleAction>(
            parentState: SimpleState(value: 0),
            toLocalState: { $0.value },
            sendAction: { _ in }
        )
        #expect(scope.state == 0)

        scope.update(from: SimpleState(value: 99))
        #expect(scope.state == 99)
    }

    @Test
    func updateDoesNotChangeStateWhenSame() {
        let scope = PrismStoreScope<SimpleState, Int, SimpleAction>(
            parentState: SimpleState(value: 3),
            toLocalState: { $0.value },
            sendAction: { _ in }
        )
        #expect(scope.state == 3)

        scope.update(from: SimpleState(value: 3))
        #expect(scope.state == 3)
    }
}

// MARK: - PrismStore.derive() Tests

@Suite("PrismStore derive Extension Coverage")
@MainActor
struct PrismStoreDeriveTests {

    @Test
    func deriveReturnsCorrectInitialValue() {
        let store = PrismStore(
            initialState: SimpleState(value: 10, label: "derive"),
            reducer: makeSimpleReducer()
        )
        let derived = store.derive { $0.value }

        #expect(derived.value == 10)
    }

    @Test
    func derivedStoreReflectsTransformOfCurrentState() {
        let store = PrismStore(
            initialState: SimpleState(value: 0, label: "start"),
            reducer: makeSimpleReducer()
        )
        let derived = store.derive { $0.label }
        #expect(derived.value == "start")

        store.send(.setLabel("end"))
        derived.update(from: store.state)
        #expect(derived.value == "end")
    }

    @Test
    func derivedStoreWithComplexTransform() {
        let store = PrismStore(
            initialState: SimpleState(value: 5, label: "x"),
            reducer: makeSimpleReducer()
        )
        let derived = store.derive { "\($0.label)_\($0.value)" }
        #expect(derived.value == "x_5")
    }
}

// MARK: - PrismLoggingMiddleware Tests

@Suite("PrismLoggingMiddleware Coverage")
struct PrismLoggingMiddlewareTests {

    @Test
    func initWithDefaultLoggerDoesNotCrash() {
        let middleware = PrismLoggingMiddleware()
        _ = middleware
    }

    @Test
    func initWithCustomLoggerCapturesMessages() async {
        let loggedMessages = SendableCollector<String>()
        let middleware = PrismLoggingMiddleware { message in
            loggedMessages.append(message)
        }

        let nextCalled = SendableFlag()
        await middleware.handle(
            state: "testState",
            action: "testAction",
            next: { (_: String) in nextCalled.set() }
        )

        #expect(loggedMessages.count == 1)
        #expect(loggedMessages.values[0].contains("testAction"))
        #expect(nextCalled.value)
    }

    @Test
    func handleCallsNextWithOriginalAction() async {
        let receivedActions = SendableCollector<String>()
        let middleware = PrismLoggingMiddleware { _ in }

        await middleware.handle(
            state: 42,
            action: "forward_me",
            next: { (action: String) in receivedActions.append(action) }
        )

        #expect(receivedActions.count == 1)
        #expect(receivedActions.values[0] == "forward_me")
    }

    @Test
    func handleLogsStateType() async {
        let loggedMessages = SendableCollector<String>()
        let middleware = PrismLoggingMiddleware { msg in loggedMessages.append(msg) }

        await middleware.handle(
            state: SimpleState(value: 1, label: ""),
            action: "someAction",
            next: { (_: String) in }
        )

        #expect(loggedMessages.count == 1)
        #expect(loggedMessages.values[0].contains("SimpleState"))
    }
}

// MARK: - PrismThrottleMiddleware Tests

@Suite("PrismThrottleMiddleware Coverage")
struct PrismThrottleMiddlewareTests {

    @Test
    func firstActionIsForwarded() async {
        let throttle = PrismThrottleMiddleware(interval: .milliseconds(100))
        let forwarded = SendableFlag()

        await throttle.handle(
            state: "s",
            action: "tap",
            next: { (_: String) in forwarded.set() }
        )

        #expect(forwarded.value)
    }

    @Test
    func duplicateActionWithinIntervalIsThrottled() async {
        let throttle = PrismThrottleMiddleware(interval: .milliseconds(100))
        let callCount = SendableCounter()

        await throttle.handle(
            state: "s",
            action: "tap",
            next: { (_: String) in callCount.increment() }
        )
        #expect(callCount.value == 1)

        await throttle.handle(
            state: "s",
            action: "tap",
            next: { (_: String) in callCount.increment() }
        )
        #expect(callCount.value == 1)
    }

    @Test
    func actionIsAllowedAfterIntervalPasses() async throws {
        let throttle = PrismThrottleMiddleware(interval: .milliseconds(100))
        let callCount = SendableCounter()

        await throttle.handle(
            state: "s",
            action: "tap",
            next: { (_: String) in callCount.increment() }
        )
        #expect(callCount.value == 1)

        try await Task.sleep(for: .milliseconds(150))

        await throttle.handle(
            state: "s",
            action: "tap",
            next: { (_: String) in callCount.increment() }
        )
        #expect(callCount.value == 2)
    }

    @Test
    func differentActionsAreNotThrottled() async {
        let throttle = PrismThrottleMiddleware(interval: .milliseconds(100))
        let callCount = SendableCounter()

        await throttle.handle(
            state: "s",
            action: "actionA",
            next: { (_: String) in callCount.increment() }
        )
        await throttle.handle(
            state: "s",
            action: "actionB",
            next: { (_: String) in callCount.increment() }
        )

        #expect(callCount.value == 2)
    }

    @Test
    func defaultIntervalIs300ms() async {
        let throttle = PrismThrottleMiddleware()
        let callCount = SendableCounter()

        await throttle.handle(
            state: 0,
            action: "x",
            next: { (_: String) in callCount.increment() }
        )
        await throttle.handle(
            state: 0,
            action: "x",
            next: { (_: String) in callCount.increment() }
        )

        #expect(callCount.value == 1)
    }
}

// MARK: - PrismMiddlewareChain Tests

@Suite("PrismMiddlewareChain Coverage Boost")
struct PrismMiddlewareChainCoverageBoostTests {

    @Test
    func initCreatesEmptyChain() {
        let chain = PrismMiddlewareChain()
        let built = chain.build()
        #expect(built.isEmpty)
    }

    @Test
    func addSingleMiddleware() {
        let chain = PrismMiddlewareChain()
            .add(PrismLoggingMiddleware { _ in })

        let built = chain.build()
        #expect(built.count == 1)
    }

    @Test
    func addMultipleMiddlewares() {
        let chain = PrismMiddlewareChain()
            .add(PrismLoggingMiddleware { _ in })
            .add(PrismThrottleMiddleware(interval: .milliseconds(50)))
            .add(PrismLoggingMiddleware { _ in })

        let built = chain.build()
        #expect(built.count == 3)
    }

    @Test
    func addDoesNotMutateOriginalChain() {
        let original = PrismMiddlewareChain()
        let withOne = original.add(PrismLoggingMiddleware { _ in })

        #expect(original.build().isEmpty)
        #expect(withOne.build().count == 1)
    }

    @Test
    func buildReturnsMiddlewaresInOrder() async {
        let log = SendableCollector<String>()

        let m1 = PrismLoggingMiddleware { _ in log.append("first") }
        let m2 = PrismLoggingMiddleware { _ in log.append("second") }

        let chain = PrismMiddlewareChain()
            .add(m1)
            .add(m2)

        let built = chain.build()
        for middleware in built {
            await middleware.handle(
                state: 0,
                action: "a",
                next: { (_: String) in }
            )
        }

        #expect(log.values == ["first", "second"])
    }
}

// MARK: - PrismDiskPersistence Coverage Boost Tests

@Suite("PrismDiskPersistence Coverage Boost")
struct PrismDiskPersistenceCoverageBoostTests {

    @Test
    func initDefaultDoesNotCrash() {
        _ = PrismDiskPersistence()
    }

    @Test
    func initWithCustomDirectory() {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        _ = PrismDiskPersistence(directory: dir)
    }

    @Test
    func saveAndLoadRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let persistence = PrismDiskPersistence(directory: dir)
        let state = SimpleState(value: 42, label: "disk")

        try persistence.save(state, key: "boost_roundtrip")
        let loaded: SimpleState? = try persistence.load(key: "boost_roundtrip")
        #expect(loaded == state)
    }

    @Test
    func loadNonexistentKeyReturnsNil() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let persistence = PrismDiskPersistence(directory: dir)
        let loaded: SimpleState? = try persistence.load(key: "does_not_exist")
        #expect(loaded == nil)
    }

    @Test
    func clearRemovesFile() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let persistence = PrismDiskPersistence(directory: dir)
        try persistence.save(SimpleState(value: 1, label: "x"), key: "clearme")
        try persistence.clear(key: "clearme")

        let loaded: SimpleState? = try persistence.load(key: "clearme")
        #expect(loaded == nil)
    }

    @Test
    func clearNonexistentKeyDoesNotThrow() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let persistence = PrismDiskPersistence(directory: dir)
        try persistence.clear(key: "never_existed")
    }

    @Test
    func saveOverwritesExistingData() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let persistence = PrismDiskPersistence(directory: dir)
        try persistence.save(SimpleState(value: 1, label: "v1"), key: "overwrite")
        try persistence.save(SimpleState(value: 2, label: "v2"), key: "overwrite")

        let loaded: SimpleState? = try persistence.load(key: "overwrite")
        #expect(loaded == SimpleState(value: 2, label: "v2"))
    }
}

// MARK: - PrismUserDefaultsPersistence Coverage Boost Tests

@Suite("PrismUserDefaultsPersistence Coverage Boost")
struct PrismUserDefaultsPersistenceCoverageBoostTests {

    @Test
    func initDefaultDoesNotCrash() {
        _ = PrismUserDefaultsPersistence()
    }

    @Test
    func initWithSuiteName() {
        _ = PrismUserDefaultsPersistence(suiteName: "com.test.\(UUID().uuidString)")
    }

    @Test
    func saveAndLoadRoundTrip() throws {
        let suite = "com.boost.test.\(UUID().uuidString)"
        let persistence = PrismUserDefaultsPersistence(suiteName: suite)
        defer { UserDefaults().removePersistentDomain(forName: suite) }

        let state = SimpleState(value: 77, label: "defaults")
        try persistence.save(state, key: "boost_ud")
        let loaded: SimpleState? = try persistence.load(key: "boost_ud")
        #expect(loaded == state)
    }

    @Test
    func loadNonexistentKeyReturnsNil() throws {
        let suite = "com.boost.test.\(UUID().uuidString)"
        let persistence = PrismUserDefaultsPersistence(suiteName: suite)
        defer { UserDefaults().removePersistentDomain(forName: suite) }

        let loaded: SimpleState? = try persistence.load(key: "nope")
        #expect(loaded == nil)
    }

    @Test
    func clearRemovesEntry() throws {
        let suite = "com.boost.test.\(UUID().uuidString)"
        let persistence = PrismUserDefaultsPersistence(suiteName: suite)
        defer { UserDefaults().removePersistentDomain(forName: suite) }

        try persistence.save(SimpleState(value: 1, label: "gone"), key: "removable")
        try persistence.clear(key: "removable")
        let loaded: SimpleState? = try persistence.load(key: "removable")
        #expect(loaded == nil)
    }

    @Test
    func saveOverwritesExistingData() throws {
        let suite = "com.boost.test.\(UUID().uuidString)"
        let persistence = PrismUserDefaultsPersistence(suiteName: suite)
        defer { UserDefaults().removePersistentDomain(forName: suite) }

        try persistence.save(SimpleState(value: 1, label: "old"), key: "ow")
        try persistence.save(SimpleState(value: 2, label: "new"), key: "ow")

        let loaded: SimpleState? = try persistence.load(key: "ow")
        #expect(loaded == SimpleState(value: 2, label: "new"))
    }
}

// MARK: - PrismPersistenceError Coverage Boost Tests

@Suite("PrismPersistenceError Coverage Boost")
struct PrismPersistenceErrorCoverageBoostTests {

    @Test
    func allCasesExist() {
        let write = PrismPersistenceError.keychainWriteFailed(-1)
        let read = PrismPersistenceError.keychainReadFailed(-2)
        let delete = PrismPersistenceError.keychainDeleteFailed(-3)

        if case .keychainWriteFailed(let s) = write { #expect(s == -1) }
        if case .keychainReadFailed(let s) = read { #expect(s == -2) }
        if case .keychainDeleteFailed(let s) = delete { #expect(s == -3) }
    }

    @Test
    func errorsConformToErrorProtocol() {
        let error: any Error = PrismPersistenceError.keychainWriteFailed(-25299)
        #expect(error is PrismPersistenceError)
    }

    @Test
    func errorsAreSendable() {
        let error: any Sendable = PrismPersistenceError.keychainReadFailed(-25300)
        #expect(error is PrismPersistenceError)
    }
}

// MARK: - PrismPersistMiddleware Coverage Boost Tests

@Suite("PrismPersistMiddleware Coverage Boost")
@MainActor
struct PrismPersistMiddlewareCoverageBoostTests {

    @Test
    func initCreatesMiddleware() {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let strategy = PrismDiskPersistence(directory: dir)
        let _: PrismPersistMiddleware<SimpleState, SimpleAction> =
            PrismPersistMiddleware(strategy: strategy, key: "init_test")
    }

    @Test
    func runSavesState() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let strategy = PrismDiskPersistence(directory: dir)
        let middleware: PrismPersistMiddleware<SimpleState, SimpleAction> =
            PrismPersistMiddleware(strategy: strategy, key: "run_test")

        let state = SimpleState(value: 55, label: "persisted")
        _ = middleware.run(state: state, action: .increment)

        let loaded: SimpleState? = try strategy.load(key: "run_test")
        #expect(loaded == state)
    }

    @Test
    func runReturnsNoneEffect() async {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let strategy = PrismDiskPersistence(directory: dir)
        let middleware: PrismPersistMiddleware<SimpleState, SimpleAction> =
            PrismPersistMiddleware(strategy: strategy, key: "effect_test")

        let effect = middleware.run(
            state: SimpleState(value: 0, label: ""),
            action: .increment
        )
        let actions = await collectActions(from: effect)
        #expect(actions.isEmpty)
    }
}

// MARK: - prismPersist free function Coverage Boost Tests

@Suite("prismPersist Free Function Coverage Boost")
@MainActor
struct PrismPersistFreeFunctionCoverageBoostTests {

    @Test
    func freeFunctionCreatesMiddleware() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let strategy = PrismDiskPersistence(directory: dir)
        let middleware: PrismPersistMiddleware<SimpleState, SimpleAction> =
            prismPersist(strategy: strategy, key: "free_fn")

        let state = SimpleState(value: 88, label: "fn")
        _ = middleware.run(state: state, action: .setLabel("saved"))

        let loaded: SimpleState? = try strategy.load(key: "free_fn")
        #expect(loaded == state)
    }
}
