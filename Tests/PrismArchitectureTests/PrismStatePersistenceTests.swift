import Foundation
import Testing

@testable import PrismArchitecture

// MARK: - Test Helpers

private struct PersistenceTestState: Codable, Equatable, Sendable, PrismState {
    let name: String
    let count: Int
}

// MARK: - PrismDiskPersistence Tests

@Suite("Disk Persistence")
struct DiskPersistenceTests {
    private let directory: URL
    private let persistence: PrismDiskPersistence

    init() {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("DiskPersistenceTests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.directory = dir
        self.persistence = PrismDiskPersistence(directory: dir)
    }

    private func cleanUp() {
        try? FileManager.default.removeItem(at: directory)
    }

    @Test
    func saveAndLoadRoundTrip() throws {
        defer { cleanUp() }
        let state = PersistenceTestState(name: "alpha", count: 42)

        try persistence.save(state, key: "roundtrip")
        let loaded: PersistenceTestState? = try persistence.load(key: "roundtrip")

        #expect(loaded == state)
    }

    @Test
    func loadReturnsNilForNonExistentKey() throws {
        defer { cleanUp() }
        let loaded: PersistenceTestState? = try persistence.load(key: "missing-key")

        #expect(loaded == nil)
    }

    @Test
    func clearRemovesSavedData() throws {
        defer { cleanUp() }
        let state = PersistenceTestState(name: "beta", count: 7)

        try persistence.save(state, key: "clearable")
        try persistence.clear(key: "clearable")
        let loaded: PersistenceTestState? = try persistence.load(key: "clearable")

        #expect(loaded == nil)
    }

    @Test
    func clearDoesNotThrowForNonExistentKey() throws {
        defer { cleanUp() }
        try persistence.clear(key: "never-saved")
    }
}

// MARK: - PrismUserDefaultsPersistence Tests

@Suite("UserDefaults Persistence")
struct UserDefaultsPersistenceTests {
    private let suiteName: String
    private let persistence: PrismUserDefaultsPersistence

    init() {
        let suite = "com.prism.tests.persistence.\(UUID().uuidString)"
        self.suiteName = suite
        self.persistence = PrismUserDefaultsPersistence(suiteName: suite)
    }

    private func cleanUp() {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }

    @Test
    func saveAndLoadRoundTrip() throws {
        defer { cleanUp() }
        let state = PersistenceTestState(name: "gamma", count: 99)

        try persistence.save(state, key: "roundtrip")
        let loaded: PersistenceTestState? = try persistence.load(key: "roundtrip")

        #expect(loaded == state)
    }

    @Test
    func loadReturnsNilForMissingKey() throws {
        defer { cleanUp() }
        let loaded: PersistenceTestState? = try persistence.load(key: "absent-key")

        #expect(loaded == nil)
    }

    @Test
    func clearRemovesEntry() throws {
        defer { cleanUp() }
        let state = PersistenceTestState(name: "delta", count: 3)

        try persistence.save(state, key: "removable")
        try persistence.clear(key: "removable")
        let loaded: PersistenceTestState? = try persistence.load(key: "removable")

        #expect(loaded == nil)
    }
}

// MARK: - PrismPersistenceError Tests

@Suite("Persistence Error")
struct PersistenceErrorTests {
    @Test
    func keychainWriteFailedCarriesStatus() {
        let error = PrismPersistenceError.keychainWriteFailed(-25299)

        if case .keychainWriteFailed(let status) = error {
            #expect(status == -25299)
        } else {
            Issue.record("Expected .keychainWriteFailed")
        }
    }

    @Test
    func keychainReadFailedCarriesStatus() {
        let error = PrismPersistenceError.keychainReadFailed(-25300)

        if case .keychainReadFailed(let status) = error {
            #expect(status == -25300)
        } else {
            Issue.record("Expected .keychainReadFailed")
        }
    }

    @Test
    func keychainDeleteFailedCarriesStatus() {
        let error = PrismPersistenceError.keychainDeleteFailed(-25244)

        if case .keychainDeleteFailed(let status) = error {
            #expect(status == -25244)
        } else {
            Issue.record("Expected .keychainDeleteFailed")
        }
    }

