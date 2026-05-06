import Foundation

public enum PrismPinningPolicy: String, Sendable, Hashable, CaseIterable {
    case strict
    case reportOnly
    case trustFirstUse
}

public struct PrismPinningResult: Sendable, Equatable {
    public let host: String
    public let isValid: Bool
    public let matchedHash: String?
    public let serverHash: String
    public let evaluatedAt: Date

    public init(
        host: String,
        isValid: Bool,
        matchedHash: String? = nil,
        serverHash: String,
        evaluatedAt: Date = .now
    ) {
        self.host = host
        self.isValid = isValid
        self.matchedHash = matchedHash
        self.serverHash = serverHash
        self.evaluatedAt = evaluatedAt
    }
}
