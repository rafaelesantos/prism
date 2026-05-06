//
//  PrismPerformanceTrace.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public struct PrismTraceSpan: Sendable {
    public let id: UUID
    public let name: String
    public let startTime: Date
    public var endTime: Date?
    public var duration: Duration?
    public let metadata: [String: String]
    public var children: [PrismTraceSpan]

    public init(
        id: UUID = UUID(),
        name: String,
        startTime: Date = .now,
        endTime: Date? = nil,
        duration: Duration? = nil,
        metadata: [String: String] = [:],
        children: [PrismTraceSpan] = []
    ) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.metadata = metadata
        self.children = children
    }
}

public actor PrismPerformanceTracer {
    public private(set) var activeSpans: [PrismTraceSpan] = []
    public private(set) var completedSpans: [PrismTraceSpan] = []

    public init() {}

    @discardableResult
    public func beginSpan(name: String, metadata: [String: String] = [:]) -> UUID {
        let span = PrismTraceSpan(name: name, metadata: metadata)
        activeSpans.append(span)
        return span.id
    }

    public func endSpan(id: UUID) {
        guard let index = activeSpans.firstIndex(where: { $0.id == id }) else { return }
        var span = activeSpans.remove(at: index)
        let endTime = Date.now
        span.endTime = endTime
        let interval = endTime.timeIntervalSince(span.startTime)
        span.duration = .seconds(interval)
        completedSpans.append(span)
    }

    public func measure<T: Sendable>(name: String, _ operation: @Sendable () async throws -> T) async rethrows -> T {
        let spanID = beginSpan(name: name)
        let result = try await operation()
        endSpan(id: spanID)
        return result
    }
}
