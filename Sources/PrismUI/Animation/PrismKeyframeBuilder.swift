import SwiftUI

/// Declarative keyframe animation builder using SwiftUI's KeyframeAnimator.
///
/// ```swift
/// PrismKeyframeView(trigger: showItem) { value in
///     Text("Hello")
///         .scaleEffect(value.scale)
///         .opacity(value.opacity)
/// } keyframes: {
///     PrismKeyframeView.Keyframe(at: 0, scale: 0.5, opacity: 0)
///     PrismKeyframeView.Keyframe(at: 0.3, scale: 1.1, opacity: 1)
///     PrismKeyframeView.Keyframe(at: 0.5, scale: 1, opacity: 1)
/// }
/// ```
@MainActor
public struct PrismKeyframeView<Content: View>: View {

    public struct Values: Sendable {
        public var scale: Double
        public var opacity: Double
        public var offsetX: Double
        public var offsetY: Double
        public var rotation: Double

        public init(
            scale: Double = 1,
            opacity: Double = 1,
            offsetX: Double = 0,
            offsetY: Double = 0,
            rotation: Double = 0
        ) {
            self.scale = scale
            self.opacity = opacity
            self.offsetX = offsetX
            self.offsetY = offsetY
            self.rotation = rotation
        }
    }

    private let trigger: Bool
    private let content: (Values) -> Content
    private let frames: [KeyframeFrame]

    public init(
        trigger: Bool,
        @ViewBuilder content: @escaping (Values) -> Content,
        frames: () -> [KeyframeFrame]
    ) {
        self.trigger = trigger
        self.content = content
        self.frames = frames()
    }

    public var body: some View {
        KeyframeAnimator(
            initialValue: frames.first.map { Values(scale: $0.scale, opacity: $0.opacity, offsetX: $0.offsetX, offsetY: $0.offsetY, rotation: $0.rotation) } ?? Values(),
            trigger: trigger
        ) { value in
            content(value)
        } keyframes: { _ in
            KeyframeTrack(\.scale) {
                for frame in frames {
                    SpringKeyframe(frame.scale, duration: frame.duration, spring: .snappy)
                }
            }
            KeyframeTrack(\.opacity) {
                for frame in frames {
                    LinearKeyframe(frame.opacity, duration: frame.duration)
                }
            }
            KeyframeTrack(\.offsetX) {
                for frame in frames {
                    SpringKeyframe(frame.offsetX, duration: frame.duration, spring: .snappy)
                }
            }
            KeyframeTrack(\.offsetY) {
                for frame in frames {
                    SpringKeyframe(frame.offsetY, duration: frame.duration, spring: .snappy)
                }
            }
            KeyframeTrack(\.rotation) {
                for frame in frames {
                    SpringKeyframe(frame.rotation, duration: frame.duration, spring: .snappy)
                }
            }
        }
    }
}

extension PrismKeyframeView {

    public struct KeyframeFrame: Sendable {
        public let duration: Double
        public let scale: Double
        public let opacity: Double
        public let offsetX: Double
        public let offsetY: Double
        public let rotation: Double

        public init(
            duration: Double = 0.3,
            scale: Double = 1,
            opacity: Double = 1,
            offsetX: Double = 0,
            offsetY: Double = 0,
            rotation: Double = 0
        ) {
            self.duration = duration
            self.scale = scale
            self.opacity = opacity
            self.offsetX = offsetX
            self.offsetY = offsetY
            self.rotation = rotation
        }
    }
}

/// Preset keyframe sequences.
extension PrismKeyframeView {

    public static func popIn() -> [KeyframeFrame] {
        [
            KeyframeFrame(duration: 0, scale: 0.3, opacity: 0),
            KeyframeFrame(duration: 0.2, scale: 1.1, opacity: 1),
            KeyframeFrame(duration: 0.15, scale: 0.95, opacity: 1),
            KeyframeFrame(duration: 0.1, scale: 1, opacity: 1),
        ]
    }

    public static func dropIn() -> [KeyframeFrame] {
        [
            KeyframeFrame(duration: 0, scale: 0.8, opacity: 0, offsetY: -40),
            KeyframeFrame(duration: 0.25, scale: 1.05, opacity: 1, offsetY: 5),
            KeyframeFrame(duration: 0.15, scale: 1, opacity: 1, offsetY: 0),
        ]
    }

    public static func flipIn() -> [KeyframeFrame] {
        [
            KeyframeFrame(duration: 0, scale: 0.5, opacity: 0, rotation: -15),
            KeyframeFrame(duration: 0.3, scale: 1.05, opacity: 1, rotation: 3),
            KeyframeFrame(duration: 0.15, scale: 1, opacity: 1, rotation: 0),
        ]
    }

    public static func heartbeat() -> [KeyframeFrame] {
        [
            KeyframeFrame(duration: 0, scale: 1),
            KeyframeFrame(duration: 0.15, scale: 1.2),
            KeyframeFrame(duration: 0.1, scale: 0.95),
            KeyframeFrame(duration: 0.15, scale: 1.15),
            KeyframeFrame(duration: 0.15, scale: 1),
        ]
    }
}
