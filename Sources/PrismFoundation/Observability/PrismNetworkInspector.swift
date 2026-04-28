//
//  PrismNetworkInspector.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// A recorded network request/response pair with timing and size information.
public struct PrismNetworkLog: Sendable {
    /// Unique identifier for this network log.
    public let id: UUID
    /// The request URL string.
    public let url: String
    /// The HTTP method (GET, POST, etc.).
    public let method: String
    /// The HTTP response status code, nil if the request failed before receiving a response.
    public let statusCode: Int?
    /// Size of the request body in bytes.
    public let requestSize: Int64?
    /// Size of the response body in bytes.
    public let responseSize: Int64?
    /// The wall-clock duration of the request.
    public let duration: Duration?
    /// The timestamp when this log was recorded.
    public let timestamp: Date
    /// An error description if the request failed.
    public let error: String?

    /// Creates a new network log with all fields.
    public init(
        id: UUID = UUID(),
        url: String,
        method: String,
        statusCode: Int? = nil,
        requestSize: Int64? = nil,
        responseSize: Int64? = nil,
        duration: Duration? = nil,
        timestamp: Date = .now,
        error: String? = nil
    ) {
        self.id = id
        self.url = url
        self.method = method
        self.statusCode = statusCode
        self.requestSize = requestSize
        self.responseSize = responseSize
        self.duration = duration
        self.timestamp = timestamp
        self.error = error
    }
}

/// Thread-safe network inspector that collects request logs and computes aggregate metrics.
public actor PrismNetworkInspector {
    /// All recorded network logs.
    public private(set) var logs: [PrismNetworkLog] = []

    /// Creates a new network inspector.
    public init() {}

    /// Records a network log entry.
    public func record(_ log: PrismNetworkLog) {
        logs.append(log)
    }

    /// Removes all recorded network logs.
    public func clear() {
        logs.removeAll()
    }

    /// The average request latency across all logs that have a duration, nil if none.
    public var averageLatency: Duration? {
        let durations = logs.compactMap { $0.duration }
        guard !durations.isEmpty else { return nil }
        let totalSeconds = durations.reduce(0.0) { sum, d in
            sum + Double(d.components.seconds) + Double(d.components.attoseconds) / 1e18
        }
        return .seconds(totalSeconds / Double(durations.count))
    }

    /// The fraction of logs that have a non-nil error, from 0.0 to 1.0.
    public var errorRate: Double {
        guard !logs.isEmpty else { return 0.0 }
        let errorCount = logs.filter { $0.error != nil }.count
        return Double(errorCount) / Double(logs.count)
    }
}
