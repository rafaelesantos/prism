import CryptoKit
import Foundation

public final class PrismSecurityAuditLog: @unchecked Sendable {
    private let lock = NSLock()
    private var _entries: [PrismAuditLogEntry] = []
    private let maxEntries: Int
    private let retentionDays: Int?

    public init(maxEntries: Int = 10_000, retentionDays: Int? = nil) {
        self.maxEntries = maxEntries
        self.retentionDays = retentionDays
    }

    @discardableResult
    public func record(_ event: PrismSecurityEvent) -> PrismAuditLogEntry {
        lock.lock()
        defer { lock.unlock() }

        let previousHash = _entries.last?.entryHash ?? ""
        let sequence = _entries.count
        let entry = PrismAuditLogEntry(event: event, previousHash: previousHash, sequence: sequence)
        _entries.append(entry)

        if _entries.count > maxEntries {
            _entries.removeFirst(_entries.count - maxEntries)
        }

        return entry
    }

    public var allEntries: [PrismAuditLogEntry] {
        lock.withLock { _entries }
    }

    public var count: Int {
        lock.withLock { _entries.count }
    }

    public func entries(ofKind kind: PrismSecurityEventKind) -> [PrismAuditLogEntry] {
        lock.withLock { _entries.filter { $0.event.kind == kind } }
    }

    public func entries(from start: Date, to end: Date) -> [PrismAuditLogEntry] {
        lock.withLock {
            _entries.filter { $0.event.timestamp >= start && $0.event.timestamp <= end }
        }
    }

    public func recentEntries(_ count: Int) -> [PrismAuditLogEntry] {
        lock.withLock { Array(_entries.suffix(count)) }
    }

    public func verifyIntegrity() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        for (index, entry) in _entries.enumerated() {
            let expectedPrevious = index == 0 ? "" : _entries[index - 1].entryHash
            if entry.previousHash != expectedPrevious {
                return false
            }

            let recomputed = PrismAuditLogEntry(
                event: entry.event,
                previousHash: entry.previousHash,
                sequence: entry.sequence
            )
            if recomputed.entryHash != entry.entryHash {
                return false
            }
        }

        return true
    }

    public func clear() {
        lock.withLock { _entries.removeAll() }
    }

    public func prune() {
        guard let days = retentionDays else { return }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        lock.withLock {
            _entries.removeAll { $0.event.timestamp < cutoff }
        }
    }
}
