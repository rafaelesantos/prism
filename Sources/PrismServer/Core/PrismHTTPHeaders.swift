import Foundation

/// Case-insensitive HTTP header storage preserving original casing.
public struct PrismHTTPHeaders: Sendable, Equatable {
    public static func == (lhs: PrismHTTPHeaders, rhs: PrismHTTPHeaders) -> Bool {
        guard lhs.storage.count == rhs.storage.count else { return false }
        for (l, r) in zip(lhs.storage, rhs.storage) {
            guard l.name == r.name && l.value == r.value else { return false }
        }
        return true
    }

    private var storage: [(name: String, value: String)]

    public init(_ headers: [(String, String)] = []) {
        self.storage = headers.map { (name: $0.0, value: $0.1) }
    }

    /// Returns the first value for the given header name (case-insensitive).
    public func value(for name: String) -> String? {
        let lowered = name.lowercased()
        return storage.first { $0.name.lowercased() == lowered }?.value
    }

    /// Returns all values for the given header name (case-insensitive).
    public func values(for name: String) -> [String] {
        let lowered = name.lowercased()
        return storage.filter { $0.name.lowercased() == lowered }.map(\.value)
    }

    /// Adds a header without removing existing values for that name.
    public mutating func add(name: String, value: String) {
        storage.append((name: name, value: value))
    }

    /// Sets a header, replacing any existing values for that name.
    public mutating func set(name: String, value: String) {
        remove(name: name)
        storage.append((name: name, value: value))
    }

    /// Removes all headers with the given name (case-insensitive).
    public mutating func remove(name: String) {
        let lowered = name.lowercased()
        storage.removeAll { $0.name.lowercased() == lowered }
    }

    /// All header entries as name-value pairs.
    public var entries: [(name: String, value: String)] { storage }

    /// The total number of header entries.
    public var count: Int { storage.count }

    // MARK: - Common Header Names

    public static let contentType = "Content-Type"
    public static let contentLength = "Content-Length"
    public static let host = "Host"
    public static let connection = "Connection"
    public static let authorization = "Authorization"
    public static let accept = "Accept"
    public static let userAgent = "User-Agent"
    public static let cacheControl = "Cache-Control"
    public static let eTag = "ETag"
    public static let ifNoneMatch = "If-None-Match"
    public static let transferEncoding = "Transfer-Encoding"
    public static let upgrade = "Upgrade"
    public static let location = "Location"
    public static let server = "Server"
    public static let date = "Date"
    public static let setCookie = "Set-Cookie"
    public static let cookie = "Cookie"
}
