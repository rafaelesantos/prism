import CryptoKit
import Foundation

public struct PrismHasher: Sendable {
    public enum Algorithm: String, Sendable, Hashable, CaseIterable {
        case sha256
        case sha384
        case sha512
    }

    private let algorithm: Algorithm

    public init(algorithm: Algorithm = .sha256) {
        self.algorithm = algorithm
    }

    public func hash(_ data: Data) -> Data {
        switch algorithm {
        case .sha256: Data(SHA256.hash(data: data))
        case .sha384: Data(SHA384.hash(data: data))
        case .sha512: Data(SHA512.hash(data: data))
        }
    }

    public func hash(_ string: String) -> Data {
        hash(Data(string.utf8))
    }

    public func hashHex(_ data: Data) -> String {
        hash(data).map { String(format: "%02x", $0) }.joined()
    }

    public func hashHex(_ string: String) -> String {
        hashHex(Data(string.utf8))
    }

    public func hmac(_ data: Data, key: SymmetricKey) -> Data {
        switch algorithm {
        case .sha256:
            Data(HMAC<SHA256>.authenticationCode(for: data, using: key))
        case .sha384:
            Data(HMAC<SHA384>.authenticationCode(for: data, using: key))
        case .sha512:
            Data(HMAC<SHA512>.authenticationCode(for: data, using: key))
        }
    }

    public func verifyHMAC(_ mac: Data, for data: Data, key: SymmetricKey) -> Bool {
        switch algorithm {
        case .sha256:
            HMAC<SHA256>.isValidAuthenticationCode(mac, authenticating: data, using: key)
        case .sha384:
            HMAC<SHA384>.isValidAuthenticationCode(mac, authenticating: data, using: key)
        case .sha512:
            HMAC<SHA512>.isValidAuthenticationCode(mac, authenticating: data, using: key)
        }
    }
}
