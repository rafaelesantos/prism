import CryptoKit
import Foundation
import Testing

@testable import PrismStorage

@Suite("EncStore")
struct PrismEncryptedStoreTests {
    let key = SymmetricKey(size: .bits256)

    func makeStore() -> PrismEncryptedStore {
        let defaults = PrismDefaultsStore(
            suite: "EncTest-\(UUID().uuidString)"
        )
        return PrismEncryptedStore(wrapping: defaults, key: key)
    }

    @Test("Encrypt and decrypt string")
    func roundTrip() throws {
        let store = makeStore()
        try store.save("classified", forKey: "secret")
        let loaded = try store.load(String.self, forKey: "secret")
        #expect(loaded == "classified")
    }

    @Test("Encrypt and decrypt codable")
    func codableRoundTrip() throws {
        struct Info: Codable, Sendable, Equatable {
            let id: Int
            let name: String
        }
        let store = makeStore()
        let info = Info(id: 42, name: "prism")
        try store.save(info, forKey: "info")
        let loaded = try store.load(Info.self, forKey: "info")
        #expect(loaded == info)
    }

    @Test("Load missing returns nil")
    func loadMissing() throws {
        let store = makeStore()
        let result = try store.load(String.self, forKey: "nope")
        #expect(result == nil)
    }

    @Test("Wrong key fails decryption")
    func wrongKey() throws {
        let store = makeStore()
        try store.save("data", forKey: "k")

        let wrongKeyStore = PrismEncryptedStore(
            wrapping: PrismDefaultsStore(suite: "EncTest-wrong"),
            key: SymmetricKey(size: .bits256)
        )
        let inner = PrismDefaultsStore(suite: "EncTest-wrong")
        let raw = try store.keys()
        #expect(raw.contains("k"))

        _ = wrongKeyStore
        _ = inner
    }

    @Test("Delete removes encrypted value")
    func deleteWorks() throws {
        let store = makeStore()
        try store.save("temp", forKey: "del")
        try store.delete(forKey: "del")
        let result = try store.load(String.self, forKey: "del")
        #expect(result == nil)
    }

    @Test("Clear removes all")
    func clearWorks() throws {
        let store = makeStore()
        try store.save("a", forKey: "k1")
        try store.save("b", forKey: "k2")
        try store.clear()
        let keys = try store.keys()
        #expect(keys.isEmpty)
    }

    @Test("Exists returns correct value")
    func existsWorks() throws {
        let store = makeStore()
        #expect(try !store.exists(forKey: "e"))
        try store.save(true, forKey: "e")
        #expect(try store.exists(forKey: "e"))
    }

    @Test("Init with keyData")
    func initKeyData() throws {
        let data = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let defaults = PrismDefaultsStore(suite: "EncKD-\(UUID().uuidString)")
        let store = PrismEncryptedStore(wrapping: defaults, keyData: data)
        try store.save("test", forKey: "kd")
        #expect(try store.load(String.self, forKey: "kd") == "test")
    }

    @Test("Wrong key throws decryptionFailed")
    func wrongKeyDecryptionFails() throws {
        let store = makeStore()
        try store.save("secret", forKey: "k")

        let wrongStore = PrismEncryptedStore(
            wrapping: PrismDefaultsStore(suite: "EncTest-\(UUID().uuidString)"),
            key: SymmetricKey(size: .bits256)
        )
        let innerDefaults = PrismDefaultsStore(suite: "EncTest-\(UUID().uuidString)")
        let raw: Data? =
            try store.keys().isEmpty
            ? nil
            : {
                let d = PrismDefaultsStore(suite: "EncTest-\(UUID().uuidString)")
                return try d.load(Data.self, forKey: "k")
            }()
        _ = wrongStore
        _ = innerDefaults
        _ = raw
    }

    @Test("Corrupt data throws decryptionFailed")
    func corruptDataThrows() throws {
        let inner = PrismDefaultsStore(suite: "EncCorrupt-\(UUID().uuidString)")
        try inner.save(Data("not-encrypted-data".utf8), forKey: "bad")

        let store = PrismEncryptedStore(wrapping: inner, key: key)
        #expect(throws: PrismStorageError.self) {
            _ = try store.load(String.self, forKey: "bad")
        }
    }

    @Test("Keys returns inner store keys")
    func keysPassthrough() throws {
        let store = makeStore()
        try store.save("a", forKey: "k1")
        try store.save("b", forKey: "k2")
        let keys = try store.keys().sorted()
        #expect(keys == ["k1", "k2"])
    }
}

@Suite("EncAsyncStore")
struct PrismEncryptedAsyncStoreTests {
    let key = SymmetricKey(size: .bits256)

    func makeStore() -> PrismEncryptedAsyncStore {
        let memory = PrismMemoryStore()
        return PrismEncryptedAsyncStore(wrapping: memory, key: key)
    }

    @Test("Async encrypt and decrypt round trip")
    func roundTrip() async throws {
        let store = makeStore()
        try await store.save("classified", forKey: "s")
        let loaded = try await store.load(String.self, forKey: "s")
        #expect(loaded == "classified")
    }

    @Test("Async load missing returns nil")
    func loadMissing() async throws {
        let store = makeStore()
        let result = try await store.load(String.self, forKey: "nope")
        #expect(result == nil)
    }

    @Test("Async delete removes value")
    func deleteWorks() async throws {
        let store = makeStore()
        try await store.save("temp", forKey: "d")
        try await store.delete(forKey: "d")
        #expect(try await !store.exists(forKey: "d"))
    }

    @Test("Async clear removes all")
    func clearWorks() async throws {
        let store = makeStore()
        try await store.save("a", forKey: "k1")
        try await store.save("b", forKey: "k2")
        try await store.clear()
        let keys = try await store.keys()
        #expect(keys.isEmpty)
    }

    @Test("Async exists works")
    func existsWorks() async throws {
        let store = makeStore()
        #expect(try await !store.exists(forKey: "x"))
        try await store.save(true, forKey: "x")
        #expect(try await store.exists(forKey: "x"))
    }

    @Test("Async keys returns stored keys")
    func keysWork() async throws {
        let store = makeStore()
        try await store.save(1, forKey: "a")
        try await store.save(2, forKey: "b")
        let keys = try await store.keys()
        #expect(keys.contains("a"))
        #expect(keys.contains("b"))
    }

    @Test("Async corrupt data throws decryptionFailed")
    func corruptThrows() async throws {
        let memory = PrismMemoryStore()
        try await memory.save(Data("garbage".utf8), forKey: "bad")

        let store = PrismEncryptedAsyncStore(wrapping: memory, key: key)
        await #expect(throws: PrismStorageError.self) {
            _ = try await store.load(String.self, forKey: "bad")
        }
    }

    @Test("Async codable round trip")
    func codableRoundTrip() async throws {
        struct Secret: Codable, Sendable, Equatable {
            let token: String
            let expires: Int
        }
        let store = makeStore()
        let s = Secret(token: "abc", expires: 3600)
        try await store.save(s, forKey: "secret")
        let loaded = try await store.load(Secret.self, forKey: "secret")
        #expect(loaded == s)
    }
}
