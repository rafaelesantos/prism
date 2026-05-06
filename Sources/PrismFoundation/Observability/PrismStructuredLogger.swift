//
//  PrismStructuredLogger.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public enum PrismLogLevel: Int, Sendable, Comparable, CaseIterable {
    case trace = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case critical = 5

    public static func < (lhs: PrismLogLevel, rhs: PrismLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct PrismLogEntry: Sendable {
    public let level: PrismLogLevel
    public let message: String
    public let category: String
    public let metadata: [String: String]
    public let timestamp: Date
    public let file: String
    public let line: Int

    public init(
        level: PrismLogLevel,
        message: String,
        category: String = "default",
        metadata: [String: String] = [:],
        timestamp: Date = .now,
        file: String = #file,
        line: Int = #line
    ) {
        self.level = level
        self.message = message
        self.category = category
        self.metadata = metadata
        self.timestamp = timestamp
        self.file = file
        self.line = line
    }
}

public protocol PrismLogDestination: Sendable {
    func write(_ entry: PrismLogEntry)
}

public struct PrismConsoleLogDestination: PrismLogDestination {
    public init() {}

    public func write(_ entry: PrismLogEntry) {
        print("[\(entry.level)] [\(entry.category)] \(entry.message)")
    }
}

public actor PrismStructuredLogger {
    public var minimumLevel: PrismLogLevel
    public private(set) var entries: [PrismLogEntry]

    private let maxEntries: Int
    private var destinations: [any PrismLogDestination]

    public init(
        minimumLevel: PrismLogLevel = .trace,
        maxEntries: Int = 1000,
        destinations: [any PrismLogDestination] = []
    ) {
        self.minimumLevel = minimumLevel
        self.maxEntries = maxEntries
        self.entries = []
        self.destinations = destinations
    }

    public func log(
        _ level: PrismLogLevel,
        _ message: String,
        category: String = "default",
        metadata: [String: String] = [:],
        file: String = #file,
        line: Int = #line
    ) {
        guard level >= minimumLevel else { return }

        let entry = PrismLogEntry(
            level: level,
            message: message,
            category: category,
            metadata: metadata,
            file: file,
            line: line
        )

        entries.append(entry)
        if entries.count > maxEntries {
            entries.removeFirst(entries.count - maxEntries)
        }

        for destination in destinations {
            destination.write(entry)
        }
    }

    public func trace(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.trace, message, category: category, metadata: metadata, file: file, line: line)
    }

    public func debug(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.debug, message, category: category, metadata: metadata, file: file, line: line)
    }

    public func info(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.info, message, category: category, metadata: metadata, file: file, line: line)
    }

    public func warning(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.warning, message, category: category, metadata: metadata, file: file, line: line)
    }

    public func error(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.error, message, category: category, metadata: metadata, file: file, line: line)
    }

    public func critical(
        _ message: String, category: String = "default", metadata: [String: String] = [:], file: String = #file,
        line: Int = #line
    ) {
        log(.critical, message, category: category, metadata: metadata, file: file, line: line)
    }
}
