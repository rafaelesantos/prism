import Foundation

public enum PrismLeaderboardPeriod: String, Codable, Sendable, CaseIterable {
    case daily
    case weekly
    case monthly
    case allTime
}
