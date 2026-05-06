import CryptoKit
import Foundation

public struct PrismSecureEnvelope: Codable, Sendable, Equatable {
    public let ephemeralPublicKey: Data
    public let ciphertext: Data
    public let signature: Data
    public let createdAt: Date

    public static func seal(
        data: Data,
        recipientPublicKey: Data,
        senderSigningKey: P256.Signing.PrivateKey
    ) throws -> PrismSecureEnvelope {
        let ephemeral = P256.KeyAgreement.PrivateKey()
        let recipientKey = try P256.KeyAgreement.PublicKey(rawRepresentation: recipientPublicKey)

        let sharedSecret = try ephemeral.sharedSecretFromKeyAgreement(with: recipientKey)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data("PrismSecureEnvelope".utf8),
            outputByteCount: 32
        )

        let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
        guard let ciphertext = sealedBox.combined else {
            throw PrismSecurityError.encryptionFailed("Failed to seal envelope")
        }

        let ephemeralPubData = ephemeral.publicKey.rawRepresentation
        var signatureInput = ephemeralPubData
        signatureInput.append(ciphertext)
        let signature = try senderSigningKey.signature(for: signatureInput)

        return PrismSecureEnvelope(
            ephemeralPublicKey: ephemeralPubData,
            ciphertext: ciphertext,
            signature: signature.rawRepresentation,
            createdAt: .now
        )
    }

    public static func open(
        _ envelope: PrismSecureEnvelope,
        recipientPrivateKey: P256.KeyAgreement.PrivateKey,
        senderVerifyKey: Data
    ) throws -> Data {
        let verifyKey = try P256.Signing.PublicKey(rawRepresentation: senderVerifyKey)

        var signatureInput = envelope.ephemeralPublicKey
        signatureInput.append(envelope.ciphertext)
        let ecdsaSignature = try P256.Signing.ECDSASignature(rawRepresentation: envelope.signature)

        guard verifyKey.isValidSignature(ecdsaSignature, for: signatureInput) else {
            throw PrismSecurityError.decryptionFailed("Envelope signature verification failed")
        }

        let ephemeralPub = try P256.KeyAgreement.PublicKey(rawRepresentation: envelope.ephemeralPublicKey)
        let sharedSecret = try recipientPrivateKey.sharedSecretFromKeyAgreement(with: ephemeralPub)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data("PrismSecureEnvelope".utf8),
            outputByteCount: 32
        )

        let sealedBox = try AES.GCM.SealedBox(combined: envelope.ciphertext)
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }

    public static func seal<T: Codable & Sendable>(
        _ value: T,
        recipientPublicKey: Data,
        senderSigningKey: P256.Signing.PrivateKey
    ) throws -> PrismSecureEnvelope {
        let data = try JSONEncoder().encode(value)
        return try seal(data: data, recipientPublicKey: recipientPublicKey, senderSigningKey: senderSigningKey)
    }

    public static func open<T: Codable & Sendable>(
        _ type: T.Type,
        from envelope: PrismSecureEnvelope,
        recipientPrivateKey: P256.KeyAgreement.PrivateKey,
        senderVerifyKey: Data
    ) throws -> T {
        let data = try open(envelope, recipientPrivateKey: recipientPrivateKey, senderVerifyKey: senderVerifyKey)
        return try JSONDecoder().decode(type, from: data)
    }
}
