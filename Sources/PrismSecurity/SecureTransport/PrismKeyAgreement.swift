import CryptoKit
import Foundation

public struct PrismKeyAgreement: Sendable {
    private let privateKey: P256.KeyAgreement.PrivateKey

    public var publicKey: P256.KeyAgreement.PublicKey {
        privateKey.publicKey
    }

    public var publicKeyData: Data {
        privateKey.publicKey.rawRepresentation
    }

    public init() {
        self.privateKey = P256.KeyAgreement.PrivateKey()
    }

    public init(privateKey: P256.KeyAgreement.PrivateKey) {
        self.privateKey = privateKey
    }

    public func deriveSharedSecret(
        with remotePublicKeyData: Data,
        salt: Data? = nil,
        info: Data = Data("PrismSecureTransport".utf8),
        outputByteCount: Int = 32
    ) throws -> SymmetricKey {
        let remotePublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: remotePublicKeyData)
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: remotePublicKey)

        if let salt {
            return sharedSecret.hkdfDerivedSymmetricKey(
                using: SHA256.self,
                salt: salt,
                sharedInfo: info,
                outputByteCount: outputByteCount
            )
        }
        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: info,
            outputByteCount: outputByteCount
        )
    }

    public func deriveSharedSecret(
        with remotePublicKey: P256.KeyAgreement.PublicKey,
        info: Data = Data("PrismSecureTransport".utf8),
        outputByteCount: Int = 32
    ) throws -> SymmetricKey {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: remotePublicKey)
        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: info,
            outputByteCount: outputByteCount
        )
    }
}
