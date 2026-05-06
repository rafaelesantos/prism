import CryptoKit
import Foundation

public struct PrismCertificatePin: Sendable, Hashable, Identifiable {
    public let id: String
    public let host: String
    public let publicKeyHash: String
    public let backupHashes: [String]
    public let expiresAt: Date?

    public init(
        host: String,
        publicKeyHash: String,
        backupHashes: [String] = [],
        expiresAt: Date? = nil
    ) {
        self.id = "\(host)_\(publicKeyHash.prefix(8))"
        self.host = host
        self.publicKeyHash = publicKeyHash
        self.backupHashes = backupHashes
        self.expiresAt = expiresAt
    }

    public var allHashes: Set<String> {
        Set([publicKeyHash] + backupHashes)
    }

    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date.now > expiresAt
    }

    public static func hash(publicKeyDER: Data) -> String {
        let digest = SHA256.hash(data: publicKeyDER)
        return Data(digest).base64EncodedString()
    }
}
