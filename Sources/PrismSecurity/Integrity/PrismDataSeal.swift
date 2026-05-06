import CryptoKit
import Foundation

public struct PrismDataSeal: Sendable {
    private let key: SymmetricKey

    public init(key: SymmetricKey) {
        self.key = key
    }

    public init(keychain: PrismKeychain = PrismKeychain(), keyID: String = "PrismDataSeal") throws {
        let item = PrismKeychainItem(id: keyID, service: "PrismDataSeal")
        if keychain.exists(for: item) {
            let keyData = try keychain.load(for: item)
            self.key = SymmetricKey(data: keyData)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            try keychain.save(data: keyData, for: item)
            self.key = newKey
        }
    }

    public struct SealedData: Codable, Sendable, Equatable {
        public let payload: Data
        public let mac: Data
        public let sealedAt: Date
    }

    public func seal<T: Codable & Sendable>(_ value: T) throws -> SealedData {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw PrismSecurityError.serializationFailed
        }
        return sealData(data)
    }

    public func sealData(_ data: Data) -> SealedData {
        let mac = Data(HMAC<SHA256>.authenticationCode(for: data, using: key))
        return SealedData(payload: data, mac: mac, sealedAt: .now)
    }

    public func unseal<T: Codable & Sendable>(_ type: T.Type, from sealed: SealedData) throws -> T {
        guard verify(sealed) else {
            throw PrismSecurityError.decryptionFailed("Data integrity check failed — HMAC mismatch")
        }
        do {
            return try JSONDecoder().decode(type, from: sealed.payload)
        } catch {
            throw PrismSecurityError.deserializationFailed
        }
    }

    public func verify(_ sealed: SealedData) -> Bool {
        HMAC<SHA256>.isValidAuthenticationCode(sealed.mac, authenticating: sealed.payload, using: key)
    }

    public func verify(data: Data, mac: Data) -> Bool {
        HMAC<SHA256>.isValidAuthenticationCode(mac, authenticating: data, using: key)
    }
}
