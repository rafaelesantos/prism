#if canImport(SwiftData)
    import Foundation
    import SwiftData

    @Model
    public final class PrismStreakRecord {
        @Attribute(.unique)
        public var streakID: String

        public var currentStreak: Int

        public var longestStreak: Int

        public var lastActivityDate: Date?

        public var totalActiveDays: Int

        public var startedAt: Date

        public init(
            streakID: String,
            currentStreak: Int = 0,
            longestStreak: Int = 0,
            lastActivityDate: Date? = nil,
            totalActiveDays: Int = 0,
            startedAt: Date = .now
        ) {
            self.streakID = streakID
            self.currentStreak = currentStreak
            self.longestStreak = longestStreak
            self.lastActivityDate = lastActivityDate
            self.totalActiveDays = totalActiveDays
            self.startedAt = startedAt
        }
    }
#endif
