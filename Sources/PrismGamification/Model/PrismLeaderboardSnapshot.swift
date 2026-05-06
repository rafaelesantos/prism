#if canImport(SwiftData)
    import Foundation

    public struct PrismLeaderboardSnapshot: Sendable {
        public let entries: [PrismLeaderboardEntry]
        public let period: PrismLeaderboardPeriod
        public let generatedAt: Date
    }

    extension PrismLeaderboardRecord {
        public func toEntry(rank: Int) -> PrismLeaderboardEntry {
            PrismLeaderboardEntry(
                id: userID,
                displayName: displayName,
                score: score,
                rank: rank
            )
        }
    }
#endif
