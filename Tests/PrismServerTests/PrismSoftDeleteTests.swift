#if canImport(SQLite3)
import Testing
import Foundation
@testable import PrismServer

struct SoftDeletableItem: PrismSoftDeletable, Equatable {
    let id: Int
    let name: String
    let deleted_at: String?

    static var tableName: String { "items" }
}

@Suite("PrismSoftDelete Tests")
struct PrismSoftDeleteTests {

    private func makeDB() async throws -> PrismDatabase {
        let db = try PrismDatabase()
        try await db.execute("""
            CREATE TABLE items (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                deleted_at TEXT
            )
        """)
        try await db.execute("INSERT INTO items (id, name, deleted_at) VALUES (1, 'active1', NULL)")
        try await db.execute("INSERT INTO items (id, name, deleted_at) VALUES (2, 'active2', NULL)")
        try await db.execute("INSERT INTO items (id, name, deleted_at) VALUES (3, 'deleted1', '2024-01-01T00:00:00Z')")
        try await db.execute("INSERT INTO items (id, name, deleted_at) VALUES (4, 'deleted2', '2024-06-15T12:00:00Z')")
        return db
    }

    @Test("excludeTrashed filters out soft-deleted rows")
    func excludeTrashed() async throws {
        let db = try await makeDB()
        let rows = try await db.table("items").excludeTrashed().orderBy("id").get()
        #expect(rows.count == 2)
        #expect(rows[0].text("name") == "active1")
        #expect(rows[1].text("name") == "active2")
    }

    @Test("onlyTrashed returns only soft-deleted rows")
    func onlyTrashed() async throws {
        let db = try await makeDB()
        let rows = try await db.table("items").onlyTrashed().orderBy("id").get()
        #expect(rows.count == 2)
        #expect(rows[0].text("name") == "deleted1")
        #expect(rows[1].text("name") == "deleted2")
    }

    @Test("withTrashed returns all rows")
    func withTrashed() async throws {
        let db = try await makeDB()
        let rows = try await db.table("items").withTrashed().orderBy("id").get()
        #expect(rows.count == 4)
    }

    @Test("softDelete sets deleted_at timestamp")
    func softDelete() async throws {
        let db = try await makeDB()
        try await db.softDelete(SoftDeletableItem.self, id: .int(1))
        let row = try await db.table("items").where("id", .int(1)).first()
        let deletedAt = row?.text("deleted_at")
        #expect(deletedAt != nil)
        #expect(!deletedAt!.isEmpty)
    }

    @Test("restore clears deleted_at")
    func restore() async throws {
        let db = try await makeDB()
        try await db.restore(SoftDeletableItem.self, id: .int(3))
        let row = try await db.table("items").where("id", .int(3)).first()
        let deletedAt = row?["deleted_at"]
        #expect(deletedAt == .null)
    }

    @Test("softDelete then excludeTrashed hides item")
    func softDeleteThenExclude() async throws {
        let db = try await makeDB()
        try await db.softDelete(SoftDeletableItem.self, id: .int(2))
        let rows = try await db.table("items").excludeTrashed().orderBy("id").get()
        #expect(rows.count == 1)
        #expect(rows[0].text("name") == "active1")
    }

    @Test("restore then onlyTrashed no longer includes item")
    func restoreThenOnlyTrashed() async throws {
        let db = try await makeDB()
        try await db.restore(SoftDeletableItem.self, id: .int(3))
        let rows = try await db.table("items").onlyTrashed().orderBy("id").get()
        #expect(rows.count == 1)
        #expect(rows[0].text("name") == "deleted2")
    }

    @Test("excludeTrashed combined with other where clause")
    func excludeTrashedWithWhere() async throws {
        let db = try await makeDB()
        let rows = try await db.table("items")
            .excludeTrashed()
            .where("name", .text("active1"))
            .get()
        #expect(rows.count == 1)
        #expect(rows[0].int("id") == 1)
    }

    @Test("count with excludeTrashed")
    func countExcludeTrashed() async throws {
        let db = try await makeDB()
        let count = try await db.table("items").excludeTrashed().count()
        #expect(count == 2)
    }
}

@Suite("PrismQueryBuilder whereRaw Tests")
struct PrismWhereRawTests {

    @Test("whereRaw filters rows")
    func whereRawBasic() async throws {
        let db = try PrismDatabase()
        try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, val INTEGER)")
        try await db.execute("INSERT INTO t (val) VALUES (10)")
        try await db.execute("INSERT INTO t (val) VALUES (20)")
        try await db.execute("INSERT INTO t (val) VALUES (30)")
        let rows = try await db.table("t").whereRaw("val > 15").get()
        #expect(rows.count == 2)
    }

    @Test("whereRaw combined with parameterized where")
    func whereRawCombined() async throws {
        let db = try PrismDatabase()
        try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, val INTEGER, active INTEGER)")
        try await db.execute("INSERT INTO t (val, active) VALUES (10, 1)")
        try await db.execute("INSERT INTO t (val, active) VALUES (20, 1)")
        try await db.execute("INSERT INTO t (val, active) VALUES (30, 0)")
        let rows = try await db.table("t")
            .where("active", .int(1))
            .whereRaw("val > 15")
            .get()
        #expect(rows.count == 1)
        #expect(rows[0].int("val") == 20)
    }

    @Test("whereRaw with IS NULL")
    func whereRawIsNull() async throws {
        let db = try PrismDatabase()
        try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, note TEXT)")
        try await db.execute("INSERT INTO t (note) VALUES ('hello')")
        try await db.execute("INSERT INTO t (note) VALUES (NULL)")
        let rows = try await db.table("t").whereRaw("note IS NULL").get()
        #expect(rows.count == 1)
    }

    @Test("whereRaw with IS NOT NULL")
    func whereRawIsNotNull() async throws {
        let db = try PrismDatabase()
        try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, note TEXT)")
        try await db.execute("INSERT INTO t (note) VALUES ('hello')")
        try await db.execute("INSERT INTO t (note) VALUES (NULL)")
        let rows = try await db.table("t").whereRaw("note IS NOT NULL").get()
        #expect(rows.count == 1)
        #expect(rows[0].text("note") == "hello")
    }

    @Test("multiple whereRaw clauses AND together")
    func multipleWhereRaw() async throws {
        let db = try PrismDatabase()
        try await db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY, a INTEGER, b INTEGER)")
        try await db.execute("INSERT INTO t (a, b) VALUES (1, 10)")
        try await db.execute("INSERT INTO t (a, b) VALUES (2, 20)")
        try await db.execute("INSERT INTO t (a, b) VALUES (3, 30)")
        let rows = try await db.table("t")
            .whereRaw("a > 1")
            .whereRaw("b < 30")
            .get()
        #expect(rows.count == 1)
        #expect(rows[0].int("a") == 2)
    }
}
#endif
