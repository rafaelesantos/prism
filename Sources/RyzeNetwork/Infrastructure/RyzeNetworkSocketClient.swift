//
//  RyzeNetworkSocketClient.swift
//  Ryze
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import RyzeFoundation

public protocol RyzeNetworkSocketClient: Sendable {
    func send(command: RyzeNetworkSocketCommand) async throws
    func connect(
        to endpoint: any RyzeNetworkSocketEndpoint
    ) async throws -> AsyncStream<Data>
}

extension RyzeNetworkSocketClient {
    public func connect<Request: RyzeNetworkSocketRequest>(
        with request: Request
    ) async throws -> AsyncStream<Data> {
        guard let endpoint = request.endpoint else {
            throw RyzeNetworkError.invalidURL
        }

        return try await connect(to: endpoint)
    }
}
