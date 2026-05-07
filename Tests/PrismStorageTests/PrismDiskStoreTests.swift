import Foundation
import Testing

@testable import PrismStorage

@Suite("DiskStore")
struct PrismDiskStoreTests {
    func makeStore(ttl: TimeInterval? = nil) -> PrismDiskStore {
        PrismDiskStore(
            directory: .custom(
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("PrismDiskTest-\(UUID().uuidString)")
            ),
            subdirectory: "test",
            defaultTTL: ttl
        )
    }

    @Test("Save and load string")
    func saveLoadString() async throws {
        let store = makeStore()
        try await store.save("hello", forKey: "greeting")
        let loaded = try await store.load(String.self, forKey: "greeting")
        #expect(loaded == "hello")
        try await store.clear()
    }

    @Test("Save and load codable")
    func saveLoadCodable() async throws {
        struct Config: Codable, Sendable, Equatable {
            let host: String
            let port: Int
        }
        let store = makeStore()
        let config = Config(host: "localhost", port: 8080)
        try await store.save(config, forKey: "config")
        let loaded = try await store.load(Config.self, forKey: "config")
        #expect(loaded == config)
        try await store.clear()
    }

    @Test("Load missing returns nil")
    func loadMissing() async throws {
        let store = makeStore()
        let result = try await store.load(String.self, forKey: "nope")
        #expect(result == nil)
    }

    @Test("Delete removes file")
    func delete() async throws {
        let store = makeStore()
        try await store.save("temp", forKey: "d")
        try await store.delete(forKey: "d")
        let exists = try await store.exists(forKey: "d")
        #expect(!exists)
    }

    @Test("Exists returns correct value")
    func exists() async throws {
        let store = makeStore()
        #expect(try await !store.exists(forKey: "missing"))
        try await store.save(1, forKey: "present")
        #expect(try await store.exists(forKey: "present"))
        try await store.clear()
    }

    @Test("Clear removes all files")
    func clear() async throws {
        let store = makeStore()
        try await store.save("a", forKey: "k1")
        try await store.save("b", forKey: "k2")
        try await store.clear()
        let keys = try await store.keys()
        #expect(keys.isEmpty)
    }

    @Test("Keys returns stored keys")
    func keys() async throws {
        let store = makeStore()
        try await store.save(1, forKey: "alpha")
        try await store.save(2, forKey: "beta")
        let keys = try await store.keys()
        #expect(keys.contains("alpha"))
        #expect(keys.contains("beta"))
        try await store.clear()
    }

    @Test("TTL expiration")
    func ttlExpiration() async throws {
        let store = makeStore()
        try await store.save("temp", forKey: "exp", ttl: 0.1)
        try await Task.sleep(for: .milliseconds(200))
        let loaded = try await store.load(String.self, forKey: "exp")
        #expect(loaded == nil)
    }

    @Test("Overwrite replaces value")
    func overwrite() async throws {
        let store = makeStore()
        try await store.save("first", forKey: "v")
        try await store.save("second", forKey: "v")
        let loaded = try await store.load(String.self, forKey: "v")
        #expect(loaded == "second")
        try await store.clear()
    }

    @Test("Total size returns bytes")
    func totalSize() async throws {
        let store = makeStore()
        try await store.save("some data here", forKey: "sized")
        let size = try await store.totalSize()
        #expect(size > 0)
        try await store.clear()
    }

    @Test("Prune expired removes old entries")
    func pruneExpired() async throws {
        let store = makeStore()
        try await store.save("keep", forKey: "alive", ttl: 3600)
        try await store.save("remove", forKey: "dead", ttl: 0.1)
        try await Task.sleep(for: .milliseconds(200))
        try await store.pruneExpired()
        let keys = try await store.keys()
        #expect(keys.contains("alive"))
        #expect(!keys.contains("dead"))
        try await store.clear()
    }

    @Test("Quota exceeded throws")
    func quotaExceeded() async throws {
        let store = PrismDiskStore(
            directory: .custom(
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("PrismDiskQuota-\(UUID().uuidString)")
            ),
            subdirectory: "test",
            maxSize: 5
        )
        await #expect(throws: PrismStorageError.self) {
            try await store.save("this string is way too long for the quota", forKey: "big")
        }
    }

    @Test("Default TTL writes meta on save")
    func defaultTTLSave() async throws {
        let store = makeStore(ttl: 3600)
        try await store.save("value", forKey: "ttlkey")
        #expect(try await store.exists(forKey: "ttlkey"))
        let loaded = try await store.load(String.self, forKey: "ttlkey")
        #expect(loaded == "value")
        try await store.clear()
    }

    @Test("Default TTL expiration")
    func defaultTTLExpiry() async throws {
        let store = makeStore(ttl: 0.1)
        try await store.save("temp", forKey: "expiring")
        try await Task.sleep(for: .milliseconds(200))
        let loaded = try await store.load(String.self, forKey: "expiring")
        #expect(loaded == nil)
    }

    @Test("Delete non-existent does not throw")
    func deleteNonExistent() async throws {
        let store = makeStore()
        try await store.delete(forKey: "never-existed")
    }

    @Test("Total size empty directory is zero")
    func totalSizeEmpty() async throws {
        let store = makeStore()
        let size = try await store.totalSize()
        #expect(size == 0)
    }

    @Test("Exists returns false for expired key")
    func existsExpired() async throws {
        let store = makeStore()
        try await store.save("temp", forKey: "exp", ttl: 0.1)
        try await Task.sleep(for: .milliseconds(200))
        #expect(try await !store.exists(forKey: "exp"))
    }

    @Test("Directory types resolve URLs")
    func directoryTypes() {
        let docs = PrismDiskStore.Directory.documents.url
        let caches = PrismDiskStore.Directory.caches.url
        let appSupport = PrismDiskStore.Directory.applicationSupport.url
        let temp = PrismDiskStore.Directory.temporary.url
        let custom = PrismDiskStore.Directory.custom(URL(fileURLWithPath: "/tmp")).url
        #expect(docs.path.contains("Documents"))
        #expect(caches.path.contains("Caches"))
        #expect(appSupport.path.contains("Application Support"))
        #expect(!temp.path.isEmpty)
        #expect(custom.path == "/tmp")
    }

    @Test("Keys returns empty for nonexistent directory")
    func keysEmptyDir() async throws {
        let store = PrismDiskStore(
            directory: .custom(
                FileManager.default.temporaryDirectory
                    .appendingPathComponent("PrismDiskNonExist-\(UUID().uuidString)")
            ),
            subdirectory: "nonexistent-\(UUID().uuidString)"
        )
        try await store.clear()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("PrismDiskNonExist-\(UUID().uuidString)")
            .appendingPathComponent("nonexistent-\(UUID().uuidString)")
        try? FileManager.default.removeItem(at: url)
    }
}
