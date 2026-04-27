//
//  PrismNetworkClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/03/25.
//

import Foundation
import PrismFoundation

/// A protocol for HTTP network clients.
public protocol PrismNetworkClient: Sendable {
    /// Performs a network request and decodes the response.
    ///
    /// - Parameters:
    ///   - request: The type-safe request to execute.
    ///   - formatter: An optional date formatter for response decoding.
    /// - Returns: The decoded response.
    /// - Throws: ``PrismNetworkError`` on failure.
    func request<Request: PrismNetworkRequest>(
        on request: Request,
        with formatter: DateFormatter?
    ) async throws -> Request.Response

    /// Follows a redirect and returns the destination URL.
    ///
    /// - Parameter request: The request whose endpoint may trigger a redirect.
    /// - Returns: The redirect destination URL.
    /// - Throws: ``PrismNetworkError`` if no redirect is found.
    func redirect<Request: PrismNetworkRequest>(
        from request: Request
    ) async throws -> URL
}

extension PrismNetworkClient {
    /// Performs a network request using the default date formatter (`nil`).
    ///
    /// - Parameter request: The type-safe request to execute.
    /// - Returns: The decoded response.
    /// - Throws: ``PrismNetworkError`` on failure.
    public func request<Request: PrismNetworkRequest>(
        on request: Request
    ) async throws -> Request.Response {
        try await self.request(
            on: request,
            with: nil
        )
    }
}
