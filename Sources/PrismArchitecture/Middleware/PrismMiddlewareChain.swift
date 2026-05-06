//
//  PrismMiddlewareChain.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import os

public protocol PrismChainableMiddleware: Sendable {
    func handle<State: Sendable, Action: Sendable>(
        state: State,
        action: Action,
        next: @Sendable (Action) -> Void
    ) async
}

// MARK: - Logging Middleware

public struct PrismLoggingMiddleware: PrismChainableMiddleware, Sendable {
    private let logger: @Sendable (String) -> Void

    public init(
        logger: @escaping @Sendable (String) -> Void = {
            os.Logger(subsystem: "com.prism.architecture", category: "middleware").debug("\($0)")
        }
    ) {
        self.logger = logger
    }

    public func handle<State: Sendable, Action: Sendable>(
        state: State,
        action: Action,
        next: @Sendable (Action) -> Void
    ) async {
        logger("[PrismMiddleware] Action: \(action) | State: \(type(of: state))")
        next(action)
    }
}

// MARK: - Throttle Middleware

public final class PrismThrottleMiddleware: PrismChainableMiddleware, @unchecked Sendable {
    private let interval: Duration
    private let lock = NSLock()
    private var lastActionTimestamps: [String: ContinuousClock.Instant] = [:]

    public init(interval: Duration = .milliseconds(300)) {
        self.interval = interval
    }

    public func handle<State: Sendable, Action: Sendable>(
        state: State,
        action: Action,
        next: @Sendable (Action) -> Void
    ) async {
        let key = String(describing: action)
        let now = ContinuousClock.now

        let shouldForward: Bool = lock.withLock {
            if let lastTime = lastActionTimestamps[key] {
                let elapsed = now - lastTime
                if elapsed < interval {
                    return false
                }
            }
            lastActionTimestamps[key] = now
            return true
        }

        if shouldForward {
            next(action)
        }
    }
}

// MARK: - Middleware Chain

public struct PrismMiddlewareChain: Sendable {
    private var middlewares: [any PrismChainableMiddleware] = []

    public init() {}

    public func add(_ middleware: any PrismChainableMiddleware) -> PrismMiddlewareChain {
        var copy = self
        copy.middlewares.append(middleware)
        return copy
    }

    public func build() -> [any PrismChainableMiddleware] {
        middlewares
    }
}
