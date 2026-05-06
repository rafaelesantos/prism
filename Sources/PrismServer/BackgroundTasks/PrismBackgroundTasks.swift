import Foundation

public struct PrismBackgroundTask: Sendable {
    public let id: String
    public let name: String
    public let startedAt: Date
}

public actor PrismBackgroundTaskManager {
    private var tasks: [String: Task<Void, Never>] = [:]
    private var metadata: [String: PrismBackgroundTask] = [:]

    public init() {}

    public func run(_ name: String, task: @escaping @Sendable () async throws -> Void) {
        let id = UUID().uuidString
        let info = PrismBackgroundTask(id: id, name: name, startedAt: Date())
        metadata[id] = info

        let managerRef = self
        let handle = Task<Void, Never> {
            do {
                try await task()
            } catch {
                // Task failed silently — fire-and-forget
            }
            await managerRef.removeTask(id: id)
        }
        tasks[id] = handle
    }

    public func runWithResult<T: Sendable>(_ name: String, task: @escaping @Sendable () async throws -> T) -> Task<
        T, Error
    > {
        let id = UUID().uuidString
        let info = PrismBackgroundTask(id: id, name: name, startedAt: Date())
        metadata[id] = info

        let managerRef = self
        let handle = Task<Void, Never> {
            // Tracking wrapper — actual result is in the returned Task
            await managerRef.removeTask(id: id)
        }
        tasks[id] = handle

        return Task<T, Error> {
            defer { handle.cancel() }
            let result = try await task()
            await managerRef.removeTask(id: id)
            return result
        }
    }

    public func cancelAll() {
        for (_, task) in tasks {
            task.cancel()
        }
        tasks.removeAll()
        metadata.removeAll()
    }

    public func cancel(id: String) {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
        metadata.removeValue(forKey: id)
    }

    public var activeTasks: [PrismBackgroundTask] {
        Array(metadata.values)
    }

    public var activeCount: Int {
        tasks.count
    }

    private func removeTask(id: String) {
        tasks.removeValue(forKey: id)
        metadata.removeValue(forKey: id)
    }
}

public actor PrismTaskGroup {
    private var tasks: [Task<Void, Never>] = []

    public init() {}

    public func add(_ name: String, task: @escaping @Sendable () async throws -> Void) {
        let handle = Task<Void, Never> {
            do {
                try await task()
            } catch {
                // Silently handle errors in group tasks
            }
        }
        tasks.append(handle)
    }

    public func awaitAll() async {
        for task in tasks {
            _ = await task.result
        }
        tasks.removeAll()
    }

    public func cancelAll() {
        for task in tasks {
            task.cancel()
        }
        tasks.removeAll()
    }
}
