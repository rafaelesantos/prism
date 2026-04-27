//
//  PrismParallax.swift
//  Prism
//
//  Created by Rafael Escaleira on 07/06/25.
//

import SwiftUI

#if os(iOS)
    import CoreMotion

    /// Parallax (3D motion) effect modifier for the PrismUI Design System.
    ///
    /// `PrismParallaxModifier` creates a depth effect using the gyroscope:
    /// - 3D rotation based on device motion
    /// - Dynamic shine that follows the tilt
    /// - Adjustable sensitivity via threshold
    /// - Width and height customization support
    ///
    /// ## Basic Usage
    /// ```swift
    /// PrismSymbol("rainbow")
    ///     .prismParallax(height: .medium2)
    /// ```
    ///
    /// ## How It Works
    /// - Uses `CMMotionManager` to read gyroscope data
    /// - Applies rotation on X (pitch) and Y (roll) axes
    /// - Creates a shine effect that moves with the tilt
    /// - Updates at 60Hz for smooth animation
    ///
    /// ## Rotation Limits
    /// - Threshold: 35 degrees - minimum angle to activate the effect
    /// - Max rotation: 20 degrees - maximum applied rotation
    ///
    /// - Note: Available only on iOS. The effect requires a physical device with a gyroscope.
    struct PrismParallaxModifier: ViewModifier {
        @Environment(\.theme) var theme
        @State var motion: CMDeviceMotion? = nil

        let motionManager: CMMotionManager = CMMotionManager()
        let threshold: Double = 35 * .pi / 180
        let maxRotationAngle: Double = 20
        let width: PrismSize?
        let height: PrismSize?

        init(
            width: PrismSize?,
            height: PrismSize?
        ) {
            self.width = width
            self.height = height
        }

        var rotation: CGPoint {
            guard let motion else { return .zero }
            let pitch = min(
                maxRotationAngle,
                motion.attitude.pitch > threshold ? (motion.attitude.pitch - threshold) * (100 / .pi) : .zero)
            let roll = min(maxRotationAngle, motion.attitude.roll * (100 / .pi))
            return .init(x: -pitch, y: roll)
        }

        var circleYOffset: CGFloat {
            guard let motion,
                motion.attitude.pitch > threshold
            else { return .zero }
            let offset = (motion.attitude.pitch - threshold) * (600 / .pi)
            return CGFloat(offset)
        }

        var widthValue: CGFloat? {
            width?.rawValue(for: theme.size)
        }

        var heightValue: CGFloat? {
            height?.rawValue(for: theme.size)
        }

        func body(content: Content) -> some View {
            PrismZStack {
                content
                    .scaledToFit()
                    .prism(width: width, height: height)
                    .rotation3DEffect(
                        .degrees(rotation.x),
                        axis: (x: 1, y: .zero, z: .zero)
                    )
                    .rotation3DEffect(
                        .degrees(rotation.y),
                        axis: (x: .zero, y: 1, z: .zero)
                    )

                shineView
            }
            .onAppear(perform: onAppear)
        }

        private func onAppear() {
            guard motionManager.isDeviceMotionAvailable else { return }
            motionManager.deviceMotionUpdateInterval = 1 / 60
            motionManager.startDeviceMotionUpdates(to: .init()) { motion, error in
                if let motion {
                    self.motion = motion
                }
            }
        }

        private var shineView: some View {
            PrismShape(shape: .circle)
                .fill(.white.opacity(0.6))
                .frame(
                    width: width != nil ? widthValue ?? .zero * 0.233 : nil,
                    height: height != nil ? heightValue ?? .zero * 0.233 : nil
                )
                .blur(radius: min(widthValue ?? .zero, heightValue ?? .zero) * 0.133)
                .offset(
                    x: motion != nil ? motion?.gravity.x ?? .zero * 400 : .zero,
                    y: circleYOffset
                )
                .mask { shineMaskView }
        }

        private var shineMaskView: some View {
            PrismShape(shape: .rect(cornerRadius: theme.radius.large))
                .prism(width: width, height: height)
                .rotation3DEffect(
                    .degrees(rotation.x),
                    axis: (x: 1, y: .zero, z: .zero)
                )
                .rotation3DEffect(
                    .degrees(rotation.y),
                    axis: (x: .zero, y: 1, z: .zero)
                )
        }

        static func mocked() -> some View {
            PrismSymbol("rainbow")
                .prism(font: .system(size: 50))
                .prismPadding(.extraLarge)
                .prismParallax(height: .medium2)
        }
    }

    #Preview {
        PrismParallaxModifier.mocked()
    }
#endif
