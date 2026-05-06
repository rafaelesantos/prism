import Foundation

public enum PrismChallengeEvent: Sendable {
    case completed(challengeID: String, points: Int)
    case progressed(challengeID: String, currentValue: Int, goalValue: Int)
    case streakExtended(streakID: String, currentStreak: Int)
    case streakBroken(streakID: String, previousStreak: Int)
    case newStreakRecord(streakID: String, longestStreak: Int)
    case badgeUnlocked(badgeID: String, tier: String)
    case leaderboardUpdated(userID: String, newRank: Int)
}
