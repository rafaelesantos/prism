#if canImport(SQLite3)
    import Foundation

    public struct PrismQueryBuilder: Sendable {
        private let db: PrismDatabase
        private let table: String
        private var selectColumns: [String] = ["*"]
        private var whereClauses: [(String, PrismDatabaseValue)] = []
        private var orderByClause: String?
        private var limitValue: Int?
        private var offsetValue: Int?

        public init(database: PrismDatabase, table: String) {
            self.db = database
            self.table = table
        }

        public func select(_ columns: String...) -> PrismQueryBuilder {
            var copy = self
            copy.selectColumns = columns
            return copy
        }

        public func `where`(_ column: String, _ value: PrismDatabaseValue) -> PrismQueryBuilder {
            var copy = self
            copy.whereClauses.append((column, value))
            return copy
        }

        public func `where`(_ column: String, _ op: String, _ value: PrismDatabaseValue) -> PrismQueryBuilder {
            var copy = self
            copy.whereClauses.append(("\(column) \(op)", value))
            return copy
        }

        public func orderBy(_ column: String, ascending: Bool = true) -> PrismQueryBuilder {
            var copy = self
            copy.orderByClause = "\(column) \(ascending ? "ASC" : "DESC")"
            return copy
        }

        public func limit(_ count: Int) -> PrismQueryBuilder {
            var copy = self
            copy.limitValue = count
            return copy
        }

        public func offset(_ count: Int) -> PrismQueryBuilder {
            var copy = self
            copy.offsetValue = count
            return copy
        }

        public func get() async throws -> [PrismRow] {
            let (sql, params) = buildSelect()
            return try await db.query(sql, parameters: params)
        }

        public func first() async throws -> PrismRow? {
            try await limit(1).get().first
        }

        public func count() async throws -> Int {
            var copy = self
            copy.selectColumns = ["COUNT(*) as count"]
            let rows = try await copy.get()
            return rows.first?.int("count") ?? 0
        }

        public func insert(_ values: [String: PrismDatabaseValue]) async throws -> Int64 {
            let columns = values.keys.sorted()
            let placeholders = columns.map { _ in "?" }.joined(separator: ", ")
            let sql = "INSERT INTO \(table) (\(columns.joined(separator: ", "))) VALUES (\(placeholders))"
            let params = columns.map { values[$0]! }
            try await db.execute(sql, parameters: params)
            return await db.lastInsertID
        }

        @discardableResult
        public func update(_ values: [String: PrismDatabaseValue]) async throws -> Int {
            let setClauses = values.keys.sorted().map { "\($0) = ?" }
            var params = values.keys.sorted().map { values[$0]! }

            var sql = "UPDATE \(table) SET \(setClauses.joined(separator: ", "))"

            if !whereClauses.isEmpty {
                let conditions = whereClauses.map { clause in
                    clause.0.contains(" ") ? "\(clause.0) ?" : "\(clause.0) = ?"
                }
                sql += " WHERE " + conditions.joined(separator: " AND ")
                params.append(contentsOf: whereClauses.map(\.1))
            }

            return try await db.execute(sql, parameters: params)
        }

        @discardableResult
        public func delete() async throws -> Int {
            var sql = "DELETE FROM \(table)"
            var params: [PrismDatabaseValue] = []

            if !whereClauses.isEmpty {
                let conditions = whereClauses.map { clause in
                    clause.0.contains(" ") ? "\(clause.0) ?" : "\(clause.0) = ?"
                }
                sql += " WHERE " + conditions.joined(separator: " AND ")
                params = whereClauses.map(\.1)
            }

            return try await db.execute(sql, parameters: params)
        }

        private func buildSelect() -> (String, [PrismDatabaseValue]) {
            var sql = "SELECT \(selectColumns.joined(separator: ", ")) FROM \(table)"
            var params: [PrismDatabaseValue] = []

            if !whereClauses.isEmpty {
                let conditions = whereClauses.map { clause in
                    clause.0.contains(" ") ? "\(clause.0) ?" : "\(clause.0) = ?"
                }
                sql += " WHERE " + conditions.joined(separator: " AND ")
                params = whereClauses.map(\.1)
            }

            if let orderBy = orderByClause {
                sql += " ORDER BY \(orderBy)"
            }

            if let limit = limitValue {
                sql += " LIMIT \(limit)"
            }

            if let offset = offsetValue {
                sql += " OFFSET \(offset)"
            }

            return (sql, params)
        }
    }

    extension PrismDatabase {
        public func table(_ name: String) -> PrismQueryBuilder {
            PrismQueryBuilder(database: self, table: name)
        }
    }
#endif
