import Foundation

public actor PrismCache<Key: Hashable & Sendable, Value: Sendable> {
    private var storage: [Key: CacheEntry<Value>] = [:]
    private var accessOrder: [Key] = []
    private let maxEntries: Int
    private let defaultTTL: TimeInterval

    public init(maxEntries: Int = 1000, defaultTTL: TimeInterval = 300) {
        self.maxEntries = maxEntries
        self.defaultTTL = defaultTTL
    }

    public func get(_ key: Key) -> Value? {
        guard let entry = storage[key] else { return nil }
        if entry.isExpired {
            storage.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            return nil
        }
        promoteKey(key)
        return entry.value
    }

    public func set(_ key: Key, value: Value, ttl: TimeInterval? = nil) {
        let expiry = Date.now.addingTimeInterval(ttl ?? defaultTTL)
        storage[key] = CacheEntry(value: value, expiry: expiry)
        promoteKey(key)
        evictIfNeeded()
    }

    public func remove(_ key: Key) {
        storage.removeValue(forKey: key)
        accessOrder.removeAll { $0 == key }
    }

    public func clear() {
        storage.removeAll()
        accessOrder.removeAll()
    }

    public var count: Int {
        storage.count
    }

    public func has(_ key: Key) -> Bool {
        guard let entry = storage[key] else { return false }
        return !entry.isExpired
    }

    public func purgeExpired() {
        let now = Date.now
        let expired = storage.filter { $0.value.expiry <= now }.map(\.key)
        for key in expired {
            storage.removeValue(forKey: key)
        }
        accessOrder.removeAll { expired.contains($0) }
    }

    private func promoteKey(_ key: Key) {
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
    }

    private func evictIfNeeded() {
        while storage.count > maxEntries, let oldest = accessOrder.first {
            storage.removeValue(forKey: oldest)
            accessOrder.removeFirst()
        }
    }
}

private struct CacheEntry<Value: Sendable>: Sendable {
    let value: Value
    let expiry: Date

    var isExpired: Bool {
        Date.now >= expiry
    }
}
