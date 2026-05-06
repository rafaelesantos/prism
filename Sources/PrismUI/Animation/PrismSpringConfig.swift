import SwiftUI

public struct PrismSpringConfig: Sendable, Hashable {
    public let response: Double
    public let dampingFraction: Double
    public let blendDuration: Double

    public init(response: Double, dampingFraction: Double, blendDuration: Double = 0) {
        self.response = response
        self.dampingFraction = dampingFraction
        self.blendDuration = blendDuration
    }

    public var animation: Animation {
        .spring(response: response, dampingFraction: dampingFraction, blendDuration: blendDuration)
    }
}

extension PrismSpringConfig {

    public static let snappy = PrismSpringConfig(response: 0.25, dampingFraction: 0.8)

    public static let gentle = PrismSpringConfig(response: 0.5, dampingFraction: 0.75)

    public static let bouncy = PrismSpringConfig(response: 0.4, dampingFraction: 0.5)

    public static let stiff = PrismSpringConfig(response: 0.2, dampingFraction: 0.9)

    public static let dramatic = PrismSpringConfig(response: 0.7, dampingFraction: 0.65)

    public static let critical = PrismSpringConfig(response: 0.15, dampingFraction: 1.0)

    public static let rubber = PrismSpringConfig(response: 0.35, dampingFraction: 0.4)
}

extension View {

    public func prismSpring(
        _ config: PrismSpringConfig,
        value: some Equatable
    ) -> some View {
        animation(config.animation, value: value)
    }
}
