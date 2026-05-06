#if canImport(SwiftData)
    import Foundation
    import SwiftData

    public struct PrismQuery<T: PersistentModel>: Sendable {
        private var predicate: Predicate<T>?
        private var sortDescriptors: [SortDescriptor<T>] = []
        private var fetchLimit: Int?
        private var fetchOffset: Int?

        public init() {}

        public func `where`(_ predicate: Predicate<T>) -> PrismQuery<T> {
            var copy = self
            copy.predicate = predicate
            return copy
        }

        public func sort(_ descriptor: SortDescriptor<T>) -> PrismQuery<T> {
            var copy = self
            copy.sortDescriptors.append(descriptor)
            return copy
        }

        public func limit(_ count: Int) -> PrismQuery<T> {
            var copy = self
            copy.fetchLimit = count
            return copy
        }

        public func offset(_ count: Int) -> PrismQuery<T> {
            var copy = self
            copy.fetchOffset = count
            return copy
        }

        public func build() -> FetchDescriptor<T> {
            var descriptor = FetchDescriptor<T>(
                predicate: predicate,
                sortBy: sortDescriptors
            )
            descriptor.fetchLimit = fetchLimit
            descriptor.fetchOffset = fetchOffset
            return descriptor
        }
    }
#endif
