import Foundation

public enum PrismPrivacyLevel: String, Sendable, Hashable, CaseIterable, Comparable {
    case `public`
    case `internal`
    case sensitive
    case restricted

    public static func < (lhs: PrismPrivacyLevel, rhs: PrismPrivacyLevel) -> Bool {
        let order: [PrismPrivacyLevel] = [.public, .internal, .sensitive, .restricted]
        let lhsIndex = order.firstIndex(of: lhs) ?? 0
        let rhsIndex = order.firstIndex(of: rhs) ?? 0
        return lhsIndex < rhsIndex
    }
}
