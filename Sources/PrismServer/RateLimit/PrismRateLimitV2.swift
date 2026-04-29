import Foundation

/// Protocol for rate limit storage backends.
public protocol PrismRateLimitStore: Sendable {
    func getWindowHits(key: String, windowStart: Date) async -> Int
    func recordHit(key: String, at date: Date) async
    func reset(key: String) async
}

/// In-memory sliding window rate limit store.
public actor PrismMemoryRateLimitStore: PrismRateLimitStore {
    private var hits: [String: [Date]] = [:]

    public init() {}

    public func getWindowHits(key: String, windowStart: Date) -> Int {
        guard let timestamps = hits[key] else { return 0 }
        return timestamps.filter { $0 >= windowStart }.count
    }

    public func recordHit(key: String, at date: Date) {
        hits[key, default: []].append(date)
        prune(key: key, before: date.addingTimeInterval(-3600))
    }

    public func reset(key: String) {
        hits.removeValue(forKey: key)
    }

    private func prune(key: String, before cutoff: Date) {
        hits[key]?.removeAll { $0 < cutoff }
    }
}

/// Configuration for sliding window rate limiting.
public struct PrismRateLimitConfig: Sendable {
    public let windowSeconds: Double
    public let maxRequests: Int
    public let keyExtractor: @Sendable (PrismHTTPRequest) -> String

    public init(windowSeconds: Double, maxRequests: Int, keyExtractor: @escaping @Sendable (PrismHTTPRequest) -> String) {
        self.windowSeconds = windowSeconds
        self.maxRequests = maxRequests
        self.keyExtractor = keyExtractor
    }

    public static func perIP(max: Int, windowSeconds: Double = 60) -> PrismRateLimitConfig {
        PrismRateLimitConfig(windowSeconds: windowSeconds, maxRequests: max) { request in
            request.headers.value(for: "X-Forwarded-For")?.split(separator: ",").first.map(String.init) ?? "unknown"
        }
    }

    public static func perHeader(_ header: String, max: Int, windowSeconds: Double = 60) -> PrismRateLimitConfig {
        PrismRateLimitConfig(windowSeconds: windowSeconds, maxRequests: max) { request in
            request.headers.value(for: header) ?? "anonymous"
        }
    }

    public static func global(max: Int, windowSeconds: Double = 60) -> PrismRateLimitConfig {
        PrismRateLimitConfig(windowSeconds: windowSeconds, maxRequests: max) { _ in "global" }
    }
}

/// Sliding window rate limiting middleware with standard rate limit headers.
public struct PrismSlidingWindowMiddleware: PrismMiddleware, Sendable {
    private let store: any PrismRateLimitStore
    private let config: PrismRateLimitConfig

    public init(store: any PrismRateLimitStore, config: PrismRateLimitConfig) {
        self.store = store
        self.config = config
    }

    public init(config: PrismRateLimitConfig) {
        self.store = PrismMemoryRateLimitStore()
        self.config = config
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        let key = config.keyExtractor(request)
        let now = Date()
        let windowStart = now.addingTimeInterval(-config.windowSeconds)

        let hits = await store.getWindowHits(key: key, windowStart: windowStart)

        let resetTime = Int(now.timeIntervalSince1970 + config.windowSeconds)
        let remaining = max(0, config.maxRequests - hits - 1)

        if hits >= config.maxRequests {
            var headers = PrismHTTPHeaders()
            headers.set(name: "Content-Type", value: "application/json; charset=utf-8")
            headers.set(name: "X-RateLimit-Limit", value: "\(config.maxRequests)")
            headers.set(name: "X-RateLimit-Remaining", value: "0")
            headers.set(name: "X-RateLimit-Reset", value: "\(resetTime)")
            headers.set(name: "Retry-After", value: "\(Int(config.windowSeconds))")
            let body = Data("{\"error\":\"RATE_LIMITED\",\"message\":\"Too many requests\"}".utf8)
            headers.set(name: "Content-Length", value: "\(body.count)")
            return PrismHTTPResponse(status: .tooManyRequests, headers: headers, body: .data(body))
        }

        await store.recordHit(key: key, at: now)
        var response = try await next(request)

        response.headers.set(name: "X-RateLimit-Limit", value: "\(config.maxRequests)")
        response.headers.set(name: "X-RateLimit-Remaining", value: "\(remaining)")
        response.headers.set(name: "X-RateLimit-Reset", value: "\(resetTime)")

        return response
    }
}
