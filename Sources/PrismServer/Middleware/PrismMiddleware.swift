import Foundation

public protocol PrismMiddleware: Sendable {
    func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
}
