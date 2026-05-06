import Foundation

public struct PrismPrivacyGuard: Sendable {
    private let redactor: PrismRedactor
    private let clipboardGuard: PrismClipboardGuard
    private let fieldClassifications: [String: PrismPrivacyLevel]

    public init(
        redactionStyle: PrismRedactor.Style = .mask,
        clipboardTimeout: TimeInterval = 30,
        fieldClassifications: [String: PrismPrivacyLevel] = Self.defaultClassifications
    ) {
        self.redactor = PrismRedactor(style: redactionStyle)
        self.clipboardGuard = PrismClipboardGuard(clearAfter: clipboardTimeout)
        self.fieldClassifications = fieldClassifications
    }

    public func redact(_ string: String) -> String {
        redactor.redact(string)
    }

    public func redactValue(_ value: String, type: PrismPIIType) -> String {
        redactor.redactValue(value, type: type)
    }

    public func classify(_ fieldName: String) -> PrismPrivacyLevel {
        let lower = fieldName.lowercased()
        if let level = fieldClassifications[lower] { return level }

        let restrictedPatterns = ["password", "secret", "private_key", "ssn", "social_security"]
        if restrictedPatterns.contains(where: { lower.contains($0) }) { return .restricted }

        let sensitivePatterns = ["email", "phone", "address", "birth", "credit_card", "token", "api_key"]
        if sensitivePatterns.contains(where: { lower.contains($0) }) { return .sensitive }

        let internalPatterns = ["user_id", "account", "ip", "device_id"]
        if internalPatterns.contains(where: { lower.contains($0) }) { return .internal }

        return .public
    }

    public func copySecurely(_ string: String) {
        clipboardGuard.copySecurely(string)
    }

    public func clearClipboard() {
        clipboardGuard.clearNow()
    }

    public func protect(field: String, value: String) -> String {
        let level = classify(field)
        switch level {
        case .public:
            return value
        case .internal:
            return value
        case .sensitive:
            return redactor.redact(value)
        case .restricted:
            return "[RESTRICTED]"
        }
    }

    public static let defaultClassifications: [String: PrismPrivacyLevel] = [
        "password": .restricted,
        "secret": .restricted,
        "private_key": .restricted,
        "ssn": .restricted,
        "email": .sensitive,
        "phone": .sensitive,
        "address": .sensitive,
        "credit_card": .sensitive,
        "date_of_birth": .sensitive,
        "user_id": .internal,
        "ip_address": .internal,
        "device_id": .internal,
        "name": .public,
        "username": .public,
    ]
}
