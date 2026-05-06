import CryptoKit
import Foundation

public final class PrismSecureChannel: Sendable {
    private let keyAgreement: PrismKeyAgreement
    private let encryptor: PrismEncryptor
    private let lock = NSLock()
    nonisolated(unsafe) private var _sharedKey: SymmetricKey?

    public var publicKeyData: Data {
        keyAgreement.publicKeyData
    }

    public var isEstablished: Bool {
        lock.withLock { _sharedKey != nil }
    }

    public init(algorithm: PrismEncryptor.Algorithm = .aesGCM) {
        self.keyAgreement = PrismKeyAgreement()
        self.encryptor = PrismEncryptor(algorithm: algorithm)
    }

    public func establish(with remotePublicKeyData: Data) throws {
        let sharedKey = try keyAgreement.deriveSharedSecret(with: remotePublicKeyData)
        lock.withLock { _sharedKey = sharedKey }
    }

    public func encrypt(_ data: Data) throws -> Data {
        guard let key = lock.withLock({ _sharedKey }) else {
            throw PrismSecurityError.invalidKey
        }
        return try encryptor.encrypt(data, using: key)
    }

    public func decrypt(_ data: Data) throws -> Data {
        guard let key = lock.withLock({ _sharedKey }) else {
            throw PrismSecurityError.invalidKey
        }
        return try encryptor.decrypt(data, using: key)
    }

    public func encrypt<T: Codable & Sendable>(_ value: T) throws -> Data {
        let data = try JSONEncoder().encode(value)
        return try encrypt(data)
    }

    public func decrypt<T: Codable & Sendable>(_ type: T.Type, from data: Data) throws -> T {
        let decrypted = try decrypt(data)
        return try JSONDecoder().decode(type, from: decrypted)
    }

    public func close() {
        lock.withLock { _sharedKey = nil }
    }
}
