//
//  PrismResponseCache.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public enum PrismCachePolicy: Sendable, CaseIterable {
    case networkOnly
    case cacheFirst
    case cacheThenNetwork
    case staleWhileRevalidate
}

public struct PrismCacheEntry: Sendable {
    public let data: Data
    public let statusCode: Int
    public let headers: [String: String]
    public let cachedAt: Date
    public let ttl: Duration

    public init(
        data: Data,
        statusCode: Int = 200,
        headers: [String: String] = [:],
        cachedAt: Date = Date(),
        ttl: Duration = .seconds(300)
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.cachedAt = cachedAt
        self.ttl = ttl
    }

    public var isExpired: Bool {
        let expirationDate = cachedAt.addingTimeInterval(ttl.timeInterval)
        return Date() > expirationDate
    }
}

public actor PrismResponseCache {
    private var storage: [String: PrismCacheEntry] = [:]
    private var accessOrder: [String] = []
    private let maxSize: Int

    public init(maxSize: Int = 100) {
        self.maxSize = maxSize
    }

    public func get(for key: String) -> PrismCacheEntry? {
        guard let entry = storage[key] else { return nil }
        if entry.isExpired {
            storage.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            return nil
        }
        touchKey(key)
        return entry
    }

    public func set(_ entry: PrismCacheEntry, for key: String) {
        if storage[key] != nil {
            storage[key] = entry
            touchKey(key)
        } else {
            if storage.count >= maxSize {
                evictLRU()
            }
            storage[key] = entry
            accessOrder.append(key)
        }
    }

    public func invalidate(key: String) {
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

    private func touchKey(_ key: String) {
        accessOrder.removeAll { $0 == key }
        accessOrder.append(key)
    }

    private func evictLRU() {
        guard let oldest = accessOrder.first else { return }
        accessOrder.removeFirst()
        storage.removeValue(forKey: oldest)
    }
}
