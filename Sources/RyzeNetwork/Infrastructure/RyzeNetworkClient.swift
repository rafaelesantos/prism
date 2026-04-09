//
//  RyzeNetworkClient.swift
//  Ryze
//
//  Created by Rafael Escaleira on 29/03/25.
//

import Foundation
import RyzeFoundation

public protocol RyzeNetworkClient: Sendable {
    func request<Request: RyzeNetworkRequest>(
        on request: Request,
        with formatter: DateFormatter?
    ) async throws -> Request.Response

    func redirect<Request: RyzeNetworkRequest>(
        from request: Request
    ) async throws -> URL
}

extension RyzeNetworkClient {
    public func request<Request: RyzeNetworkRequest>(
        on request: Request
    ) async throws -> Request.Response {
        try await self.request(
            on: request,
            with: nil
        )
    }
}
