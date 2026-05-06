#if canImport(SwiftData)
    import Foundation

    public struct PrismBadgeSnapshot: Sendable {
        public let badgeID: String
        public let isUnlocked: Bool
        public let tierRawValue: String
        public let unlockedAt: Date?
        public let createdAt: Date
    }

    extension PrismBadgeProgress {
        public var snapshot: PrismBadgeSnapshot {
            PrismBadgeSnapshot(
                badgeID: badgeID,
                isUnlocked: isUnlocked,
                tierRawValue: tierRawValue,
                unlockedAt: unlockedAt,
                createdAt: createdAt
            )
        }
    }
#endif
