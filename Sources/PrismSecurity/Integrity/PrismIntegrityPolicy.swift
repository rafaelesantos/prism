import Foundation

public enum PrismIntegrityAction: String, Sendable, Hashable, CaseIterable {
    case log
    case wipeSecureStore
    case notify
}

public struct PrismIntegrityPolicy: Sendable {
    public let actions: [PrismIntegrityAction]
    public let onViolation: (@Sendable (PrismIntegrityViolation) -> Void)?

    public static let `default` = PrismIntegrityPolicy(actions: [.log])

    public static let strict = PrismIntegrityPolicy(actions: [.log, .wipeSecureStore, .notify])

    public init(
        actions: [PrismIntegrityAction] = [.log],
        onViolation: (@Sendable (PrismIntegrityViolation) -> Void)? = nil
    ) {
        self.actions = actions
        self.onViolation = onViolation
    }
}

public struct PrismIntegrityViolation: Sendable, Equatable {
    public let kind: PrismIntegrityViolationKind
    public let detail: String
    public let detectedAt: Date

    public init(kind: PrismIntegrityViolationKind, detail: String, detectedAt: Date = .now) {
        self.kind = kind
        self.detail = detail
        self.detectedAt = detectedAt
    }
}

public enum PrismIntegrityViolationKind: String, Sendable, Hashable, CaseIterable {
    case jailbreak
    case debuggerAttached
    case simulator
    case dataTampered
    case fileTampered
    case reverseEngineering
}
