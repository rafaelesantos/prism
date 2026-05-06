#if canImport(SwiftData)
    import Foundation
    import SwiftData

    public struct PrismContainer: Sendable {
        public static func create(
            for types: [any PersistentModel.Type],
            inMemory: Bool = false,
            cloudKitContainerID: String? = nil,
            migrationPlan: (any SchemaMigrationPlan.Type)? = nil
        ) throws -> ModelContainer {
            let schema = Schema(types)
            var config = ModelConfiguration(
                isStoredInMemoryOnly: inMemory
            )

            if let cloudKitID = cloudKitContainerID {
                config = ModelConfiguration(
                    cloudKitDatabase: .automatic
                )
            }

            if let migrationPlan {
                return try ModelContainer(
                    for: schema,
                    migrationPlan: migrationPlan,
                    configurations: [config]
                )
            }

            return try ModelContainer(
                for: schema,
                configurations: [config]
            )
        }

        public static func inMemory(
            for types: [any PersistentModel.Type]
        ) throws -> ModelContainer {
            try create(for: types, inMemory: true)
        }
    }
#endif
