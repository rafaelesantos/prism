import Foundation

public struct PrismTokenConfiguration: Sendable {
    public let service: String
    public let accessTokenKey: String
    public let refreshTokenKey: String
    public let refreshThreshold: TimeInterval
    public let refreshStrategy: PrismTokenRefreshStrategy

    public static let `default` = PrismTokenConfiguration(
        service: "PrismTokenManager",
        accessTokenKey: "access_token",
        refreshTokenKey: "refresh_token",
        refreshThreshold: 300,
        refreshStrategy: .proactive
    )

    public init(
        service: String = "PrismTokenManager",
        accessTokenKey: String = "access_token",
        refreshTokenKey: String = "refresh_token",
        refreshThreshold: TimeInterval = 300,
        refreshStrategy: PrismTokenRefreshStrategy = .proactive
    ) {
        self.service = service
        self.accessTokenKey = accessTokenKey
        self.refreshTokenKey = refreshTokenKey
        self.refreshThreshold = refreshThreshold
        self.refreshStrategy = refreshStrategy
    }
}

public enum PrismTokenRefreshStrategy: String, Sendable, Hashable, CaseIterable {
    case proactive
    case reactive
    case manual
}
