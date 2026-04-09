//
//  RyzeNetworkSocketEndpoint.swift
//  Ryze
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import Network
import RyzeFoundation

public protocol RyzeNetworkSocketEndpoint: RyzeLogger, Sendable {
    var host: NWEndpoint.Host { get }
    var port: NWEndpoint.Port { get throws }
    var parameters: NWParameters { get }
}

extension RyzeNetworkSocketEndpoint {
    public func log() {
        let logger = RyzeNetworkLogger()
        logger.info(.host(host.debugDescription))

        if let port = try? port {
            logger.info(.port(port.rawValue))
        }

        logger.info(.parameters(parameters.debugDescription))
    }
}
