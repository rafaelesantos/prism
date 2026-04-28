//
//  PrismPerformanceTrace.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// A single span within a performance trace, supporting hierarchical children.
public struct PrismTraceSpan: Sendable {
    /// Unique identifier for this span.
    public let id: UUID
    /// Human-readable name describing the traced operation.
    public let name: String
    /// The time this span started.
    public let startTime: Date
    /// The time this span ended, nil if still active.
    public var endTime: Date?
    /// The wall-clock duration of this span, nil if still active.
    public var duration: Duration?
    /// Arbitrary key-value metadata attached to this span.
    public let metadata: [String: String]
    /// Nested child spans within this parent.
    public var children: [PrismTraceSpan]

    /// Creates a new trace span.
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

/// Thread-safe performance tracer for measuring operation durations.
public actor PrismPerformanceTracer {
    /// Spans that have been started but not yet ended.
    public private(set) var activeSpans: [PrismTraceSpan] = []
    /// Spans that have been completed with an end time and duration.
    public private(set) var completedSpans: [PrismTraceSpan] = []

    /// Creates a new performance tracer.
    public init() {}

    /// Begins a new span and returns its identifier for later completion.
    @discardableResult
    public func beginSpan(name: String, metadata: [String: String] = [:]) -> UUID {
        let span = PrismTraceSpan(name: name, metadata: metadata)
        activeSpans.append(span)
        return span.id
    }

    /// Ends the span with the given identifier, moving it to completed spans.
    public func endSpan(id: UUID) {
        guard let index = activeSpans.firstIndex(where: { $0.id == id }) else { return }
        var span = activeSpans.remove(at: index)
        let endTime = Date.now
        span.endTime = endTime
        let interval = endTime.timeIntervalSince(span.startTime)
        span.duration = .seconds(interval)
        completedSpans.append(span)
    }

    /// Measures the duration of an async operation, automatically creating and completing a span.
    public func measure<T: Sendable>(name: String, _ operation: @Sendable () async throws -> T) async rethrows -> T {
        let spanID = beginSpan(name: name)
        let result = try await operation()
        endSpan(id: spanID)
        return result
    }
}
