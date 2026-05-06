import CryptoKit
import Foundation

public struct PrismEncryptor: Sendable {
    public enum Algorithm: String, Sendable, Hashable, CaseIterable {
        case aesGCM
        case chaChaPoly
    }

    private let algorithm: Algorithm

    public init(algorithm: Algorithm = .aesGCM) {
        self.algorithm = algorithm
    }

    public func generateKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    public func exportKey(_ key: SymmetricKey) -> Data {
        key.withUnsafeBytes { Data($0) }
    }

    public func importKey(_ data: Data) -> SymmetricKey {
        SymmetricKey(data: data)
    }

    public func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        switch algorithm {
        case .aesGCM:
            let sealedBox = try AES.GCM.seal(data, using: key)
            guard let combined = sealedBox.combined else {
                throw PrismSecurityError.encryptionFailed("Failed to produce combined sealed box")
            }
            return combined
        case .chaChaPoly:
            let sealedBox = try ChaChaPoly.seal(data, using: key)
            return sealedBox.combined
        }
    }

    public func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
        do {
            switch algorithm {
            case .aesGCM:
                let sealedBox = try AES.GCM.SealedBox(combined: data)
                return try AES.GCM.open(sealedBox, using: key)
            case .chaChaPoly:
                let sealedBox = try ChaChaPoly.SealedBox(combined: data)
                return try ChaChaPoly.open(sealedBox, using: key)
            }
        } catch {
            throw PrismSecurityError.decryptionFailed(error.localizedDescription)
        }
    }

    public func encrypt<T: Codable & Sendable>(_ value: T, using key: SymmetricKey) throws -> Data {
        let data = try JSONEncoder().encode(value)
        return try encrypt(data, using: key)
    }

    public func decrypt<T: Codable & Sendable>(_ type: T.Type, from data: Data, using key: SymmetricKey) throws -> T {
        let decrypted = try decrypt(data, using: key)
        do {
            return try JSONDecoder().decode(type, from: decrypted)
        } catch {
            throw PrismSecurityError.deserializationFailed
        }
    }
}
