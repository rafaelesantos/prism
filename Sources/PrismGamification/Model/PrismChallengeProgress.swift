#if canImport(SwiftData)
    import Foundation
    import SwiftData

    @Model
    public final class PrismChallengeProgress {
        @Attribute(.unique)
        public var challengeID: String

        public var currentValue: Int

        public var goalValue: Int

        public var isCompleted: Bool

        public var typeRawValue: String

        public var createdAt: Date

        public var updatedAt: Date

        public var completedAt: Date?

        @Transient
        public var progress: Double {
            guard goalValue > 0 else { return 0 }
            return min(Double(currentValue) / Double(goalValue), 1.0)
        }

        public init(
            challengeID: String,
            currentValue: Int = 0,
            goalValue: Int,
            isCompleted: Bool = false,
            typeRawValue: String,
            createdAt: Date = .now,
            updatedAt: Date = .now,
            completedAt: Date? = nil
        ) {
            self.challengeID = challengeID
            self.currentValue = currentValue
            self.goalValue = goalValue
            self.isCompleted = isCompleted
            self.typeRawValue = typeRawValue
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.completedAt = completedAt
        }
    }
#endif
