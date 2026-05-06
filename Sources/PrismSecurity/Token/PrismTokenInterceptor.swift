import Foundation

public struct PrismTokenInterceptor: Sendable {
    private let tokenManager: PrismTokenManager
    private let headerName: String

    public init(
        tokenManager: PrismTokenManager,
        headerName: String = "Authorization"
    ) {
        self.tokenManager = tokenManager
        self.headerName = headerName
    }

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        let token = try await tokenManager.validAccessToken()
        var authorizedRequest = request
        authorizedRequest.setValue("Bearer \(token)", forHTTPHeaderField: headerName)
        return authorizedRequest
    }

    public var hasTokens: Bool {
        get async { await tokenManager.hasTokens }
    }
}
