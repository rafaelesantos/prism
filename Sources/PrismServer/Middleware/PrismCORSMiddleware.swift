import Foundation

public struct PrismCORSMiddleware: PrismMiddleware {
    public let allowedOrigins: [String]
    public let allowedMethods: [PrismHTTPMethod]
    public let allowedHeaders: [String]
    public let exposedHeaders: [String]
    public let allowCredentials: Bool
    public let maxAge: Int

    public init(
        allowedOrigins: [String] = ["*"],
        allowedMethods: [PrismHTTPMethod] = [.GET, .POST, .PUT, .PATCH, .DELETE, .OPTIONS],
        allowedHeaders: [String] = ["Content-Type", "Authorization", "Accept"],
        exposedHeaders: [String] = [],
        allowCredentials: Bool = false,
        maxAge: Int = 86400
    ) {
        self.allowedOrigins = allowedOrigins
        self.allowedMethods = allowedMethods
        self.allowedHeaders = allowedHeaders
        self.exposedHeaders = exposedHeaders
        self.allowCredentials = allowCredentials
        self.maxAge = maxAge
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        if request.method == .OPTIONS {
            var response = PrismHTTPResponse(status: .noContent)
            addCORSHeaders(to: &response, request: request)
            return response
        }

        var response = try await next(request)
        addCORSHeaders(to: &response, request: request)
        return response
    }

    private func addCORSHeaders(to response: inout PrismHTTPResponse, request: PrismHTTPRequest) {
        let origin = request.headers.value(for: "Origin") ?? "*"
        let allowedOrigin =
            allowedOrigins.contains("*")
            ? "*" : (allowedOrigins.contains(origin) ? origin : allowedOrigins.first ?? "*")

        response.headers.set(name: "Access-Control-Allow-Origin", value: allowedOrigin)
        response.headers.set(
            name: "Access-Control-Allow-Methods", value: allowedMethods.map(\.rawValue).joined(separator: ", "))
        response.headers.set(name: "Access-Control-Allow-Headers", value: allowedHeaders.joined(separator: ", "))
        response.headers.set(name: "Access-Control-Max-Age", value: "\(maxAge)")

        if !exposedHeaders.isEmpty {
            response.headers.set(name: "Access-Control-Expose-Headers", value: exposedHeaders.joined(separator: ", "))
        }

        if allowCredentials {
            response.headers.set(name: "Access-Control-Allow-Credentials", value: "true")
        }
    }
}
