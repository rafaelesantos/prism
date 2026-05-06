#if canImport(SwiftData)
    import Foundation
    import SwiftData

    @Model
    public final class PrismBadgeProgress {
        @Attribute(.unique)
        public var badgeID: String

        public var isUnlocked: Bool

        public var tierRawValue: String

        public var unlockedAt: Date?

        public var createdAt: Date

        public init(
            badgeID: String,
            isUnlocked: Bool = false,
            tierRawValue: String,
            unlockedAt: Date? = nil,
            createdAt: Date = .now
        ) {
            self.badgeID = badgeID
            self.isUnlocked = isUnlocked
            self.tierRawValue = tierRawValue
            self.unlockedAt = unlockedAt
            self.createdAt = createdAt
        }
    }
#endif
