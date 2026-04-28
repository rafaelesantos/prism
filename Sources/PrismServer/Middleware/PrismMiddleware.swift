import Foundation

/// Protocol for HTTP middleware that can intercept, modify, or short-circuit requests.
public protocol PrismMiddleware: Sendable {
    /// Processes a request, optionally calling next to continue the chain.
    func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
}
