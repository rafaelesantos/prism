import Foundation

public struct PrismLeaderboardEntry: Sendable, Identifiable, Comparable, Equatable {
    public let id: String
    public let displayName: String
    public let score: Int
    public let rank: Int

    public init(id: String, displayName: String, score: Int, rank: Int) {
        self.id = id
        self.displayName = displayName
        self.score = score
        self.rank = rank
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rank < rhs.rank
    }
}
