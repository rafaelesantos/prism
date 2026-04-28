import Foundation

/// Actor-based token bucket rate limiter.
public actor PrismRateLimiter {
    private var buckets: [String: TokenBucket] = [:]
    private let maxRequests: Int
    private let windowSeconds: Double

    public init(maxRequests: Int, windowSeconds: Double) {
        self.maxRequests = maxRequests
        self.windowSeconds = windowSeconds
    }

    public func shouldAllow(key: String) -> Bool {
        let now = Date.now.timeIntervalSince1970
        var bucket = buckets[key] ?? TokenBucket(tokens: maxRequests, lastRefill: now)

        let elapsed = now - bucket.lastRefill
        let refill = Int(elapsed / windowSeconds) * maxRequests
        if refill > 0 {
            bucket.tokens = min(maxRequests, bucket.tokens + refill)
            bucket.lastRefill = now
        }

        if bucket.tokens > 0 {
            bucket.tokens -= 1
            buckets[key] = bucket
            return true
        }

        buckets[key] = bucket
        return false
    }

    private struct TokenBucket {
        var tokens: Int
        var lastRefill: Double
    }
}

/// Rate limiting middleware using client IP or a custom key extractor.
public struct PrismRateLimitMiddleware: PrismMiddleware {
    private let limiter: PrismRateLimiter
    private let keyExtractor: @Sendable (PrismHTTPRequest) -> String

    public init(
        maxRequests: Int = 100,
        windowSeconds: Double = 60,
        keyExtractor: @escaping @Sendable (PrismHTTPRequest) -> String = { $0.headers.value(for: "X-Forwarded-For") ?? "unknown" }
    ) {
        self.limiter = PrismRateLimiter(maxRequests: maxRequests, windowSeconds: windowSeconds)
        self.keyExtractor = keyExtractor
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        let key = keyExtractor(request)
        let allowed = await limiter.shouldAllow(key: key)

        guard allowed else {
            var response = PrismHTTPResponse(status: .tooManyRequests, body: .text("Rate limit exceeded"))
            response.headers.set(name: "Retry-After", value: "60")
            return response
        }

        return try await next(request)
    }
}
