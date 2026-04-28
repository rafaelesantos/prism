//
//  PrismCrashReporter.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// A structured report capturing crash or fatal-error details.
public struct PrismCrashReport: Sendable {
    /// Unique identifier for this crash report.
    public let id: UUID
    /// Human-readable description of the crash.
    public let message: String
    /// Optional stack trace captured at crash time.
    public let stackTrace: String?
    /// The timestamp when the crash was recorded.
    public let timestamp: Date
    /// The app version string at crash time.
    public let appVersion: String?
    /// Arbitrary key-value metadata attached to this report.
    public let metadata: [String: String]

    /// Creates a new crash report with all fields.
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

/// Thread-safe crash reporter that collects crash reports and notifies a callback.
public actor PrismCrashReporter {
    /// All recorded crash reports.
    public private(set) var reports: [PrismCrashReport] = []
    /// Optional callback invoked each time a crash is recorded.
    public var onCrash: (@Sendable (PrismCrashReport) -> Void)?

    /// Creates a crash reporter with an optional callback.
    public init(onCrash: (@Sendable (PrismCrashReport) -> Void)? = nil) {
        self.onCrash = onCrash
    }

    /// Records a crash report and invokes the onCrash callback.
    public func record(_ report: PrismCrashReport) {
        reports.append(report)
        onCrash?(report)
    }

    /// Removes all recorded crash reports.
    public func clear() {
        reports.removeAll()
    }
}
