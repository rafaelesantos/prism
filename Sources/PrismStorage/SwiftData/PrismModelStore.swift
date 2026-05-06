#if canImport(SwiftData)
    import Foundation
    import SwiftData

    @ModelActor
    public actor PrismModelStore<T: PersistentModel> {
        public func insert(_ model: T) {
            modelContext.insert(model)
            try? modelContext.save()
        }

        public func insertBatch(_ models: [T]) {
            for model in models {
                modelContext.insert(model)
            }
            try? modelContext.save()
        }

        public func fetch(
            _ descriptor: FetchDescriptor<T> = FetchDescriptor<T>()
        ) throws -> [T] {
            try modelContext.fetch(descriptor)
        }

        public func fetch(
            predicate: Predicate<T>? = nil,
            sortBy: [SortDescriptor<T>] = [],
            limit: Int? = nil
        ) throws -> [T] {
            var descriptor = FetchDescriptor<T>(
                predicate: predicate,
                sortBy: sortBy
            )
            descriptor.fetchLimit = limit
            return try modelContext.fetch(descriptor)
        }

        public func count(predicate: Predicate<T>? = nil) throws -> Int {
            var descriptor = FetchDescriptor<T>(predicate: predicate)
            descriptor.fetchLimit = 0
            return try modelContext.fetchCount(descriptor)
        }

        public func delete(_ model: T) {
            modelContext.delete(model)
            try? modelContext.save()
        }

        public func deleteAll(predicate: Predicate<T>? = nil) throws {
            let models = try fetch(predicate: predicate)
            for model in models {
                modelContext.delete(model)
            }
            try modelContext.save()
        }

        public func save() throws {
            try modelContext.save()
        }

        public func transaction(_ work: (ModelContext) throws -> Void) throws {
            try work(modelContext)
            try modelContext.save()
        }

        public func exists(predicate: Predicate<T>? = nil) throws -> Bool {
            try count(predicate: predicate) > 0
        }
    }
#endif
