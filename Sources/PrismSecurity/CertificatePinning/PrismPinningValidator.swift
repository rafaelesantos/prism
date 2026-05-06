import CryptoKit
import Foundation
import Security

public actor PrismPinningValidator {
    private var pins: [String: PrismCertificatePin]
    private let policy: PrismPinningPolicy
    private var tofuStore: [String: String]
    private let violationHandler: (@Sendable (PrismPinningResult) -> Void)?

    public init(
        pins: [PrismCertificatePin] = [],
        policy: PrismPinningPolicy = .strict,
        onViolation: (@Sendable (PrismPinningResult) -> Void)? = nil
    ) {
        var pinMap: [String: PrismCertificatePin] = [:]
        for pin in pins {
            pinMap[pin.host] = pin
        }
        self.pins = pinMap
        self.policy = policy
        self.tofuStore = [:]
        self.violationHandler = onViolation
    }

    public func addPin(_ pin: PrismCertificatePin) {
        pins[pin.host] = pin
    }

    public func removePin(forHost host: String) {
        pins.removeValue(forKey: host)
    }

    public func validate(serverTrust: SecTrust, host: String) -> PrismPinningResult {
        guard let serverPublicKeyHash = extractPublicKeyHash(from: serverTrust) else {
            let result = PrismPinningResult(
                host: host, isValid: false, serverHash: "extraction_failed"
            )
            violationHandler?(result)
            return result
        }

        switch policy {
        case .trustFirstUse:
            return validateTOFU(host: host, serverHash: serverPublicKeyHash)
        case .strict, .reportOnly:
            return validateAgainstPins(host: host, serverHash: serverPublicKeyHash)
        }
    }

    public func validate(publicKeyHash: String, forHost host: String) -> PrismPinningResult {
        switch policy {
        case .trustFirstUse:
            return validateTOFU(host: host, serverHash: publicKeyHash)
        case .strict, .reportOnly:
            return validateAgainstPins(host: host, serverHash: publicKeyHash)
        }
    }

    // MARK: - Private

    private func validateAgainstPins(host: String, serverHash: String) -> PrismPinningResult {
        guard let pin = pins[host] else {
            return PrismPinningResult(
                host: host, isValid: true, serverHash: serverHash
            )
        }

        if pin.isExpired {
            return PrismPinningResult(
                host: host, isValid: true, serverHash: serverHash
            )
        }

        let allHashes = pin.allHashes
        if allHashes.contains(serverHash) {
            return PrismPinningResult(
                host: host, isValid: true, matchedHash: serverHash,
                serverHash: serverHash
            )
        }

        let result = PrismPinningResult(
            host: host, isValid: false, serverHash: serverHash
        )
        violationHandler?(result)
        return result
    }

    private func validateTOFU(host: String, serverHash: String) -> PrismPinningResult {
        if let stored = tofuStore[host] {
            let isValid = stored == serverHash
            let result = PrismPinningResult(
                host: host, isValid: isValid,
                matchedHash: isValid ? serverHash : nil,
                serverHash: serverHash
            )
            if !isValid { violationHandler?(result) }
            return result
        }

        tofuStore[host] = serverHash
        return PrismPinningResult(
            host: host, isValid: true, matchedHash: serverHash,
            serverHash: serverHash
        )
    }

    private func extractPublicKeyHash(from trust: SecTrust) -> String? {
        guard SecTrustGetCertificateCount(trust) > 0,
            let certificate = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
            let leaf = certificate.first
        else { return nil }

        guard let publicKey = SecCertificateCopyKey(leaf) else { return nil }

        var error: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) as? Data else {
            return nil
        }

        return PrismCertificatePin.hash(publicKeyDER: keyData)
    }
}
