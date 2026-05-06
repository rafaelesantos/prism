import CryptoKit
import Foundation
import Security

public struct PrismSecureEnclave: Sendable {
    private let keychain: PrismKeychain

    public init(keychain: PrismKeychain = PrismKeychain(service: "PrismSecureEnclave")) {
        self.keychain = keychain
    }

    public static var isAvailable: Bool {
        SecureEnclave.isAvailable
    }

    @discardableResult
    public func generateKeyPair(tag: String) throws -> Data {
        guard SecureEnclave.isAvailable else {
            throw PrismSecurityError.secureEnclaveNotAvailable
        }

        do {
            let privateKey = try SecureEnclave.P256.Signing.PrivateKey()
            let publicKeyData = privateKey.publicKey.rawRepresentation
            let privateKeyData = privateKey.dataRepresentation

            let item = PrismKeychainItem(
                id: "se_key_\(tag)",
                service: "PrismSecureEnclave",
                accessControl: .biometricCurrentSet
            )
            try keychain.save(data: privateKeyData, for: item)

            return publicKeyData
        } catch let error as PrismSecurityError {
            throw error
        } catch {
            throw PrismSecurityError.secureEnclaveKeyGenerationFailed
        }
    }

    public func sign(data: Data, withKeyTagged tag: String) throws -> Data {
        guard SecureEnclave.isAvailable else {
            throw PrismSecurityError.secureEnclaveNotAvailable
        }

        do {
            let item = PrismKeychainItem(
                id: "se_key_\(tag)",
                service: "PrismSecureEnclave",
                accessControl: .biometricCurrentSet
            )
            let keyData = try keychain.load(for: item)
            let privateKey = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: keyData)
            let signature = try privateKey.signature(for: data)
            return signature.rawRepresentation
        } catch let error as PrismSecurityError {
            throw error
        } catch {
            throw PrismSecurityError.secureEnclaveSigningFailed
        }
    }

    public func verify(signature: Data, for data: Data, publicKey: Data) throws -> Bool {
        let key = try P256.Signing.PublicKey(rawRepresentation: publicKey)
        let ecdsaSignature = try P256.Signing.ECDSASignature(rawRepresentation: signature)
        return key.isValidSignature(ecdsaSignature, for: data)
    }

    public func deleteKeyPair(tag: String) throws {
        let item = PrismKeychainItem(
            id: "se_key_\(tag)",
            service: "PrismSecureEnclave",
            accessControl: .biometricCurrentSet
        )
        try keychain.delete(for: item)
    }
}
