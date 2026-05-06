#if canImport(SQLite3)
    import Foundation

    public actor PrismConnectionPool {
        private var available: [PrismDatabase] = []
        private var inUse: Int = 0
        private let maxConnections: Int
        private let path: String
        private var waiters: [CheckedContinuation<PrismDatabase, any Error>] = []

        public init(path: String, maxConnections: Int = 5) throws {
            self.path = path
            self.maxConnections = maxConnections

            let initial = try PrismDatabase(path: path)
            available.append(initial)
        }

        public func acquire() async throws -> PrismDatabase {
            if let conn = available.popLast() {
                inUse += 1
                return conn
            }

            if inUse < maxConnections {
                let conn = try PrismDatabase(path: path)
                inUse += 1
                return conn
            }

            return try await withCheckedThrowingContinuation { continuation in
                waiters.append(continuation)
            }
        }

        public func release(_ connection: PrismDatabase) {
            inUse -= 1

            if let waiter = waiters.first {
                waiters.removeFirst()
                inUse += 1
                waiter.resume(returning: connection)
            } else {
                available.append(connection)
            }
        }

        public func withConnection<T: Sendable>(_ block: (PrismDatabase) async throws -> T) async throws -> T {
            let conn = try await acquire()
            do {
                let result = try await block(conn)
                release(conn)
                return result
            } catch {
                release(conn)
                throw error
            }
        }

        public var activeCount: Int { inUse }

        public var idleCount: Int { available.count }

        public var totalCount: Int { inUse + available.count }
    }
#endif
