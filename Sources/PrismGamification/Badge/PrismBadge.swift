import Foundation

public protocol PrismBadge: RawRepresentable, CaseIterable, Hashable, Sendable
where RawValue == String {
    var title: String { get }
    var badgeDescription: String { get }
    var iconName: String? { get }
    var tier: PrismBadgeTier { get }
    var condition: PrismBadgeCondition { get }
}

extension PrismBadge {
    public var iconName: String? { nil }
}
