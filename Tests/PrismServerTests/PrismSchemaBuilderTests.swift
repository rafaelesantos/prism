#if canImport(SQLite3)
    import Foundation
    import Testing

    @testable import PrismServer

    @Suite("PrismSchemaBuilder Tests")
    struct PrismSchemaBuilderTests {

        @Test("Create table with basic columns")
        func basicColumns() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("name", .text)
                    .column("age", .integer)
            }
            #expect(sql.count == 1)
            #expect(sql[0] == "CREATE TABLE users (name TEXT, age INTEGER)")
        }

        @Test("Primary key with autoincrement")
        func primaryKey() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.primaryKey("id")
                    .column("name", .text)
            }
            #expect(sql[0].contains("id INTEGER PRIMARY KEY AUTOINCREMENT"))
        }

        @Test("Primary key without autoincrement")
        func primaryKeyNoAuto() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.primaryKey("id", autoIncrement: false)
                    .column("name", .text)
            }
            #expect(sql[0] == "CREATE TABLE users (id INTEGER, name TEXT)")
        }

        @Test("NOT NULL constraint")
        func notNullConstraint() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("email", .text, constraints: [.notNull])
            }
            #expect(sql[0].contains("email TEXT NOT NULL"))
        }

        @Test("UNIQUE constraint")
        func uniqueConstraint() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("email", .text, constraints: [.unique])
            }
            #expect(sql[0].contains("email TEXT UNIQUE"))
        }

        @Test("DEFAULT constraint with integer")
        func defaultInt() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("age", .integer, constraints: [.default(.int(0))])
            }
            #expect(sql[0].contains("age INTEGER DEFAULT 0"))
        }

        @Test("DEFAULT constraint with text")
        func defaultText() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("role", .text, constraints: [.default(.text("user"))])
            }
            #expect(sql[0].contains("role TEXT DEFAULT 'user'"))
        }

        @Test("CHECK constraint")
        func checkConstraint() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("age", .integer, constraints: [.check("age >= 0")])
            }
            #expect(sql[0].contains("CHECK (age >= 0)"))
        }

        @Test("Multiple constraints on one column")
        func multipleConstraints() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("email", .text, constraints: [.notNull, .unique])
            }
            #expect(sql[0].contains("email TEXT NOT NULL UNIQUE"))
        }

        @Test("Foreign key generation")
        func foreignKey() {
            let sql = PrismSchemaBuilder.create(table: "posts") { t in
                t.primaryKey("id")
                    .column("user_id", .integer, constraints: [.notNull])
                    .foreignKey("user_id", references: "users", column: "id", onDelete: .cascade)
            }
            #expect(sql[0].contains("FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE"))
        }

        @Test("Multiple foreign keys")
        func multipleForeignKeys() {
            let sql = PrismSchemaBuilder.create(table: "comments") { t in
                t.primaryKey("id")
                    .column("user_id", .integer)
                    .column("post_id", .integer)
                    .foreignKey("user_id", references: "users", column: "id", onDelete: .setNull)
                    .foreignKey("post_id", references: "posts", column: "id", onDelete: .cascade)
            }
            #expect(sql[0].contains("FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL"))
            #expect(sql[0].contains("FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE"))
        }

        @Test("Timestamps helper adds created_at and updated_at")
        func timestamps() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.primaryKey("id")
                    .timestamps()
            }
            #expect(sql[0].contains("created_at TEXT"))
            #expect(sql[0].contains("updated_at TEXT"))
        }

        @Test("SoftDeletes helper adds deleted_at")
        func softDeletes() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.primaryKey("id")
                    .softDeletes()
            }
            #expect(sql[0].contains("deleted_at TEXT"))
        }

        @Test("Composite unique constraint")
        func compositeUnique() {
            let sql = PrismSchemaBuilder.create(table: "user_roles") { t in
                t.column("user_id", .integer)
                    .column("role_id", .integer)
                    .unique(["user_id", "role_id"])
            }
            #expect(sql[0].contains("UNIQUE (user_id, role_id)"))
        }

        @Test("Index generates separate CREATE INDEX statement")
        func indexStatement() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("email", .text)
                    .index(["email"])
            }
            #expect(sql.count == 2)
            #expect(sql[1] == "CREATE INDEX idx_users_email ON users (email)")
        }

        @Test("Multiple indices")
        func multipleIndices() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("email", .text)
                    .column("name", .text)
                    .index(["email"])
                    .index(["name", "email"])
            }
            #expect(sql.count == 3)
            #expect(sql[1] == "CREATE INDEX idx_users_email ON users (email)")
            #expect(sql[2] == "CREATE INDEX idx_users_name_email ON users (name, email)")
        }

        @Test("Drop table with IF EXISTS")
        func dropIfExists() {
            let sql = PrismSchemaBuilder.drop(table: "users")
            #expect(sql == "DROP TABLE IF EXISTS users")
        }

        @Test("Drop table without IF EXISTS")
        func dropWithout() {
            let sql = PrismSchemaBuilder.drop(table: "users", ifExists: false)
            #expect(sql == "DROP TABLE users")
        }

        @Test("Rename table")
        func rename() {
            let sql = PrismSchemaBuilder.rename(table: "users", to: "accounts")
            #expect(sql == "ALTER TABLE users RENAME TO accounts")
        }

        @Test("Boolean column type maps to INTEGER")
        func booleanType() {
            let sql = PrismSchemaBuilder.create(table: "flags") { t in
                t.column("active", .boolean)
            }
            #expect(sql[0] == "CREATE TABLE flags (active INTEGER)")
        }

        @Test("Datetime column type maps to TEXT")
        func datetimeType() {
            let sql = PrismSchemaBuilder.create(table: "events") { t in
                t.column("starts_at", .datetime)
            }
            #expect(sql[0] == "CREATE TABLE events (starts_at TEXT)")
        }

        @Test("VARCHAR(N) column type")
        func varcharType() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("code", .varchar(10))
            }
            #expect(sql[0] == "CREATE TABLE users (code VARCHAR(10))")
        }

        @Test("Real column type")
        func realType() {
            let sql = PrismSchemaBuilder.create(table: "products") { t in
                t.column("price", .real)
            }
            #expect(sql[0] == "CREATE TABLE products (price REAL)")
        }

        @Test("Blob column type")
        func blobType() {
            let sql = PrismSchemaBuilder.create(table: "files") { t in
                t.column("data", .blob)
            }
            #expect(sql[0] == "CREATE TABLE files (data BLOB)")
        }

        @Test("Full table with all features")
        func fullTable() {
            let sql = PrismSchemaBuilder.create(table: "posts") { t in
                t.primaryKey("id")
                    .column("title", .text, constraints: [.notNull])
                    .column("body", .text)
                    .column("user_id", .integer, constraints: [.notNull])
                    .column("views", .integer, constraints: [.default(.int(0))])
                    .timestamps()
                    .softDeletes()
                    .foreignKey("user_id", references: "users", column: "id", onDelete: .cascade)
                    .unique(["title", "user_id"])
                    .index(["user_id"])
            }
            #expect(sql.count == 2)
            let create = sql[0]
            #expect(create.contains("id INTEGER PRIMARY KEY AUTOINCREMENT"))
            #expect(create.contains("title TEXT NOT NULL"))
            #expect(create.contains("user_id INTEGER NOT NULL"))
            #expect(create.contains("views INTEGER DEFAULT 0"))
            #expect(create.contains("created_at TEXT"))
            #expect(create.contains("updated_at TEXT"))
            #expect(create.contains("deleted_at TEXT"))
            #expect(create.contains("UNIQUE (title, user_id)"))
            #expect(create.contains("FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE"))
            #expect(sql[1].contains("CREATE INDEX idx_posts_user_id"))
        }

        @Test("Foreign key default action is NO ACTION")
        func foreignKeyDefaultAction() {
            let sql = PrismSchemaBuilder.create(table: "posts") { t in
                t.column("user_id", .integer)
                    .foreignKey("user_id", references: "users", column: "id")
            }
            #expect(sql[0].contains("ON DELETE NO ACTION"))
        }

        @Test("DEFAULT NULL")
        func defaultNull() {
            let sql = PrismSchemaBuilder.create(table: "users") { t in
                t.column("bio", .text, constraints: [.default(.null)])
            }
            #expect(sql[0].contains("DEFAULT NULL"))
        }
    }

    @Suite("PrismColumnType Tests")
    struct PrismColumnTypeTests {

        @Test("All types produce valid SQL")
        func allTypes() {
            #expect(PrismColumnType.integer.sql == "INTEGER")
            #expect(PrismColumnType.text.sql == "TEXT")
            #expect(PrismColumnType.real.sql == "REAL")
            #expect(PrismColumnType.blob.sql == "BLOB")
            #expect(PrismColumnType.boolean.sql == "INTEGER")
            #expect(PrismColumnType.datetime.sql == "TEXT")
            #expect(PrismColumnType.varchar(255).sql == "VARCHAR(255)")
        }
    }

    @Suite("PrismForeignKeyAction Tests")
    struct PrismForeignKeyActionTests {

        @Test("All actions have correct raw values")
        func allActions() {
            #expect(PrismForeignKeyAction.cascade.rawValue == "CASCADE")
            #expect(PrismForeignKeyAction.setNull.rawValue == "SET NULL")
            #expect(PrismForeignKeyAction.restrict.rawValue == "RESTRICT")
            #expect(PrismForeignKeyAction.noAction.rawValue == "NO ACTION")
        }
    }
#endif
