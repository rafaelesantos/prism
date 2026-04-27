//
//  PrismNetworkSocketCommand.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/06/25.
//

/// A protocol for commands sent over a WebSocket connection.
public protocol PrismNetworkSocketCommand: Sendable {
    /// The text message to send over the WebSocket connection.
    var message: String { get }
}
