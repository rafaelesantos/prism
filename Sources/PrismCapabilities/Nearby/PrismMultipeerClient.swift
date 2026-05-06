import Foundation

// MARK: - Peer

public struct PrismPeer: Sendable {
    public let id: String
    public let displayName: String
    public let isConnected: Bool

    public init(id: String, displayName: String, isConnected: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.isConnected = isConnected
    }
}

// MARK: - Multipeer State

public enum PrismMultipeerState: Sendable, CaseIterable {
    case notConnected
    case connecting
    case connected
}

// MARK: - Multipeer Client

#if canImport(MultipeerConnectivity)
    import MultipeerConnectivity

    private struct SendablePeerID: @unchecked Sendable {
        let peerID: MCPeerID
    }

    @MainActor @Observable
    public final class PrismMultipeerClient: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate,
        MCNearbyServiceBrowserDelegate
    {
        public private(set) var peers: [PrismPeer] = []
        public private(set) var state: PrismMultipeerState = .notConnected

        private var session: MCSession?
        private var localPeerID: MCPeerID?
        private var advertiser: MCNearbyServiceAdvertiser?
        private var browser: MCNearbyServiceBrowser?
        private var knownPeers: [String: MCPeerID] = [:]

        public override init() {
            super.init()
        }

        public func startAdvertising(serviceType: String, displayName: String) {
            let peerID = MCPeerID(displayName: displayName)
            localPeerID = peerID

            let mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            mcSession.delegate = self
            session = mcSession

            let adv = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
            adv.delegate = self
            adv.startAdvertisingPeer()
            advertiser = adv
        }

        public func stopAdvertising() {
            advertiser?.stopAdvertisingPeer()
            advertiser = nil
        }

        public func startBrowsing(serviceType: String, displayName: String = ProcessInfo.processInfo.hostName) {
            if localPeerID == nil {
                let peerID = MCPeerID(displayName: displayName)
                localPeerID = peerID
                let mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
                mcSession.delegate = self
                session = mcSession
            }

            let br = MCNearbyServiceBrowser(peer: localPeerID!, serviceType: serviceType)
            br.delegate = self
            br.startBrowsingForPeers()
            browser = br
        }

        public func stopBrowsing() {
            browser?.stopBrowsingForPeers()
            browser = nil
        }

        public func invitePeer(_ peer: PrismPeer) async throws {
            guard let mcSession = session,
                let mcPeerID = knownPeers[peer.id]
            else {
                return
            }
            browser?.invitePeer(mcPeerID, to: mcSession, withContext: nil, timeout: 30)
        }

        public func send(data: Data, to peers: [PrismPeer]) throws {
            guard let mcSession = session else { return }
            let mcPeers = peers.compactMap { knownPeers[$0.id] }
            guard !mcPeers.isEmpty else { return }
            try mcSession.send(data, toPeers: mcPeers, with: .reliable)
        }

        public func disconnect() {
            session?.disconnect()
            advertiser?.stopAdvertisingPeer()
            browser?.stopBrowsingForPeers()
            session = nil
            advertiser = nil
            browser = nil
            localPeerID = nil
            peers = []
            knownPeers = [:]
            state = .notConnected
        }

        // MARK: - MCSessionDelegate

        nonisolated public func session(_ session: MCSession, peer peerID: MCPeerID, didChange newState: MCSessionState)
        {
            let displayName = peerID.displayName
            let state = newState
            let sendable = SendablePeerID(peerID: peerID)
            Task { @MainActor in
                self.knownPeers[displayName] = sendable.peerID
                switch state {
                case .connected:
                    self.state = .connected
                    if let index = self.peers.firstIndex(where: { $0.id == displayName }) {
                        self.peers[index] = PrismPeer(id: displayName, displayName: displayName, isConnected: true)
                    } else {
                        self.peers.append(PrismPeer(id: displayName, displayName: displayName, isConnected: true))
                    }
                case .connecting:
                    self.state = .connecting
                case .notConnected:
                    if let index = self.peers.firstIndex(where: { $0.id == displayName }) {
                        self.peers[index] = PrismPeer(id: displayName, displayName: displayName, isConnected: false)
                    }
                    if self.peers.allSatisfy({ !$0.isConnected }) {
                        self.state = .notConnected
                    }
                @unknown default:
                    break
                }
            }
        }

        nonisolated public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            // Subclass or extend to handle incoming data
        }

        nonisolated public func session(
            _ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID
        ) {}

        nonisolated public func session(
            _ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID,
            with progress: Progress
        ) {}

        nonisolated public func session(
            _ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID,
            at localURL: URL?, withError error: Error?
        ) {}

        // MARK: - MCNearbyServiceAdvertiserDelegate

        nonisolated public func advertiser(
            _ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
            withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void
        ) {
            nonisolated(unsafe) let handler = invitationHandler
            Task { @MainActor in
                handler(true, self.session)
            }
        }

        // MARK: - MCNearbyServiceBrowserDelegate

        nonisolated public func browser(
            _ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?
        ) {
            let displayName = peerID.displayName
            let sendable = SendablePeerID(peerID: peerID)
            Task { @MainActor in
                self.knownPeers[displayName] = sendable.peerID
                if !self.peers.contains(where: { $0.id == displayName }) {
                    self.peers.append(PrismPeer(id: displayName, displayName: displayName, isConnected: false))
                }
            }
        }

        nonisolated public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
            let displayName = peerID.displayName
            Task { @MainActor in
                self.peers.removeAll { $0.id == displayName }
                self.knownPeers.removeValue(forKey: displayName)
            }
        }
    }
#endif
