import Foundation

public struct PrismTestClient: Sendable {
    private let router: PrismRouter

    public init(router: PrismRouter) {
        self.router = router
    }

    public func send(_ request: PrismHTTPRequest) async throws -> PrismHTTPResponse {
        try await router.handle(request)
    }

    public func get(_ path: String, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws -> PrismHTTPResponse {
        let request = PrismHTTPRequest(method: .GET, uri: path, headers: headers)
        return try await send(request)
    }

    public func post(_ path: String, body: Data? = nil, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws
        -> PrismHTTPResponse
    {
        let request = PrismHTTPRequest(method: .POST, uri: path, headers: headers, body: body)
        return try await send(request)
    }

    public func postJSON<T: Encodable>(_ path: String, body: T, encoder: JSONEncoder = JSONEncoder()) async throws
        -> PrismHTTPResponse
    {
        let data = try encoder.encode(body)
        var headers = PrismHTTPHeaders()
        headers.set(name: PrismHTTPHeaders.contentType, value: "application/json")
        headers.set(name: PrismHTTPHeaders.contentLength, value: "\(data.count)")
        return try await post(path, body: data, headers: headers)
    }

    public func put(_ path: String, body: Data? = nil, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws
        -> PrismHTTPResponse
    {
        let request = PrismHTTPRequest(method: .PUT, uri: path, headers: headers, body: body)
        return try await send(request)
    }

    public func patch(_ path: String, body: Data? = nil, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws
        -> PrismHTTPResponse
    {
        let request = PrismHTTPRequest(method: .PATCH, uri: path, headers: headers, body: body)
        return try await send(request)
    }

    public func delete(_ path: String, headers: PrismHTTPHeaders = PrismHTTPHeaders()) async throws -> PrismHTTPResponse
    {
        let request = PrismHTTPRequest(method: .DELETE, uri: path, headers: headers)
        return try await send(request)
    }
}

public final class PrismTestClientBuilder: Sendable {
    private let _routes: LockedTestBox<[PrismRoute]>
    private let _middlewares: LockedTestBox<[any PrismMiddleware]>

    public init() {
        self._routes = LockedTestBox([])
        self._middlewares = LockedTestBox([])
    }

    public func route(_ method: PrismHTTPMethod, _ pattern: String, handler: @escaping PrismRouteHandler)
        -> PrismTestClientBuilder
    {
        _routes.mutate { $0.append(PrismRoute(method: method, pattern: pattern, handler: handler)) }
        return self
    }

    public func get(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismTestClientBuilder {
        route(.GET, pattern, handler: handler)
    }

    public func post(_ pattern: String, handler: @escaping PrismRouteHandler) -> PrismTestClientBuilder {
        route(.POST, pattern, handler: handler)
    }

    public func use(_ middleware: any PrismMiddleware) -> PrismTestClientBuilder {
        _middlewares.mutate { $0.append(middleware) }
        return self
    }

    public func build() -> PrismTestClient {
        let router = PrismRouter(routes: _routes.value, middlewares: _middlewares.value, groups: [])
        return PrismTestClient(router: router)
    }
}

private final class LockedTestBox<T>: @unchecked Sendable {
    private var _value: T
    private let lock = NSLock()

    init(_ value: T) {
        self._value = value
    }

    var value: T {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func mutate(_ transform: (inout T) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        transform(&_value)
    }
}
