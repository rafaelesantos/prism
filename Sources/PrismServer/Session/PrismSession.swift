import Foundation

public struct PrismSession: Sendable {
    public let id: String
    public var data: [String: String]
    public let createdAt: Date
    public var expiresAt: Date

    public init(id: String = UUID().uuidString, data: [String: String] = [:], ttl: TimeInterval = 3600) {
        self.id = id
        self.data = data
        self.createdAt = .now
        self.expiresAt = Date.now.addingTimeInterval(ttl)
    }

    public var isExpired: Bool { Date.now >= expiresAt }

    public subscript(_ key: String) -> String? {
        get { data[key] }
        set { data[key] = newValue }
    }
}

public protocol PrismSessionStore: Sendable {
    func load(id: String) async -> PrismSession?
    func save(_ session: PrismSession) async
    func destroy(id: String) async
}

public actor PrismMemorySessionStore: PrismSessionStore {
    private let cache: PrismCache<String, PrismSession>

    public init(maxSessions: Int = 10000, ttl: TimeInterval = 3600) {
        self.cache = PrismCache(maxEntries: maxSessions, defaultTTL: ttl)
    }

    public func load(id: String) async -> PrismSession? {
        await cache.get(id)
    }

    public func save(_ session: PrismSession) async {
        let ttl = session.expiresAt.timeIntervalSince(.now)
        await cache.set(session.id, value: session, ttl: max(ttl, 1))
    }

    public func destroy(id: String) async {
        await cache.remove(id)
    }
}
