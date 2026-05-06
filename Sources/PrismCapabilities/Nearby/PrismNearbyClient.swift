import Foundation

// MARK: - Nearby Object

public struct PrismNearbyObject: Sendable {
    public let peerToken: Data
    public let distance: Float?
    public let direction: SIMD3<Float>?

    public init(peerToken: Data, distance: Float? = nil, direction: SIMD3<Float>? = nil) {
        self.peerToken = peerToken
        self.distance = distance
        self.direction = direction
    }
}

// MARK: - Session State

public enum PrismNearbySessionState: Sendable, CaseIterable {
    case idle
    case running
    case suspended
    case invalidated
}

// MARK: - Nearby Client

#if canImport(NearbyInteraction) && os(iOS)
    import NearbyInteraction

    @MainActor @Observable
    public final class PrismNearbyClient: NSObject, NISessionDelegate {
        public private(set) var sessionState: PrismNearbySessionState = .idle
        public private(set) var nearbyObjects: [PrismNearbyObject] = []

        private var session: NISession?

        public override init() {
            super.init()
        }

        public func start(peerToken: Data) {
            session?.invalidate()
            let niSession = NISession()
            niSession.delegate = self
            session = niSession

            guard let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: peerToken)
            else { return }
            let config = NINearbyPeerConfiguration(peerToken: token)
            niSession.run(config)
            sessionState = .running
        }

        public func stop() {
            session?.invalidate()
            session = nil
            sessionState = .idle
            nearbyObjects = []
        }

        public func generateToken() -> Data? {
            let niSession = NISession()
            session = niSession
            guard let token = niSession.discoveryToken else { return nil }
            return try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
        }

        // MARK: - NISessionDelegate

        private nonisolated func tokenData(from token: NIDiscoveryToken) -> Data {
            (try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)) ?? Data()
        }

        nonisolated public func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
            let objects = nearbyObjects.map { obj in
                PrismNearbyObject(
                    peerToken: tokenData(from: obj.discoveryToken),
                    distance: obj.distance,
                    direction: obj.direction
                )
            }
            Task { @MainActor in
                self.nearbyObjects = objects
            }
        }

        nonisolated public func session(
            _ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason
        ) {
            let removedTokens = Set(nearbyObjects.map { tokenData(from: $0.discoveryToken) })
            Task { @MainActor in
                self.nearbyObjects.removeAll { removedTokens.contains($0.peerToken) }
            }
        }

        nonisolated public func sessionWasSuspended(_ session: NISession) {
            Task { @MainActor in
                self.sessionState = .suspended
            }
        }

        nonisolated public func sessionSuspensionEnded(_ session: NISession) {
            Task { @MainActor in
                self.sessionState = .running
            }
        }

        nonisolated public func session(_ session: NISession, didInvalidateWith error: Error) {
            Task { @MainActor in
                self.sessionState = .invalidated
                self.nearbyObjects = []
            }
        }
    }
#endif
