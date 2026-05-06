import Foundation

public enum PrismGamificationError: Error, Sendable, Equatable {
    case challengeNotFound(String)
    case challengeAlreadyCompleted(String)
    case persistenceFailed(String)
    case invalidOperation(String)
    case streakNotFound(String)
    case badgeNotFound(String)
    case badgeAlreadyUnlocked(String)
    case leaderboardEntryNotFound(String)
}

extension PrismGamificationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .challengeNotFound(let id):
            "Challenge not found: \(id)"
        case .challengeAlreadyCompleted(let id):
            "Challenge already completed: \(id)"
        case .persistenceFailed(let message):
            "Persistence failed: \(message)"
        case .invalidOperation(let message):
            "Invalid operation: \(message)"
        case .streakNotFound(let id):
            "Streak not found: \(id)"
        case .badgeNotFound(let id):
            "Badge not found: \(id)"
        case .badgeAlreadyUnlocked(let id):
            "Badge already unlocked: \(id)"
        case .leaderboardEntryNotFound(let id):
            "Leaderboard entry not found: \(id)"
        }
    }
}
