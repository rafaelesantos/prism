import Foundation

/// Wraps PrismHTTPResponse with chainable assertion helpers for testing.
public struct PrismAssertResponse: Sendable {
    public let response: PrismHTTPResponse

    public init(_ response: PrismHTTPResponse) {
        self.response = response
    }

    public var bodyString: String? {
        switch response.body {
        case .data(let data): return String(data: data, encoding: .utf8)
        case .text(let str): return str
        case .empty: return nil
        }
    }

    @discardableResult
    public func assertStatus(_ expected: PrismHTTPStatus) -> PrismAssertResponse {
        assert(response.status == expected, "Expected status \(expected.code) but got \(response.status.code)")
        return self
    }

    @discardableResult
    public func assertHeader(_ name: String, _ value: String) -> PrismAssertResponse {
        let actual = response.headers.value(for: name)
        assert(actual == value, "Expected header '\(name)' to be '\(value)' but got '\(actual ?? "nil")'")
        return self
    }

    @discardableResult
    public func assertBodyContains(_ substring: String) -> PrismAssertResponse {
        let body = bodyString ?? ""
        assert(body.contains(substring), "Expected body to contain '\(substring)' but body was '\(body)'")
        return self
    }

    public func assertJSON<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        let data: Data
        switch response.body {
        case .data(let d): data = d
        case .text(let s): data = Data(s.utf8)
        case .empty: throw PrismTestError.emptyBody
        }
        return try decoder.decode(type, from: data)
    }
}

/// Fluent API for building test requests.
public struct PrismRequestBuilder: Sendable {
    private var method: PrismHTTPMethod
    private var path: String
    private var headers: PrismHTTPHeaders
    private var requestBody: Data?

    private init(method: PrismHTTPMethod, path: String) {
        self.method = method
        self.path = path
        self.headers = PrismHTTPHeaders()
        self.requestBody = nil
    }

    public static func get(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .GET, path: path)
    }

    public static func post(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .POST, path: path)
    }

    public static func put(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .PUT, path: path)
    }

    public static func patch(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .PATCH, path: path)
    }

    public static func delete(_ path: String) -> PrismRequestBuilder {
        PrismRequestBuilder(method: .DELETE, path: path)
    }

    public func header(_ name: String, _ value: String) -> PrismRequestBuilder {
        var copy = self
        copy.headers.set(name: name, value: value)
        return copy
    }

    public func body(_ data: Data) -> PrismRequestBuilder {
        var copy = self
        copy.requestBody = data
        return copy
    }

    public func jsonBody<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) -> PrismRequestBuilder {
        var copy = self
        if let data = try? encoder.encode(value) {
            copy.requestBody = data
            copy.headers.set(name: "Content-Type", value: "application/json")
            copy.headers.set(name: "Content-Length", value: "\(data.count)")
        }
        return copy
    }

    public func build() -> PrismHTTPRequest {
        PrismHTTPRequest(
            method: method,
            uri: path,
            headers: headers,
            body: requestBody
        )
    }
}

/// Errors from test utilities.
public enum PrismTestError: Error, Sendable {
    case emptyBody
    case serverNotStarted
}
