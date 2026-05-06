#if canImport(GameKit)
    import GameKit

    // MARK: - Player

    public struct PrismGameCenterPlayer: Sendable {
        public let id: String
        public let displayName: String
        public let alias: String
        public let isAuthenticated: Bool

        public init(id: String, displayName: String, alias: String, isAuthenticated: Bool) {
            self.id = id
            self.displayName = displayName
            self.alias = alias
            self.isAuthenticated = isAuthenticated
        }
    }

    // MARK: - Leaderboard Score

    public struct PrismLeaderboardScore: Sendable {
        public let playerID: String
        public let displayName: String
        public let value: Int
        public let rank: Int
        public let formattedValue: String?
        public let date: Date

        public init(
            playerID: String, displayName: String, value: Int, rank: Int, formattedValue: String? = nil, date: Date
        ) {
            self.playerID = playerID
            self.displayName = displayName
            self.value = value
            self.rank = rank
            self.formattedValue = formattedValue
            self.date = date
        }
    }

    // MARK: - Leaderboard Scope

    public enum PrismLeaderboardScope: Sendable {
        case global
        case friends
    }

    // MARK: - Leaderboard Time Scope

    public enum PrismLeaderboardTimeScope: Sendable, CaseIterable {
        case today
        case week
        case allTime
    }

    // MARK: - Achievement

    public struct PrismAchievement: Sendable {
        public let id: String
        public let title: String
        public let percentComplete: Double
        public let isCompleted: Bool
        public let showsCompletionBanner: Bool

        public init(id: String, title: String, percentComplete: Double, isCompleted: Bool, showsCompletionBanner: Bool)
        {
            self.id = id
            self.title = title
            self.percentComplete = percentComplete
            self.isCompleted = isCompleted
            self.showsCompletionBanner = showsCompletionBanner
        }
    }

    // MARK: - Match Request

    public struct PrismMatchRequest: Sendable {
        public let minPlayers: Int
        public let maxPlayers: Int
        public let playerGroup: Int?
        public let defaultNumberOfPlayers: Int

        public init(minPlayers: Int, maxPlayers: Int, playerGroup: Int? = nil, defaultNumberOfPlayers: Int) {
            self.minPlayers = minPlayers
            self.maxPlayers = maxPlayers
            self.playerGroup = playerGroup
            self.defaultNumberOfPlayers = defaultNumberOfPlayers
        }
    }

    // MARK: - Match Status

    public enum PrismMatchStatus: Sendable, CaseIterable {
        case unknown
        case open
        case ended
        case matching
    }

    // MARK: - Game Center Client

    @MainActor @Observable
    public final class PrismGameCenterClient {
        public private(set) var localPlayer: PrismGameCenterPlayer?
        public private(set) var isAuthenticated: Bool = false

        public init() {}

        @discardableResult
        public func authenticate() async throws -> PrismGameCenterPlayer {
            try await withCheckedThrowingContinuation { continuation in
                GKLocalPlayer.local.authenticateHandler = { viewController, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    let local = GKLocalPlayer.local
                    guard local.isAuthenticated else {
                        continuation.resume(throwing: GKError(.notAuthenticated))
                        return
                    }
                    let player = PrismGameCenterPlayer(
                        id: local.gamePlayerID,
                        displayName: local.displayName,
                        alias: local.alias,
                        isAuthenticated: true
                    )
                    continuation.resume(returning: player)
                }
            }
        }

        public func submitScore(value: Int, leaderboardID: String) async throws {
            try await GKLeaderboard.submitScore(
                value,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [leaderboardID]
            )
        }

        public func loadScores(
            leaderboardID: String, scope: PrismLeaderboardScope, timeScope: PrismLeaderboardTimeScope, range: Range<Int>
        ) async throws -> [PrismLeaderboardScore] {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
            guard let leaderboard = leaderboards.first else { return [] }

            let playerScope: GKLeaderboard.PlayerScope =
                switch scope {
                case .global: .global
                case .friends: .friendsOnly
                }

            let gkTimeScope: GKLeaderboard.TimeScope =
                switch timeScope {
                case .today: .today
                case .week: .week
                case .allTime: .allTime
                }

            let nsRange = NSRange(location: range.lowerBound, length: range.count)
            let (_, entries, _) = try await leaderboard.loadEntries(
                for: playerScope, timeScope: gkTimeScope, range: nsRange)

            return entries.enumerated().map { index, entry in
                PrismLeaderboardScore(
                    playerID: entry.player.gamePlayerID,
                    displayName: entry.player.displayName,
                    value: entry.score,
                    rank: entry.rank,
                    formattedValue: entry.formattedScore,
                    date: entry.date
                )
            }
        }

        public func reportAchievement(id: String, percentComplete: Double) async throws {
            let achievement = GKAchievement(identifier: id)
            achievement.percentComplete = percentComplete
            achievement.showsCompletionBanner = true
            try await GKAchievement.report([achievement])
        }

        public func loadAchievements() async throws -> [PrismAchievement] {
            let gkAchievements = try await GKAchievement.loadAchievements()
            return gkAchievements.map { achievement in
                PrismAchievement(
                    id: achievement.identifier,
                    title: achievement.identifier,
                    percentComplete: achievement.percentComplete,
                    isCompleted: achievement.isCompleted,
                    showsCompletionBanner: achievement.showsCompletionBanner
                )
            }
        }

        public func resetAchievements() async throws {
            try await GKAchievement.resetAchievements()
        }

        public func findMatch(request: PrismMatchRequest) async throws {
            let gkRequest = GKMatchRequest()
            gkRequest.minPlayers = request.minPlayers
            gkRequest.maxPlayers = request.maxPlayers
            gkRequest.defaultNumberOfPlayers = request.defaultNumberOfPlayers
            if let group = request.playerGroup {
                gkRequest.playerGroup = group
            }
            _ = try await GKMatchmaker.shared().findMatch(for: gkRequest)
        }

        public func showLeaderboard(id: String) {
            let viewController = GKGameCenterViewController(
                leaderboardID: id, playerScope: .global, timeScope: .allTime)
            presentGameCenterViewController(viewController)
        }

        public func showAchievements() {
            let viewController = GKGameCenterViewController(state: .achievements)
            presentGameCenterViewController(viewController)
        }

        // MARK: - Private

        private func presentGameCenterViewController(_ viewController: GKGameCenterViewController) {
            #if canImport(UIKit)
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let rootVC = scene.windows.first?.rootViewController
                else { return }
                rootVC.present(viewController, animated: true)
            #elseif canImport(AppKit)
                guard let window = NSApplication.shared.mainWindow else { return }
                window.contentViewController?.presentAsSheet(viewController)
            #endif
        }
    }
#endif
