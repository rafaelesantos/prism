#if canImport(SQLite3)
    import Foundation

    public protocol PrismModel: Codable, Sendable {
        static var tableName: String { get }
        static var primaryKey: String { get }
    }

    extension PrismModel {
        public static var tableName: String {
            String(describing: Self.self).lowercased() + "s"
        }

        public static var primaryKey: String { "id" }
    }

    extension PrismDatabase {
        public func all<T: PrismModel>(_ type: T.Type) throws -> [T] {
            let rows = try query("SELECT * FROM \(T.tableName)")
            return try rows.map { try decodeRow($0, as: type) }
        }

        public func find<T: PrismModel>(_ type: T.Type, id: PrismDatabaseValue) throws -> T? {
            let rows = try query(
                "SELECT * FROM \(T.tableName) WHERE \(T.primaryKey) = ? LIMIT 1", parameters: [id])
            return try rows.first.map { try decodeRow($0, as: type) }
        }

        @discardableResult
        public func insert<T: PrismModel>(_ model: T) throws -> Int64 {
            let values = try encodeModel(model)
            let columns = values.keys.sorted()
            let placeholders = columns.map { _ in "?" }.joined(separator: ", ")
            let sql = "INSERT INTO \(T.tableName) (\(columns.joined(separator: ", "))) VALUES (\(placeholders))"
            let params = columns.map { values[$0]! }
            try execute(sql, parameters: params)
            return lastInsertID
        }

        @discardableResult
        public func delete<T: PrismModel>(_ type: T.Type, id: PrismDatabaseValue) throws -> Int {
            try execute("DELETE FROM \(T.tableName) WHERE \(T.primaryKey) = ?", parameters: [id])
        }

        // MARK: - Private

        private func decodeRow<T: Decodable>(_ row: PrismRow, as type: T.Type) throws -> T {
            let dict = row.values.mapValues { value -> Any in
                switch value {
                case .null: return NSNull()
                case .int(let v): return v
                case .double(let v): return v
                case .text(let v): return v
                case .blob(let v): return v
                }
            }
            let data = try JSONSerialization.data(withJSONObject: dict)
            return try JSONDecoder().decode(type, from: data)
        }

        private func encodeModel<T: Encodable>(_ model: T) throws -> [String: PrismDatabaseValue] {
            let data = try JSONEncoder().encode(model)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw PrismDatabaseError.decodingFailed("Model encoding produced non-dictionary")
            }
            var result: [String: PrismDatabaseValue] = [:]
            for (key, value) in dict {
                switch value {
                case is NSNull:
                    result[key] = .null
                case let v as Int:
                    result[key] = .int(v)
                case let v as Double:
                    result[key] = .double(v)
                case let v as String:
                    result[key] = .text(v)
                case let v as Bool:
                    result[key] = .int(v ? 1 : 0)
                default:
                    let nested = try JSONSerialization.data(withJSONObject: value)
                    result[key] = .text(String(data: nested, encoding: .utf8) ?? "")
                }
            }
            return result
        }
    }
#endif
