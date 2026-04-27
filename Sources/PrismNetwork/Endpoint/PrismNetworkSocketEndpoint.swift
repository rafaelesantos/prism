//
//  PrismNetworkSocketEndpoint.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import Network
import PrismFoundation

/// A protocol that defines WebSocket endpoints.
public protocol PrismNetworkSocketEndpoint: PrismLogger, Sendable {
    /// The network host to connect to.
    var host: NWEndpoint.Host { get }
    /// The port number for the WebSocket connection.
    var port: NWEndpoint.Port { get throws }
    /// The network parameters (e.g., TLS configuration) for the connection.
    var parameters: NWParameters { get }
}

extension PrismNetworkSocketEndpoint {
    /// Logs the endpoint's host, port, and connection parameters.
    public func log() {
        let logger = PrismNetworkLogger()
        logger.info(.host(host.debugDescription))

        if let port = try? port {
            logger.info(.port(port.rawValue))
        }

        logger.info(.parameters(parameters.debugDescription))
    }
}
