//
//  PrismNetworkInspector.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public struct PrismNetworkLog: Sendable {
    public let id: UUID
    public let url: String
    public let method: String
    public let statusCode: Int?
    public let requestSize: Int64?
    public let responseSize: Int64?
    public let duration: Duration?
    public let timestamp: Date
    public let error: String?

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

public actor PrismNetworkInspector {
    public private(set) var logs: [PrismNetworkLog] = []

    public init() {}

    public func record(_ log: PrismNetworkLog) {
        logs.append(log)
    }

    public func clear() {
        logs.removeAll()
    }

    public var averageLatency: Duration? {
        let durations = logs.compactMap { $0.duration }
        guard !durations.isEmpty else { return nil }
        let totalSeconds = durations.reduce(0.0) { sum, d in
            sum + Double(d.components.seconds) + Double(d.components.attoseconds) / 1e18
        }
        return .seconds(totalSeconds / Double(durations.count))
    }

    public var errorRate: Double {
        guard !logs.isEmpty else { return 0.0 }
        let errorCount = logs.filter { $0.error != nil }.count
        return Double(errorCount) / Double(logs.count)
    }
}
