import SwiftUI

extension View {

    public func prismAnimation(
        _ token: MotionToken,
        value: some Equatable
    ) -> some View {
        modifier(ReduceMotionAnimationModifier(token: token, value: value))
    }

    public func prismTransition(_ transition: AnyTransition, motion: MotionToken = .normal) -> some View {
        self.transition(transition)
            .animation(motion.animation, value: UUID())
    }
}

private struct ReduceMotionAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let token: MotionToken
    let value: V

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.animation(token.animation, value: value)
        }
    }
}
