#if canImport(SwiftData)
    import Foundation
    import SwiftData

    @Model
    public final class PrismLeaderboardRecord {
        @Attribute(.unique)
        public var entryID: String

        public var userID: String

        public var displayName: String

        public var score: Int

        public var periodRawValue: String

        public var updatedAt: Date

        public var createdAt: Date

        public init(
            entryID: String,
            userID: String,
            displayName: String,
            score: Int,
            periodRawValue: String,
            updatedAt: Date = .now,
            createdAt: Date = .now
        ) {
            self.entryID = entryID
            self.userID = userID
            self.displayName = displayName
            self.score = score
            self.periodRawValue = periodRawValue
            self.updatedAt = updatedAt
            self.createdAt = createdAt
        }
    }
#endif
