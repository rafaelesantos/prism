import Foundation
import Testing

@testable import PrismStorage

@Suite("ObsStore")
struct PrismStorageObserverTests {
    func makeObserver() -> PrismStorageObserver {
        let defaults = PrismDefaultsStore(
            suite: "ObsTest-\(UUID().uuidString)"
        )
        return PrismStorageObserver(wrapping: defaults)
    }

    @Test("Save emits saved event")
    func saveEvent() async throws {
        let observer = makeObserver()
        let stream = observer.events()

        try observer.save("val", forKey: "k")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.saved(key: "k")])
    }

    @Test("Delete emits deleted event")
    func deleteEvent() async throws {
        let observer = makeObserver()
        try observer.save("v", forKey: "d")
        let stream = observer.events()

        try observer.delete(forKey: "d")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.deleted(key: "d")])
    }

    @Test("Clear emits cleared event")
    func clearEvent() async throws {
        let observer = makeObserver()
        try observer.save("v", forKey: "c")
        let stream = observer.events()

        try observer.clear()

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.cleared])
    }

    @Test("Load emits loaded event when value exists")
    func loadEvent() async throws {
        let observer = makeObserver()
        try observer.save("v", forKey: "l")
        let stream = observer.events()

        _ = try observer.load(String.self, forKey: "l")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.loaded(key: "l")])
    }

    @Test("Passthrough operations work correctly")
    func passthrough() throws {
        let observer = makeObserver()
        try observer.save("a", forKey: "p1")
        try observer.save("b", forKey: "p2")
        #expect(try observer.exists(forKey: "p1"))
        #expect(try observer.keys().sorted() == ["p1", "p2"])
        let loaded = try observer.load(String.self, forKey: "p1")
        #expect(loaded == "a")
    }

    @Test("Load nil does not emit loaded event")
    func loadNilNoEvent() async throws {
        let observer = makeObserver()
        let stream = observer.events()

        _ = try observer.load(String.self, forKey: "missing")
        try observer.save("trigger", forKey: "t")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events.first == .saved(key: "t"))
    }

    @Test("Exists does not emit event")
    func existsNoEvent() throws {
        let observer = makeObserver()
        try observer.save("v", forKey: "e")
        #expect(try observer.exists(forKey: "e"))
        #expect(try !observer.exists(forKey: "nope"))
    }

    @Test("Keys does not emit event")
    func keysNoEvent() throws {
        let observer = makeObserver()
        try observer.save("a", forKey: "k1")
        let keys = try observer.keys()
        #expect(keys.contains("k1"))
    }
}

@Suite("AsyncObsStore")
struct PrismAsyncStorageObserverTests {
    func makeObserver() -> PrismAsyncStorageObserver {
        let memory = PrismMemoryStore()
        return PrismAsyncStorageObserver(wrapping: memory)
    }

    @Test("Async save emits saved event")
    func saveEvent() async throws {
        let observer = makeObserver()
        let stream = await observer.events()

        try await observer.save("val", forKey: "k")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.saved(key: "k")])
    }

    @Test("Async delete emits deleted event")
    func deleteEvent() async throws {
        let observer = makeObserver()
        try await observer.save("v", forKey: "d")
        let stream = await observer.events()

        try await observer.delete(forKey: "d")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.deleted(key: "d")])
    }

    @Test("Async clear emits cleared event")
    func clearEvent() async throws {
        let observer = makeObserver()
        try await observer.save("v", forKey: "c")
        let stream = await observer.events()

        try await observer.clear()

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.cleared])
    }

    @Test("Async load emits loaded event when value exists")
    func loadEvent() async throws {
        let observer = makeObserver()
        try await observer.save("v", forKey: "l")
        let stream = await observer.events()

        _ = try await observer.load(String.self, forKey: "l")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events == [.loaded(key: "l")])
    }

    @Test("Async load nil does not emit loaded event")
    func loadNilNoEvent() async throws {
        let observer = makeObserver()
        let stream = await observer.events()

        _ = try await observer.load(String.self, forKey: "missing")
        try await observer.save("trigger", forKey: "t")

        var events: [PrismStorageEvent] = []
        for await event in stream {
            events.append(event)
            if events.count >= 1 { break }
        }
        #expect(events.first == .saved(key: "t"))
    }

    @Test("Async exists passthrough")
    func existsPassthrough() async throws {
        let observer = makeObserver()
        #expect(try await !observer.exists(forKey: "x"))
        try await observer.save("v", forKey: "x")
        #expect(try await observer.exists(forKey: "x"))
    }

    @Test("Async keys passthrough")
    func keysPassthrough() async throws {
        let observer = makeObserver()
        try await observer.save("a", forKey: "k1")
        try await observer.save("b", forKey: "k2")
        let keys = try await observer.keys()
        #expect(keys.contains("k1"))
        #expect(keys.contains("k2"))
    }
}
