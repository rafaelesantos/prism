//
//  PrismCrashReporter.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public struct PrismCrashReport: Sendable {
    public let id: UUID
    public let message: String
    public let stackTrace: String?
    public let timestamp: Date
    public let appVersion: String?
    public let metadata: [String: String]

    public init(
        id: UUID = UUID(),
        message: String,
        stackTrace: String? = nil,
        timestamp: Date = .now,
        appVersion: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.message = message
        self.stackTrace = stackTrace
        self.timestamp = timestamp
        self.appVersion = appVersion
        self.metadata = metadata
    }
}

public actor PrismCrashReporter {
    public private(set) var reports: [PrismCrashReport] = []
    public var onCrash: (@Sendable (PrismCrashReport) -> Void)?

    public init(onCrash: (@Sendable (PrismCrashReport) -> Void)? = nil) {
        self.onCrash = onCrash
    }

    public func record(_ report: PrismCrashReport) {
        reports.append(report)
        onCrash?(report)
    }

    public func clear() {
        reports.removeAll()
    }
}
