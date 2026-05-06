#if canImport(SwiftData)
    import Foundation

    public struct PrismAnalyticsSnapshot: Sendable {
        public let totalChallengesStarted: Int
        public let totalChallengesCompleted: Int
        public let completionRate: Double
        public let averageTimeToComplete: TimeInterval?
        public let totalStreakDays: Int
        public let totalBadgesUnlocked: Int
        public let eventCount: Int
        public let periodStart: Date
        public let periodEnd: Date
    }

    public struct PrismAnalyticsRecordSnapshot: Sendable {
        public let recordID: String
        public let eventType: String
        public let entityID: String
        public let timestamp: Date
        public let metadata: String
        public let completionDuration: Double?
    }

    extension PrismAnalyticsRecord {
        public var snapshot: PrismAnalyticsRecordSnapshot {
            PrismAnalyticsRecordSnapshot(
                recordID: recordID,
                eventType: eventType,
                entityID: entityID,
                timestamp: timestamp,
                metadata: metadata,
                completionDuration: completionDuration
            )
        }
    }
#endif
