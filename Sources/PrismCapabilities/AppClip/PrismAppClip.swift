import Foundation

// MARK: - App Clip Region

public struct PrismAppClipRegion: Sendable {
    public let latitude: Double
    public let longitude: Double
    public let radius: Double

    public init(latitude: Double, longitude: Double, radius: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
}

// MARK: - App Clip Invocation

public struct PrismAppClipInvocation: Sendable {
    public let url: URL
    public let payload: String?
    public let region: PrismAppClipRegion?

    public init(url: URL, payload: String? = nil, region: PrismAppClipRegion? = nil) {
        self.url = url
        self.payload = payload
        self.region = region
    }
}

// MARK: - App Clip Experience

public enum PrismAppClipExperience: Sendable {
    case defaultExperience
    case advancedExperience(String)
}

// MARK: - App Clip Client

#if canImport(AppClip) && canImport(UIKit)
    import AppClip
    import CoreLocation
    import StoreKit
    import UIKit

    public final class PrismAppClipClient: Sendable {

        public init() {}

        public func handleInvocation(url: URL) -> PrismAppClipInvocation {
            let payload = url.query
            return PrismAppClipInvocation(url: url, payload: payload)
        }

        public func verifyLocation(latitude: Double, longitude: Double) async -> Bool {
            await withCheckedContinuation { continuation in
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    continuation.resume(returning: false)
                    return
                }
                scene.confirmVerifiedPromptForExperience(
                    inRegion: CLCircularRegion(
                        center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                        radius: 100,
                        identifier: "prism-verify"
                    )
                ) { verified, _ in
                    continuation.resume(returning: verified)
                }
            }
        }

        @MainActor
        public func requestFullAppInstall() {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return
            }
            let overlay = SKOverlay(configuration: SKOverlay.AppClipConfiguration(position: .bottom))
            overlay.present(in: scene)
        }
    }
#endif
