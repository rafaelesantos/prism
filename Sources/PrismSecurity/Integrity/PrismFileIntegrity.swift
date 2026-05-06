import CryptoKit
import Foundation

public struct PrismFileIntegrity: Sendable {
    private let keychain: PrismKeychain

    public init(keychain: PrismKeychain = PrismKeychain(service: "PrismFileIntegrity")) {
        self.keychain = keychain
    }

    public struct VerificationResult: Sendable, Equatable {
        public let path: String
        public let isValid: Bool
        public let expectedHash: String
        public let actualHash: String
        public let verifiedAt: Date

        public init(path: String, isValid: Bool, expectedHash: String, actualHash: String, verifiedAt: Date = .now) {
            self.path = path
            self.isValid = isValid
            self.expectedHash = expectedHash
            self.actualHash = actualHash
            self.verifiedAt = verifiedAt
        }
    }

    public func registerFile(at url: URL) throws {
        let hash = try computeHash(at: url)
        let item = PrismKeychainItem(id: hashKey(for: url), service: "PrismFileIntegrity")
        try keychain.save(string: hash, for: item)
    }

    public func verify(at url: URL) throws -> VerificationResult {
        let item = PrismKeychainItem(id: hashKey(for: url), service: "PrismFileIntegrity")
        let expectedHash = try keychain.loadString(for: item)
        let actualHash = try computeHash(at: url)

        return VerificationResult(
            path: url.path,
            isValid: expectedHash == actualHash,
            expectedHash: expectedHash,
            actualHash: actualHash
        )
    }

    public func verifyAll(at urls: [URL]) throws -> [VerificationResult] {
        try urls.map { try verify(at: $0) }
    }

    public func updateHash(at url: URL) throws {
        try registerFile(at: url)
    }

    public func unregister(at url: URL) throws {
        let item = PrismKeychainItem(id: hashKey(for: url), service: "PrismFileIntegrity")
        try keychain.delete(for: item)
    }

    public func computeHash(at url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func hashKey(for url: URL) -> String {
        let pathHash = SHA256.hash(data: Data(url.path.utf8))
        return "file_\(pathHash.prefix(8).map { String(format: "%02x", $0) }.joined())"
    }
}
