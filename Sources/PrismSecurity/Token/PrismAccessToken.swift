import Foundation

public struct PrismAccessToken: Sendable, Equatable {
    public let rawToken: String
    public let header: [String: String]
    public let payloadData: Data
    public let expiresAt: Date?
    public let issuedAt: Date?
    public let subject: String?
    public let issuer: String?

    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date.now >= expiresAt
    }

    public func expiresWithin(_ interval: TimeInterval) -> Bool {
        guard let expiresAt else { return false }
        return Date.now.addingTimeInterval(interval) >= expiresAt
    }

    public var timeUntilExpiry: TimeInterval? {
        guard let expiresAt else { return nil }
        return expiresAt.timeIntervalSinceNow
    }

    public static func decode(_ jwt: String) throws -> PrismAccessToken {
        let parts = jwt.components(separatedBy: ".")
        guard parts.count == 3 else {
            throw PrismSecurityError.invalidData
        }

        let headerJSON = try decodeBase64URL(parts[0])
        let payloadJSON = try decodeBase64URL(parts[1])

        let headerDict = (try? JSONSerialization.jsonObject(with: headerJSON)) as? [String: String] ?? [:]
        let payloadDict = (try? JSONSerialization.jsonObject(with: payloadJSON)) as? [String: Any] ?? [:]

        let exp: Date? = (payloadDict["exp"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
            ?? (payloadDict["exp"] as? Int).map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let iat: Date? = (payloadDict["iat"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
            ?? (payloadDict["iat"] as? Int).map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let sub = payloadDict["sub"] as? String
        let iss = payloadDict["iss"] as? String

        return PrismAccessToken(
            rawToken: jwt,
            header: headerDict,
            payloadData: payloadJSON,
            expiresAt: exp,
            issuedAt: iat,
            subject: sub,
            issuer: iss
        )
    }

    public func claim<T>(_ key: String) -> T? {
        guard let dict = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] else {
            return nil
        }
        return dict[key] as? T
    }

    public var claims: [String: Any] {
        (try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any]) ?? [:]
    }

    private static func decodeBase64URL(_ string: String) throws -> Data {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }
        guard let data = Data(base64Encoded: base64) else {
            throw PrismSecurityError.invalidData
        }
        return data
    }

    public static func == (lhs: PrismAccessToken, rhs: PrismAccessToken) -> Bool {
        lhs.rawToken == rhs.rawToken
    }
}
