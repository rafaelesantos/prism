#if canImport(SwiftData)
    import Foundation

    public struct PrismChallengeSnapshot: Sendable {
        public let challengeID: String
        public let currentValue: Int
        public let goalValue: Int
        public let isCompleted: Bool
        public let typeRawValue: String
        public let createdAt: Date
        public let updatedAt: Date
        public let completedAt: Date?

        public var progress: Double {
            guard goalValue > 0 else { return 0 }
            return min(Double(currentValue) / Double(goalValue), 1.0)
        }
    }

    extension PrismChallengeProgress {
        public var snapshot: PrismChallengeSnapshot {
            PrismChallengeSnapshot(
                challengeID: challengeID,
                currentValue: currentValue,
                goalValue: goalValue,
                isCompleted: isCompleted,
                typeRawValue: typeRawValue,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt
            )
        }
    }

    public struct PrismStreakSnapshot: Sendable {
        public let streakID: String
        public let currentStreak: Int
        public let longestStreak: Int
        public let lastActivityDate: Date?
        public let totalActiveDays: Int
        public let startedAt: Date
    }

    extension PrismStreakRecord {
        public var snapshot: PrismStreakSnapshot {
            PrismStreakSnapshot(
                streakID: streakID,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastActivityDate: lastActivityDate,
                totalActiveDays: totalActiveDays,
                startedAt: startedAt
            )
        }
    }
#endif
