//
//  PrismNetworkSocketClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import PrismFoundation

/// A protocol for WebSocket clients.
public protocol PrismNetworkSocketClient: Sendable {
    /// Sends a command over the active WebSocket connection.
    ///
    /// - Parameter command: The command whose message will be sent.
    /// - Throws: ``PrismNetworkError/noConnectivity`` if no connection is active.
    func send(command: PrismNetworkSocketCommand) async throws

    /// Opens a WebSocket connection to the given endpoint and returns a stream of received data frames.
    ///
    /// - Parameter endpoint: The WebSocket endpoint to connect to.
    /// - Returns: An `AsyncStream` that yields data frames as they arrive.
    /// - Throws: ``PrismNetworkError`` if the connection cannot be established.
    func connect(
        to endpoint: any PrismNetworkSocketEndpoint
    ) async throws -> AsyncStream<Data>
}

extension PrismNetworkSocketClient {
    /// Connects using a socket request, extracting the endpoint automatically.
    ///
    /// - Parameter request: The socket request containing the endpoint.
    /// - Returns: An `AsyncStream` that yields data frames as they arrive.
    /// - Throws: ``PrismNetworkError/invalidURL`` if the request has no endpoint.
    public func connect<Request: PrismNetworkSocketRequest>(
        with request: Request
    ) async throws -> AsyncStream<Data> {
        guard let endpoint = request.endpoint else {
            throw PrismNetworkError.invalidURL
        }

        return try await connect(to: endpoint)
    }
}
