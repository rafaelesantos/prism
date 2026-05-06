#if canImport(SwiftData)
    import Foundation
    import SwiftData

    public enum PrismChallengeContainerProvider {
        public static func makeContainer(
            cloudKitContainerIdentifier: String? = nil,
            inMemory: Bool = false
        ) throws -> ModelContainer {
            let schema = Schema([
                PrismChallengeProgress.self,
                PrismStreakRecord.self,
                PrismBadgeProgress.self,
                PrismLeaderboardRecord.self,
                PrismAnalyticsRecord.self,
            ])

            let configuration: ModelConfiguration
            if inMemory {
                configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
            } else if let containerID = cloudKitContainerIdentifier {
                configuration = ModelConfiguration(
                    containerID,
                    schema: schema,
                    cloudKitDatabase: .automatic
                )
            } else {
                configuration = ModelConfiguration(schema: schema)
            }

            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        }
    }
#endif
