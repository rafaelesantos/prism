import Foundation

// MARK: - Call Type

public enum PrismCallType: Sendable {
    case generic
    case audio
    case video
}

// MARK: - Call End Reason

public enum PrismCallEndReason: Sendable, CaseIterable {
    case failed
    case remoteEnded
    case unanswered
    case answeredElsewhere
    case declinedElsewhere
}

// MARK: - Call Info

public struct PrismCallInfo: Sendable {
    public let id: UUID
    public let handle: String
    public let displayName: String?
    public let type: PrismCallType
    public let isOutgoing: Bool
    public let hasVideo: Bool

    public init(
        id: UUID = UUID(), handle: String, displayName: String? = nil, type: PrismCallType = .audio,
        isOutgoing: Bool = false, hasVideo: Bool = false
    ) {
        self.id = id
        self.handle = handle
        self.displayName = displayName
        self.type = type
        self.isOutgoing = isOutgoing
        self.hasVideo = hasVideo
    }
}

// MARK: - Blocked Caller

public struct PrismBlockedCaller: Sendable {
    public let phoneNumber: String
    public let label: String?

    public init(phoneNumber: String, label: String? = nil) {
        self.phoneNumber = phoneNumber
        self.label = label
    }
}

// MARK: - Call Action

public enum PrismCallAction: Sendable {
    case start(PrismCallInfo)
    case answer(UUID)
    case end(UUID)
    case hold(UUID, Bool)
    case mute(UUID, Bool)
}

// MARK: - Call Client

#if canImport(CallKit) && (os(iOS) || os(watchOS))
    import CallKit

    @MainActor @Observable
    public final class PrismCallClient {
        private let provider: CXProvider
        private let callController: CXCallController

        public init() {
            let configuration = CXProviderConfiguration()
            configuration.supportsVideo = true
            configuration.maximumCallsPerCallGroup = 1
            self.provider = CXProvider(configuration: configuration)
            self.callController = CXCallController()
        }

        public func reportIncomingCall(info: PrismCallInfo) async throws {
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .phoneNumber, value: info.handle)
            update.localizedCallerName = info.displayName
            update.hasVideo = info.hasVideo
            try await provider.reportNewIncomingCall(with: info.id, update: update)
        }

        public func reportOutgoingCall(info: PrismCallInfo) {
            provider.reportOutgoingCall(with: info.id, startedConnectingAt: Date())
        }

        public func reportCallEnded(id: UUID, reason: PrismCallEndReason) {
            let cxReason: CXCallEndedReason =
                switch reason {
                case .failed: .failed
                case .remoteEnded: .remoteEnded
                case .unanswered: .unanswered
                case .answeredElsewhere: .answeredElsewhere
                case .declinedElsewhere: .declinedElsewhere
                }
            provider.reportCall(with: id, endedAt: Date(), reason: cxReason)
        }

        public func reportCallConnected(id: UUID) {
            provider.reportOutgoingCall(with: id, connectedAt: Date())
        }

        public func requestTransaction(action: PrismCallAction) async throws {
            let cxAction: CXAction =
                switch action {
                case .start(let info):
                    CXStartCallAction(call: info.id, handle: CXHandle(type: .phoneNumber, value: info.handle))
                case .answer(let id):
                    CXAnswerCallAction(call: id)
                case .end(let id):
                    CXEndCallAction(call: id)
                case .hold(let id, let onHold):
                    CXSetHeldCallAction(call: id, onHold: onHold)
                case .mute(let id, let muted):
                    CXSetMutedCallAction(call: id, muted: muted)
                }
            let transaction = CXTransaction(action: cxAction)
            try await callController.request(transaction)
        }
    }
#endif
