//
//  PrismRetryPolicy.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public protocol PrismRetryPolicy: Sendable {
    func shouldRetry(for error: Error, attempt: Int) -> Bool
    func delay(for attempt: Int) -> Duration
}

public struct PrismExponentialBackoff: PrismRetryPolicy, Sendable {
    public let baseDelay: Duration
    public let maxDelay: Duration
    public let maxAttempts: Int

    public init(
        baseDelay: Duration = .seconds(1),
        maxDelay: Duration = .seconds(30),
        maxAttempts: Int = 3
    ) {
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.maxAttempts = maxAttempts
    }

    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        attempt < maxAttempts
    }

    public func delay(for attempt: Int) -> Duration {
        let exponentialSeconds = baseDelay.timeInterval * pow(2.0, Double(attempt))
        let jitter = Double.random(in: 0...0.5)
        let totalSeconds = exponentialSeconds + jitter
        let cappedSeconds = min(totalSeconds, maxDelay.timeInterval)
        return .nanoseconds(Int64(cappedSeconds * 1_000_000_000))
    }
}

public struct PrismLinearRetry: PrismRetryPolicy, Sendable {
    public let fixedDelay: Duration
    public let maxAttempts: Int

    public init(
        fixedDelay: Duration = .seconds(2),
        maxAttempts: Int = 3
    ) {
        self.fixedDelay = fixedDelay
        self.maxAttempts = maxAttempts
    }

    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        attempt < maxAttempts
    }

    public func delay(for attempt: Int) -> Duration {
        fixedDelay
    }
}

public struct PrismRetryableRequest<T: Sendable>: Sendable {
    public let policy: any PrismRetryPolicy
    public let operation: @Sendable () async throws -> T

    public init(
        policy: any PrismRetryPolicy,
        operation: @escaping @Sendable () async throws -> T
    ) {
        self.policy = policy
        self.operation = operation
    }

    public func execute() async throws -> T {
        var attempt = 0
        while true {
            do {
                return try await operation()
            } catch {
                guard policy.shouldRetry(for: error, attempt: attempt) else {
                    throw error
                }
                let waitDuration = policy.delay(for: attempt)
                try await Task.sleep(for: waitDuration)
                attempt += 1
            }
        }
    }
}

// MARK: - Duration helpers

extension Duration {
    var timeInterval: Double {
        let (seconds, attoseconds) = components
        return Double(seconds) + Double(attoseconds) * 1e-18
    }
}
