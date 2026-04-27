//
//  PrismNetworkScheme.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

/// Supported URL schemes (HTTP, HTTPS, WS, WSS).
public enum PrismNetworkScheme: String, Sendable, CaseIterable {
    /// Unencrypted HTTP scheme.
    case http = "http"
    /// Encrypted HTTPS scheme.
    case https = "https"
    /// Unencrypted WebSocket scheme.
    case ws = "ws"
    /// Encrypted WebSocket scheme.
    case wss = "wss"
}
