import Foundation

public typealias PrismRequestHook = @Sendable (PrismHTTPRequest) async throws -> PrismHTTPRequest

public typealias PrismResponseHook = @Sendable (PrismHTTPRequest, PrismHTTPResponse) async throws -> PrismHTTPResponse

public typealias PrismErrorHook = @Sendable (Error, PrismHTTPRequest) async -> PrismHTTPResponse?

public actor PrismHookRegistry {
    private var requestHooks: [PrismRequestHook] = []
    private var responseHooks: [PrismResponseHook] = []
    private var errorHooks: [PrismErrorHook] = []

    public init() {}

    public func onRequest(_ hook: @escaping PrismRequestHook) {
        requestHooks.append(hook)
    }

    public func onResponse(_ hook: @escaping PrismResponseHook) {
        responseHooks.append(hook)
    }

    public func onError(_ hook: @escaping PrismErrorHook) {
        errorHooks.append(hook)
    }

    public func runRequestHooks(_ request: PrismHTTPRequest) async throws -> PrismHTTPRequest {
        var req = request
        for hook in requestHooks {
            req = try await hook(req)
        }
        return req
    }

    public func runResponseHooks(_ request: PrismHTTPRequest, response: PrismHTTPResponse) async throws
        -> PrismHTTPResponse
    {
        var resp = response
        for hook in responseHooks {
            resp = try await hook(request, resp)
        }
        return resp
    }

    public func runErrorHooks(_ error: Error, request: PrismHTTPRequest) async -> PrismHTTPResponse? {
        for hook in errorHooks {
            if let response = await hook(error, request) {
                return response
            }
        }
        return nil
    }

    public var requestHookCount: Int { requestHooks.count }

    public var responseHookCount: Int { responseHooks.count }

    public var errorHookCount: Int { errorHooks.count }
}

public struct PrismHooksMiddleware: PrismMiddleware, Sendable {
    private let registry: PrismHookRegistry

    public init(registry: PrismHookRegistry) {
        self.registry = registry
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        do {
            let modifiedRequest = try await registry.runRequestHooks(request)
            let response = try await next(modifiedRequest)
            let modifiedResponse = try await registry.runResponseHooks(modifiedRequest, response: response)
            return modifiedResponse
        } catch {
            if let errorResponse = await registry.runErrorHooks(error, request: request) {
                return errorResponse
            }
            throw error
        }
    }
}
