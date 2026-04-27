//
//  PrismNetworkSocketCommand.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/06/25.
//

/// Protocolo para comandos enviados via WebSocket.
public protocol PrismNetworkSocketCommand: Sendable {
    var message: String { get }
}
