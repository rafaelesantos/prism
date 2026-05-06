import Foundation

public struct PrismGamificationMessage: Sendable, Equatable, Identifiable {
    public let id: String
    public let kind: PrismGamificationMessageKind
    public let content: String
    public let entityID: String
    public let generatedAt: Date

    public init(
        id: String = UUID().uuidString,
        kind: PrismGamificationMessageKind,
        content: String,
        entityID: String,
        generatedAt: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.content = content
        self.entityID = entityID
        self.generatedAt = generatedAt
    }
}
