#if canImport(SQLite3)
import Foundation

public enum PrismColumnType: Sendable, Equatable {
    case integer
    case text
    case real
    case blob
    case boolean
    case datetime
    case varchar(Int)

    var sql: String {
        switch self {
        case .integer: "INTEGER"
        case .text: "TEXT"
        case .real: "REAL"
        case .blob: "BLOB"
        case .boolean: "INTEGER"
        case .datetime: "TEXT"
        case .varchar(let n): "VARCHAR(\(n))"
        }
    }
}

public enum PrismColumnConstraint: Sendable, Equatable {
    case notNull
    case unique
    case `default`(PrismDatabaseValue)
    case check(String)
    case autoIncrement

    var sql: String {
        switch self {
        case .notNull: "NOT NULL"
        case .unique: "UNIQUE"
        case .default(let value): "DEFAULT \(value.sqlLiteral)"
        case .check(let expr): "CHECK (\(expr))"
        case .autoIncrement: "AUTOINCREMENT"
        }
    }
}

public enum PrismForeignKeyAction: String, Sendable {
    case cascade = "CASCADE"
    case setNull = "SET NULL"
    case restrict = "RESTRICT"
    case noAction = "NO ACTION"
}

public struct PrismColumn: Sendable {
    public let name: String
    public let type: PrismColumnType
    public let constraints: [PrismColumnConstraint]

    public init(name: String, type: PrismColumnType, constraints: [PrismColumnConstraint] = []) {
        self.name = name
        self.type = type
        self.constraints = constraints
    }

    var sql: String {
        var parts = [name, type.sql]
        parts.append(contentsOf: constraints.map(\.sql))
        return parts.joined(separator: " ")
    }
}

public struct PrismForeignKey: Sendable {
    public let column: String
    public let referencesTable: String
    public let referencesColumn: String
    public let onDelete: PrismForeignKeyAction

    public init(column: String, references table: String, column refColumn: String, onDelete: PrismForeignKeyAction = .noAction) {
        self.column = column
        self.referencesTable = table
        self.referencesColumn = refColumn
        self.onDelete = onDelete
    }

    var sql: String {
        "FOREIGN KEY (\(column)) REFERENCES \(referencesTable)(\(referencesColumn)) ON DELETE \(onDelete.rawValue)"
    }
}

public struct PrismTableBuilder: Sendable {
    let tableName: String
    private var columns: [PrismColumn] = []
    private var foreignKeys: [PrismForeignKey] = []
    private var uniqueGroups: [[String]] = []
    private var indices: [[String]] = []

    public init(table: String) {
        self.tableName = table
    }

    public func column(_ name: String, _ type: PrismColumnType, constraints: [PrismColumnConstraint] = []) -> PrismTableBuilder {
        var copy = self
        copy.columns.append(PrismColumn(name: name, type: type, constraints: constraints))
        return copy
    }

    public func primaryKey(_ name: String, autoIncrement: Bool = true) -> PrismTableBuilder {
        var constraints: [PrismColumnConstraint] = []
        if autoIncrement { constraints.append(.autoIncrement) }
        var copy = self
        copy.columns.append(PrismColumn(name: name, type: .integer, constraints: constraints))
        return copy
    }

    public func foreignKey(_ col: String, references table: String, column refCol: String, onDelete: PrismForeignKeyAction = .noAction) -> PrismTableBuilder {
        var copy = self
        copy.foreignKeys.append(PrismForeignKey(column: col, references: table, column: refCol, onDelete: onDelete))
        return copy
    }

    public func unique(_ cols: [String]) -> PrismTableBuilder {
        var copy = self
        copy.uniqueGroups.append(cols)
        return copy
    }

    public func index(_ cols: [String]) -> PrismTableBuilder {
        var copy = self
        copy.indices.append(cols)
        return copy
    }

    public func timestamps() -> PrismTableBuilder {
        column("created_at", .datetime)
            .column("updated_at", .datetime)
    }

    public func softDeletes() -> PrismTableBuilder {
        column("deleted_at", .datetime)
    }

    public func build() -> [String] {
        var statements: [String] = []

        var parts: [String] = []

        for (i, col) in columns.enumerated() {
            if i == 0 && col.type == .integer && col.constraints.contains(.autoIncrement) {
                let constraintsWithoutAI = col.constraints.filter { $0 != .autoIncrement }
                var colParts = [col.name, col.type.sql, "PRIMARY KEY", "AUTOINCREMENT"]
                colParts.append(contentsOf: constraintsWithoutAI.map(\.sql))
                parts.append(colParts.joined(separator: " "))
            } else {
                parts.append(col.sql)
            }
        }

        for group in uniqueGroups {
            parts.append("UNIQUE (\(group.joined(separator: ", ")))")
        }

        for fk in foreignKeys {
            parts.append(fk.sql)
        }

        let createSQL = "CREATE TABLE \(tableName) (\(parts.joined(separator: ", ")))"
        statements.append(createSQL)

        for cols in indices {
            let indexName = "idx_\(tableName)_\(cols.joined(separator: "_"))"
            statements.append("CREATE INDEX \(indexName) ON \(tableName) (\(cols.joined(separator: ", ")))")
        }

        return statements
    }
}

public enum PrismSchemaBuilder {
    public static func create(table: String, builder: (PrismTableBuilder) -> PrismTableBuilder) -> [String] {
        let tableBuilder = PrismTableBuilder(table: table)
        return builder(tableBuilder).build()
    }

    public static func drop(table: String, ifExists: Bool = true) -> String {
        ifExists ? "DROP TABLE IF EXISTS \(table)" : "DROP TABLE \(table)"
    }

    public static func rename(table: String, to newName: String) -> String {
        "ALTER TABLE \(table) RENAME TO \(newName)"
    }
}

extension PrismDatabaseValue {
    var sqlLiteral: String {
        switch self {
        case .null: "NULL"
        case .int(let v): "\(v)"
        case .double(let v): "\(v)"
        case .text(let v): "'\(v)'"
        case .blob: "X''"
        }
    }
}
#endif
