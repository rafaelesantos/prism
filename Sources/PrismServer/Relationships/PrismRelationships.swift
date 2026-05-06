#if canImport(SQLite3)
    import Foundation

    public enum PrismRelationType: Sendable {
        case hasMany
        case hasOne
        case belongsTo
    }

    public struct PrismRelation: Sendable {
        public let type: PrismRelationType
        public let localKey: String
        public let foreignKey: String
        public let relatedTable: String

        public init(type: PrismRelationType, localKey: String, foreignKey: String, relatedTable: String) {
            self.type = type
            self.localKey = localKey
            self.foreignKey = foreignKey
            self.relatedTable = relatedTable
        }

        public static func hasMany(_ table: String, foreignKey: String, localKey: String = "id") -> PrismRelation {
            PrismRelation(type: .hasMany, localKey: localKey, foreignKey: foreignKey, relatedTable: table)
        }

        public static func hasOne(_ table: String, foreignKey: String, localKey: String = "id") -> PrismRelation {
            PrismRelation(type: .hasOne, localKey: localKey, foreignKey: foreignKey, relatedTable: table)
        }

        public static func belongsTo(_ table: String, foreignKey: String, localKey: String = "id") -> PrismRelation {
            PrismRelation(type: .belongsTo, localKey: foreignKey, foreignKey: localKey, relatedTable: table)
        }
    }

    public protocol PrismRelatable: PrismModel {
        static var relations: [String: PrismRelation] { get }
    }

    extension PrismRelatable {
        public static var relations: [String: PrismRelation] { [:] }
    }

    extension PrismDatabase {
        public func loadRelated<T: PrismRelatable>(_ model: T, relation name: String) throws -> [PrismRow] {
            guard let relation = T.relations[name] else {
                throw PrismDatabaseError.executionFailed("Unknown relation: \(name)")
            }

            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(model),
                let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let localValue = dict[relation.localKey]
            else {
                throw PrismDatabaseError.executionFailed("Cannot read local key \(relation.localKey)")
            }

            let valueStr = "\(localValue)"

            switch relation.type {
            case .hasMany:
                return try loadHasMany(relation.relatedTable, foreignKey: relation.foreignKey, localValue: valueStr)
            case .hasOne:
                if let row = try loadHasOne(
                    relation.relatedTable, foreignKey: relation.foreignKey, localValue: valueStr)
                {
                    return [row]
                }
                return []
            case .belongsTo:
                if let row = try loadBelongsTo(
                    relation.relatedTable, primaryKey: relation.foreignKey, foreignValue: valueStr)
                {
                    return [row]
                }
                return []
            }
        }

        public func loadHasMany(_ tableName: String, foreignKey: String, localValue: String) throws -> [PrismRow] {
            try query("SELECT * FROM \(tableName) WHERE \(foreignKey) = ?", parameters: [.text(localValue)])
        }

        public func loadBelongsTo(_ tableName: String, primaryKey: String, foreignValue: String) throws -> PrismRow? {
            try queryFirst(
                "SELECT * FROM \(tableName) WHERE \(primaryKey) = ? LIMIT 1", parameters: [.text(foreignValue)])
        }

        public func loadHasOne(_ tableName: String, foreignKey: String, localValue: String) throws -> PrismRow? {
            try queryFirst(
                "SELECT * FROM \(tableName) WHERE \(foreignKey) = ? LIMIT 1", parameters: [.text(localValue)])
        }
    }
#endif
