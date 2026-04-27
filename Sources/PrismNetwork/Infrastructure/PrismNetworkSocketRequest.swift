//
//  PrismNetworkSocketRequest.swift
//  Prism
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import PrismFoundation

/// A protocol for WebSocket requests.
public protocol PrismNetworkSocketRequest: Sendable {
    /// The WebSocket endpoint to connect to, or `nil` if unavailable.
    var endpoint: (any PrismNetworkSocketEndpoint)? { get }
}
