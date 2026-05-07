import Foundation
import Testing

@testable import PrismStorage

@Suite("KcStore")
struct PrismKeychainStoreTests {
    let store = PrismKeychainStore(service: "PrismStorageTest-\(UUID().uuidString)")

    @Test("Save and load string")
    func saveLoadString() throws {
        try store.save("secret", forKey: "token")
        let loaded = try store.load(String.self, forKey: "token")
        #expect(loaded == "secret")
        try store.delete(forKey: "token")
    }

    @Test("Save and load codable")
    func saveLoadCodable() throws {
        struct Cred: Codable, Sendable, Equatable {
            let user: String
            let pass: String
        }
        let cred = Cred(user: "admin", pass: "s3cret")
        try store.save(cred, forKey: "cred")
        let loaded = try store.load(Cred.self, forKey: "cred")
        #expect(loaded == cred)
        try store.delete(forKey: "cred")
    }

    @Test("Load missing returns nil")
    func loadMissing() throws {
        let result = try store.load(String.self, forKey: "nonexistent-\(UUID())")
        #expect(result == nil)
    }

    @Test("Delete removes item")
    func delete() throws {
        try store.save("temp", forKey: "del")
        try store.delete(forKey: "del")
        let result = try store.load(String.self, forKey: "del")
        #expect(result == nil)
    }

    @Test("Exists returns correct value")
    func exists() throws {
        let key = "exists-\(UUID())"
        #expect(try !store.exists(forKey: key))
        try store.save(true, forKey: key)
        #expect(try store.exists(forKey: key))
        try store.delete(forKey: key)
    }

    @Test("Overwrite replaces value")
    func overwrite() throws {
        try store.save("first", forKey: "ow")
        try store.save("second", forKey: "ow")
        let loaded = try store.load(String.self, forKey: "ow")
        #expect(loaded == "second")
        try store.delete(forKey: "ow")
    }

    @Test("Clear does not throw")
    func clear() throws {
        try store.save("a", forKey: "c1")
        try store.clear()
    }

    @Test("Delete nonexistent does not throw")
    func deleteNonexistent() throws {
        try store.delete(forKey: "never-existed-\(UUID())")
    }

    @Test("Keys returns saved keys")
    func keysReturned() throws {
        let key1 = "kc-key1-\(UUID())"
        let key2 = "kc-key2-\(UUID())"
        try store.save("a", forKey: key1)
        try store.save("b", forKey: key2)
        let keys = try store.keys()
        #expect(keys.contains(key1))
        #expect(keys.contains(key2))
        try store.delete(forKey: key1)
        try store.delete(forKey: key2)
    }

    @Test("Keys returns empty when no items")
    func keysEmpty() throws {
        let emptyStore = PrismKeychainStore(
            service: "PrismStorageEmptyTest-\(UUID().uuidString)"
        )
        let keys = try emptyStore.keys()
        #expect(keys.isEmpty)
    }

    @Test("Init with access group")
    func accessGroup() {
        let store = PrismKeychainStore(
            service: "PrismTest",
            accessGroup: "group.com.prism.test"
        )
        _ = store
    }
}
