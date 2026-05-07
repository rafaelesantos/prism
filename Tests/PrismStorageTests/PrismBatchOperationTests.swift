import Foundation
import Testing

@testable import PrismStorage

@Suite("BatchOp")
struct PrismBatchOperationTests {
    func makeWriter() -> (PrismBatchWriter, PrismDefaultsStore) {
        let store = PrismDefaultsStore(suite: "BatchTest-\(UUID().uuidString)")
        return (PrismBatchWriter(store: store), store)
    }

    @Test("Execute save actions")
    func executeSave() throws {
        let (writer, store) = makeWriter()
        let actions: [PrismBatchAction<String>] = [
            .save(key: "a", value: "1"),
            .save(key: "b", value: "2"),
            .save(key: "c", value: "3"),
        ]
        let result = try writer.execute(actions)
        #expect(result.total == 3)
        #expect(result.succeeded == 3)
        #expect(result.failed == 0)
        #expect(result.allSucceeded)
        #expect(try store.load(String.self, forKey: "b") == "2")
    }

    @Test("Execute delete actions")
    func executeDelete() throws {
        let (writer, store) = makeWriter()
        try store.save("x", forKey: "d1")
        try store.save("y", forKey: "d2")
        let actions: [PrismBatchAction<String>] = [
            .delete(key: "d1"),
            .delete(key: "d2"),
        ]
        let result = try writer.execute(actions)
        #expect(result.total == 2)
        #expect(result.allSucceeded)
        #expect(try store.load(String.self, forKey: "d1") == nil)
    }

    @Test("SaveAll convenience")
    func saveAll() throws {
        let (writer, store) = makeWriter()
        let items: [(key: String, value: Int)] = [
            ("n1", 10), ("n2", 20), ("n3", 30),
        ]
        let result = try writer.saveAll(items)
        #expect(result.total == 3)
        #expect(result.allSucceeded)
        #expect(try store.load(Int.self, forKey: "n2") == 20)
    }

    @Test("DeleteAll convenience")
    func deleteAll() throws {
        let (writer, store) = makeWriter()
        try store.save("a", forKey: "k1")
        try store.save("b", forKey: "k2")
        let result = try writer.deleteAll(["k1", "k2"])
        #expect(result.total == 2)
        #expect(result.allSucceeded)
    }

    @Test("BatchResult equatable")
    func resultEquatable() {
        let a = PrismBatchResult(total: 5, succeeded: 4, failed: 1)
        let b = PrismBatchResult(total: 5, succeeded: 4, failed: 1)
        #expect(a == b)
        #expect(!a.allSucceeded)
    }

    @Test("Mixed save and delete actions")
    func mixedActions() throws {
        let (writer, store) = makeWriter()
        try store.save("existing", forKey: "del")
        let actions: [PrismBatchAction<String>] = [
            .save(key: "new1", value: "a"),
            .delete(key: "del"),
            .save(key: "new2", value: "b"),
        ]
        let result = try writer.execute(actions)
        #expect(result.total == 3)
        #expect(result.allSucceeded)
        #expect(try store.load(String.self, forKey: "new1") == "a")
        #expect(try store.load(String.self, forKey: "del") == nil)
        #expect(try store.load(String.self, forKey: "new2") == "b")
    }

    @Test("Empty batch returns zero result")
    func emptyBatch() throws {
        let (writer, _) = makeWriter()
        let result = try writer.execute([PrismBatchAction<String>]())
        #expect(result.total == 0)
        #expect(result.allSucceeded)
    }

    @Test("DeleteAll with no keys")
    func deleteAllEmpty() throws {
        let (writer, _) = makeWriter()
        let result = try writer.deleteAll([])
        #expect(result.total == 0)
        #expect(result.allSucceeded)
    }
}

@Suite("AsyncBatchOp")
struct PrismAsyncBatchOperationTests {
    func makeWriter() -> (PrismAsyncBatchWriter, PrismMemoryStore) {
        let store = PrismMemoryStore()
        return (PrismAsyncBatchWriter(store: store), store)
    }

    @Test("Async execute save actions")
    func executeSave() async throws {
        let (writer, store) = makeWriter()
        let actions: [PrismBatchAction<String>] = [
            .save(key: "a", value: "1"),
            .save(key: "b", value: "2"),
        ]
        let result = try await writer.execute(actions)
        #expect(result.total == 2)
        #expect(result.allSucceeded)
        #expect(try await store.load(String.self, forKey: "a") == "1")
    }

    @Test("Async execute delete actions")
    func executeDelete() async throws {
        let (writer, store) = makeWriter()
        try await store.save("x", forKey: "d1")
        let actions: [PrismBatchAction<String>] = [.delete(key: "d1")]
        let result = try await writer.execute(actions)
        #expect(result.allSucceeded)
        #expect(try await store.load(String.self, forKey: "d1") == nil)
    }

    @Test("Async saveAll convenience")
    func saveAll() async throws {
        let (writer, store) = makeWriter()
        let items: [(key: String, value: Int)] = [("n1", 10), ("n2", 20)]
        let result = try await writer.saveAll(items)
        #expect(result.total == 2)
        #expect(result.allSucceeded)
        #expect(try await store.load(Int.self, forKey: "n1") == 10)
    }

    @Test("Async deleteAll convenience")
    func deleteAll() async throws {
        let (writer, store) = makeWriter()
        try await store.save("a", forKey: "k1")
        try await store.save("b", forKey: "k2")
        let result = try await writer.deleteAll(["k1", "k2"])
        #expect(result.total == 2)
        #expect(result.allSucceeded)
    }

    @Test("Async mixed actions")
    func mixedActions() async throws {
        let (writer, store) = makeWriter()
        try await store.save("existing", forKey: "del")
        let actions: [PrismBatchAction<String>] = [
            .save(key: "new", value: "v"),
            .delete(key: "del"),
        ]
        let result = try await writer.execute(actions)
        #expect(result.total == 2)
        #expect(result.allSucceeded)
        #expect(try await store.load(String.self, forKey: "new") == "v")
        #expect(try await store.load(String.self, forKey: "del") == nil)
    }

    @Test("Async empty batch")
    func emptyBatch() async throws {
        let (writer, _) = makeWriter()
        let result = try await writer.execute([PrismBatchAction<String>]())
        #expect(result.total == 0)
        #expect(result.allSucceeded)
    }
}
