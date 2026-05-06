import Foundation

public struct PrismAuditExporter: Sendable {
    public init() {}

    public func exportJSON(_ entries: [PrismAuditLogEntry]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(entries)
    }

    public func exportJSONString(_ entries: [PrismAuditLogEntry]) throws -> String {
        let data = try exportJSON(entries)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PrismSecurityError.serializationFailed
        }
        return string
    }

    public func exportSummary(_ entries: [PrismAuditLogEntry]) -> PrismAuditSummary {
        var kindCounts: [PrismSecurityEventKind: Int] = [:]
        for entry in entries {
            kindCounts[entry.event.kind, default: 0] += 1
        }

        return PrismAuditSummary(
            totalEntries: entries.count,
            firstEntry: entries.first?.event.timestamp,
            lastEntry: entries.last?.event.timestamp,
            eventCounts: kindCounts,
            generatedAt: .now
        )
    }
}

public struct PrismAuditSummary: Sendable, Equatable {
    public let totalEntries: Int
    public let firstEntry: Date?
    public let lastEntry: Date?
    public let eventCounts: [PrismSecurityEventKind: Int]
    public let generatedAt: Date
}
