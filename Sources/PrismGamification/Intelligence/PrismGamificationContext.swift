import Foundation

public struct PrismGamificationContext: Sendable, Equatable {
    public let entityID: String
    public let challengeTitle: String?
    public let currentValue: Int?
    public let goalValue: Int?
    public let points: Int?
    public let totalPoints: Int?
    public let currentStreak: Int?
    public let longestStreak: Int?
    public let badgeTitle: String?
    public let badgeTier: String?
    public let rank: Int?
    public let previousRank: Int?
    public let score: Int?
    public let completedChallenges: Int?
    public let activeCategories: [String]?

    public init(
        entityID: String,
        challengeTitle: String? = nil,
        currentValue: Int? = nil,
        goalValue: Int? = nil,
        points: Int? = nil,
        totalPoints: Int? = nil,
        currentStreak: Int? = nil,
        longestStreak: Int? = nil,
        badgeTitle: String? = nil,
        badgeTier: String? = nil,
        rank: Int? = nil,
        previousRank: Int? = nil,
        score: Int? = nil,
        completedChallenges: Int? = nil,
        activeCategories: [String]? = nil
    ) {
        self.entityID = entityID
        self.challengeTitle = challengeTitle
        self.currentValue = currentValue
        self.goalValue = goalValue
        self.points = points
        self.totalPoints = totalPoints
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.badgeTitle = badgeTitle
        self.badgeTier = badgeTier
        self.rank = rank
        self.previousRank = previousRank
        self.score = score
        self.completedChallenges = completedChallenges
        self.activeCategories = activeCategories
    }
}
