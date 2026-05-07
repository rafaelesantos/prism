import Foundation
import Testing

@testable import PrismStorage

@Suite("CmpStore")
struct PrismCompressedStoreTests {
    func makeStore(
        algorithm: NSData.CompressionAlgorithm = .lzfse
    ) -> PrismCompressedStore {
        let defaults = PrismDefaultsStore(
            suite: "CmpTest-\(UUID().uuidString)"
        )
        return PrismCompressedStore(wrapping: defaults, algorithm: algorithm)
    }

    @Test("Compress and decompress string")
    func roundTrip() throws {
        let store = makeStore()
        let text = String(repeating: "PrismStorage rocks! ", count: 100)
        try store.save(text, forKey: "big")
        let loaded = try store.load(String.self, forKey: "big")
        #expect(loaded == text)
    }

    @Test("Compress and decompress codable")
    func codableRoundTrip() throws {
        struct Payload: Codable, Sendable, Equatable {
            let items: [Int]
        }
        let store = makeStore()
        let payload = Payload(items: Array(0..<1000))
        try store.save(payload, forKey: "arr")
        let loaded = try store.load(Payload.self, forKey: "arr")
        #expect(loaded == payload)
    }

    @Test("Load missing returns nil")
    func loadMissing() throws {
        let store = makeStore()
        #expect(try store.load(String.self, forKey: "nope") == nil)
    }

    @Test("Delete removes value")
    func deleteWorks() throws {
        let store = makeStore()
        try store.save("x", forKey: "d")
        try store.delete(forKey: "d")
        #expect(try store.load(String.self, forKey: "d") == nil)
    }

    @Test("Clear removes all")
    func clearWorks() throws {
        let store = makeStore()
        try store.save("a", forKey: "c1")
        try store.save("b", forKey: "c2")
        try store.clear()
        #expect(try store.keys().isEmpty)
    }

    @Test("LZMA algorithm")
    func lzmaAlgorithm() throws {
        let store = makeStore(algorithm: .lzma)
        try store.save("lzma test data", forKey: "lz")
        #expect(try store.load(String.self, forKey: "lz") == "lzma test data")
    }

    @Test("Zlib algorithm")
    func zlibAlgorithm() throws {
        let store = makeStore(algorithm: .zlib)
        try store.save("zlib test data", forKey: "zl")
        #expect(try store.load(String.self, forKey: "zl") == "zlib test data")
    }

    @Test("LZ4 algorithm")
    func lz4Algorithm() throws {
        let store = makeStore(algorithm: .lz4)
        try store.save("lz4 test data", forKey: "l4")
        #expect(try store.load(String.self, forKey: "l4") == "lz4 test data")
    }

    @Test("Exists passthrough")
    func existsPassthrough() throws {
        let store = makeStore()
        #expect(try !store.exists(forKey: "x"))
        try store.save("v", forKey: "x")
        #expect(try store.exists(forKey: "x"))
    }

    @Test("Keys passthrough")
    func keysPassthrough() throws {
        let store = makeStore()
        try store.save("a", forKey: "k1")
        try store.save("b", forKey: "k2")
        let keys = try store.keys()
        #expect(keys.contains("k1"))
        #expect(keys.contains("k2"))
    }

    @Test("Decode error on type mismatch")
    func decodeError() throws {
        let store = makeStore()
        try store.save("hello", forKey: "typed")
        #expect(throws: PrismStorageError.self) {
            _ = try store.load(Int.self, forKey: "typed")
        }
    }
}

@Suite("CmpAsyncStore")
struct PrismCompressedAsyncStoreTests {
    func makeStore(
        algorithm: NSData.CompressionAlgorithm = .lzfse
    ) -> PrismCompressedAsyncStore {
        let memory = PrismMemoryStore()
        return PrismCompressedAsyncStore(wrapping: memory, algorithm: algorithm)
    }

    @Test("Async compress and decompress round trip")
    func roundTrip() async throws {
        let store = makeStore()
        let text = String(repeating: "Async compression test! ", count: 100)
        try await store.save(text, forKey: "big")
        let loaded = try await store.load(String.self, forKey: "big")
        #expect(loaded == text)
    }

    @Test("Async load missing returns nil")
    func loadMissing() async throws {
        let store = makeStore()
        #expect(try await store.load(String.self, forKey: "nope") == nil)
    }

    @Test("Async delete removes value")
    func deleteWorks() async throws {
        let store = makeStore()
        try await store.save("x", forKey: "d")
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
        try await store.save("v", forKey: "x")
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

    @Test("Async LZMA algorithm")
    func lzmaAlgorithm() async throws {
        let store = makeStore(algorithm: .lzma)
        try await store.save("lzma async", forKey: "lz")
        #expect(try await store.load(String.self, forKey: "lz") == "lzma async")
    }

    @Test("Async corrupt data throws decompressionFailed")
    func corruptThrows() async throws {
        let memory = PrismMemoryStore()
        try await memory.save(Data("not-compressed".utf8), forKey: "bad")

        let store = PrismCompressedAsyncStore(wrapping: memory)
        await #expect(throws: PrismStorageError.self) {
            _ = try await store.load(String.self, forKey: "bad")
        }
    }
}
