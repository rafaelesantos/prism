//
//  PrismNetworkSocketRequest.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import PrismFoundation

/// Protocolo para requisições de WebSocket.
public protocol PrismNetworkSocketRequest: Sendable {
    var endpoint: (any PrismNetworkSocketEndpoint)? { get }
}