    @Test
    func allErrorCasesMatchExpectedStatus() {
        let write = PrismPersistenceError.keychainWriteFailed(-25299)
        let read = PrismPersistenceError.keychainReadFailed(-25300)
        let delete = PrismPersistenceError.keychainDeleteFailed(-25244)

        if case .keychainWriteFailed(let s) = write { #expect(s == -25299) }
        if case .keychainReadFailed(let s) = read { #expect(s == -25300) }
        if case .keychainDeleteFailed(let s) = delete { #expect(s == -25244) }
    }
}

// MARK: - PrismDiskPersistence default init

@Suite("Disk Persistence Default Init")
struct DiskPersistenceDefaultInitTests {
    @Test
    func defaultInitUsesDocumentsDirectory() throws {
        let persistence = PrismDiskPersistence()
        let state = PersistenceTestState(name: "default-init", count: 1)
        let key = "default_init_test_\(UUID().uuidString)"

        try persistence.save(state, key: key)
        let loaded: PersistenceTestState? = try persistence.load(key: key)
        #expect(loaded == state)
        try persistence.clear(key: key)
    }
}

// MARK: - PrismUserDefaultsPersistence default init

@Suite("UserDefaults Persistence Default Init")
struct UserDefaultsPersistenceDefaultInitTests {
    @Test
    func defaultInitUsesStandardDefaults() throws {
        let persistence = PrismUserDefaultsPersistence()
        let state = PersistenceTestState(name: "std", count: 77)
        let key = "std_default_test_\(UUID().uuidString)"

        try persistence.save(state, key: key)
        let loaded: PersistenceTestState? = try persistence.load(key: key)
        #expect(loaded == state)
        try persistence.clear(key: key)
    }
}

// MARK: - PrismPersistMiddleware

private enum PersistAction: PrismAction {
    case save
    case any
}

@Suite("PrismPersistMiddleware")
@MainActor
struct PrismPersistMiddlewareTests {
    @Test
    func middlewarePersistsStateOnEveryAction() async throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PersistMiddlewareTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let strategy = PrismDiskPersistence(directory: tempDir)
        let middleware: PrismPersistMiddleware<PersistenceTestState, PersistAction> =
            PrismPersistMiddleware(strategy: strategy, key: "mw_state")

        let state = PersistenceTestState(name: "mw", count: 42)
        let effect = middleware.run(state: state, action: .any)
        let actions = await collectActions(from: effect)
        #expect(actions.isEmpty)

        let loaded: PersistenceTestState? = try strategy.load(key: "mw_state")
        #expect(loaded == state)
    }

    @Test
    func prismPersistFreeFunction() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("PersistFuncTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let strategy = PrismDiskPersistence(directory: tempDir)
        let middleware: PrismPersistMiddleware<PersistenceTestState, PersistAction> =
            prismPersist(strategy: strategy, key: "func_state")

        let state = PersistenceTestState(name: "fn", count: 99)
        _ = middleware.run(state: state, action: .save)

        let loaded: PersistenceTestState? = try strategy.load(key: "func_state")
        #expect(loaded == state)
    }

    @Test
    func middlewareReturnsNoneEffect() async {
        let strategy = PrismDiskPersistence(
            directory: FileManager.default.temporaryDirectory
        )
        let middleware: PrismPersistMiddleware<PersistenceTestState, PersistAction> =
            PrismPersistMiddleware(strategy: strategy, key: "effect_test")

        let effect = middleware.run(
            state: PersistenceTestState(name: "e", count: 0),
            action: .any
        )
        let actions = await collectActions(from: effect)
        #expect(actions.isEmpty)
    }
}

// MARK: - PrismKeychainPersistence save/load

private let _isNotCI = ProcessInfo.processInfo.environment["CI"] == nil

@Suite(
    "Keychain Persistence Full",
    .enabled(if: _isNotCI, "Keychain not available in CI sandbox")
)
struct KeychainPersistenceFullTests {
    @Test
    func saveAndLoadRoundTrip() throws {
        let persistence = PrismKeychainPersistence()
        let key = "kc_roundtrip_\(UUID().uuidString)"
        let state = PersistenceTestState(name: "kc", count: 55)

        try persistence.save(state, key: key)
        let loaded: PersistenceTestState? = try persistence.load(key: key)
        #expect(loaded == state)
        try persistence.clear(key: key)
    }

    @Test
    func loadReturnsNilForMissingKey() throws {
        let persistence = PrismKeychainPersistence()
        let loaded: PersistenceTestState? = try persistence.load(
            key: "kc_missing_\(UUID().uuidString)"
        )
        #expect(loaded == nil)
    }

    @Test
    func saveOverwritesExistingItem() throws {
        let persistence = PrismKeychainPersistence()
        let key = "kc_overwrite_\(UUID().uuidString)"

        try persistence.save(PersistenceTestState(name: "v1", count: 1), key: key)
        try persistence.save(PersistenceTestState(name: "v2", count: 2), key: key)
        let loaded: PersistenceTestState? = try persistence.load(key: key)
        #expect(loaded?.name == "v2")
        try persistence.clear(key: key)
    }
}
