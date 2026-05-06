#if canImport(SQLite3)
    import Foundation

    public struct PrismMigration: Sendable {
        public let version: Int
        public let name: String
        public let up: String
        public let down: String

        public init(version: Int, name: String, up: String, down: String = "") {
            self.version = version
            self.name = name
            self.up = up
            self.down = down
        }
    }

    public struct PrismMigrator: Sendable {
        private let db: PrismDatabase
        private let migrations: [PrismMigration]

        public init(database: PrismDatabase, migrations: [PrismMigration]) {
            self.db = database
            self.migrations = migrations.sorted { $0.version < $1.version }
        }

        public func migrate() async throws {
            try await createMigrationsTable()
            let applied = try await appliedVersions()

            for migration in migrations where !applied.contains(migration.version) {
                try await db.transaction { db in
                    try db.execute(migration.up)
                    try db.execute(
                        "INSERT INTO _prism_migrations (version, name, applied_at) VALUES (?, ?, ?)",
                        parameters: [
                            .int(migration.version), .text(migration.name),
                            .text(ISO8601DateFormatter().string(from: .now)),
                        ]
                    )
                }
            }
        }

        public func rollback() async throws {
            let applied = try await appliedVersions()
            guard let lastVersion = applied.max(),
                let migration = migrations.first(where: { $0.version == lastVersion })
            else {
                return
            }

            guard !migration.down.isEmpty else {
                throw PrismDatabaseError.migrationFailed("No rollback SQL for migration \(migration.version)")
            }

            try await db.transaction { db in
                try db.execute(migration.down)
                try db.execute("DELETE FROM _prism_migrations WHERE version = ?", parameters: [.int(migration.version)])
            }
        }

        private func createMigrationsTable() async throws {
            try await db.execute(
                """
                CREATE TABLE IF NOT EXISTS _prism_migrations (
                    version INTEGER PRIMARY KEY,
                    name TEXT NOT NULL,
                    applied_at TEXT NOT NULL
                )
                """)
        }

        private func appliedVersions() async throws -> Set<Int> {
            let rows = try await db.query("SELECT version FROM _prism_migrations")
            return Set(rows.compactMap { $0.int("version") })
        }
    }
#endif
