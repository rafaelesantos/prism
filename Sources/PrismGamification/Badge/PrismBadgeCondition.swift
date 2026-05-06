import Foundation

public enum PrismBadgeCondition: Sendable, Equatable {
    case challengeCompleted(challengeID: String)
    case pointsReached(threshold: Int)
    case streakReached(streakID: String, days: Int)
    case custom(id: String)
}
