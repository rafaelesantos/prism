import Foundation

public struct PrismHTTPRequest: Sendable {
    public let method: PrismHTTPMethod
    public let uri: String
    public let path: String
    public let version: String
    public var headers: PrismHTTPHeaders
    public var body: Data?
    public var parameters: [String: String]
    public let queryParameters: [String: String]
    public var userInfo: [String: String]

    public init(
        method: PrismHTTPMethod,
        uri: String,
        version: String = "HTTP/1.1",
        headers: PrismHTTPHeaders = PrismHTTPHeaders(),
        body: Data? = nil,
        parameters: [String: String] = [:],
        userInfo: [String: String] = [:]
    ) {
        self.method = method
        self.uri = uri
        self.version = version
        self.headers = headers
        self.body = body
        self.parameters = parameters
        self.userInfo = userInfo

        let parts = uri.split(separator: "?", maxSplits: 1)
        self.path = String(parts.first ?? "/")

        var qp: [String: String] = [:]
        if parts.count == 2 {
            let queryString = String(parts[1])
            for pair in queryString.split(separator: "&") {
                let kv = pair.split(separator: "=", maxSplits: 1)
                if kv.count == 2 {
                    let key = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                    let value = String(kv[1]).removingPercentEncoding ?? String(kv[1])
                    qp[key] = value
                } else if kv.count == 1 {
                    let key = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                    qp[key] = ""
                }
            }
        }
        self.queryParameters = qp
    }

    public func parameter(_ name: String) -> String? {
        parameters[name]
    }

    public func query(_ name: String) -> String? {
        queryParameters[name]
    }

    public var contentType: String? {
        headers.value(for: PrismHTTPHeaders.contentType)
    }

    public var contentLength: Int? {
        headers.value(for: PrismHTTPHeaders.contentLength).flatMap(Int.init)
    }
}
