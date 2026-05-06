#if canImport(SQLite3)
import Foundation

public struct PrismQueryScope: Sendable {
    public let name: String
    public let apply: @Sendable (PrismQueryBuilder) -> PrismQueryBuilder

    public init(name: String, apply: @escaping @Sendable (PrismQueryBuilder) -> PrismQueryBuilder) {
        self.name = name
        self.apply = apply
    }
}

extension PrismQueryBuilder {
    public func scope(_ scope: PrismQueryScope) -> PrismQueryBuilder {
        scope.apply(self)
    }
}
#endif
