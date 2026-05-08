#if canImport(SwiftData)
    import SwiftData

    public struct PrismMigrationStage: Sendable {
        public let version: String
        public let description: String
        public let migrationPlan: (any SchemaMigrationPlan.Type)?

        public init(
            version: String,
            description: String,
            migrationPlan: (any SchemaMigrationPlan.Type)? = nil
        ) {
            self.version = version
            self.description = description
            self.migrationPlan = migrationPlan
        }
    }

    public struct PrismMigrationHelper: Sendable {
        public let stages: [PrismMigrationStage]

        public init(stages: [PrismMigrationStage]) {
            self.stages = stages
        }

        public func currentVersion() -> String {
            stages.last?.version ?? "0.0.0"
        }

        public func needsMigration(from: String, to: String) -> Bool {
            guard from != to else { return false }
            let fromIndex = stages.firstIndex(where: { $0.version == from })
            let toIndex = stages.firstIndex(where: { $0.version == to })
            guard let start = fromIndex, let end = toIndex else { return false }
            return start < end
        }

        public func migrationStages(from: String, to: String) -> [PrismMigrationStage] {
            guard let fromIndex = stages.firstIndex(where: { $0.version == from }),
                let toIndex = stages.firstIndex(where: { $0.version == to }),
                fromIndex < toIndex
            else {
                return []
            }
            return Array(stages[(fromIndex + 1)...toIndex])
        }
    }
#endif
