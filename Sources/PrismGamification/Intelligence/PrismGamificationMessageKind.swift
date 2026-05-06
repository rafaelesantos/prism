import Foundation

public enum PrismGamificationMessageKind: String, Codable, Sendable, CaseIterable {
    case challengeCompleted
    case challengeProgress
    case streakMotivation
    case streakAtRisk
    case badgeUnlocked
    case leaderboardUpdate
    case challengeRecommendation
}
