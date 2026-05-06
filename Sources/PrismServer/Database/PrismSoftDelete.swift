#if canImport(SQLite3)
import Foundation

public protocol PrismSoftDeletable: PrismModel {}

extension PrismQueryBuilder {
    public func excludeTrashed() -> PrismQueryBuilder {
        whereRaw("deleted_at IS NULL")
    }

    public func onlyTrashed() -> PrismQueryBuilder {
        whereRaw("deleted_at IS NOT NULL")
    }

    public func withTrashed() -> PrismQueryBuilder {
        self
    }
}

extension PrismDatabase {
    @discardableResult
    public func softDelete<T: PrismSoftDeletable>(_ type: T.Type, id: PrismDatabaseValue) async throws -> Int {
        let timestamp = ISO8601DateFormatter().string(from: Date.now)
        return try await execute(
            "UPDATE \(T.tableName) SET deleted_at = ? WHERE \(T.primaryKey) = ?",
            parameters: [.text(timestamp), id]
        )
    }

    @discardableResult
    public func restore<T: PrismSoftDeletable>(_ type: T.Type, id: PrismDatabaseValue) async throws -> Int {
        try await execute(
            "UPDATE \(T.tableName) SET deleted_at = NULL WHERE \(T.primaryKey) = ?",
            parameters: [id]
        )
    }
}
#endif
