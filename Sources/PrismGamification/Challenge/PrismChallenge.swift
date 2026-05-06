import Foundation

public protocol PrismChallenge: RawRepresentable, CaseIterable, Hashable, Sendable
where RawValue == String {
    var title: String { get }
    var challengeDescription: String { get }
    var type: PrismChallengeType { get }
    var goal: Int { get }
    var category: String? { get }
    var iconName: String? { get }
    var points: Int { get }
}

extension PrismChallenge {
    public var category: String? { nil }
    public var iconName: String? { nil }
    public var points: Int { 0 }
}
