//
//  PrismNetworkScheme.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

/// Schemes de URL suportados (HTTP, HTTPS, WSS).
public enum PrismNetworkScheme: String, Sendable, CaseIterable {
    case http = "http"
    case https = "https"
    case ws = "ws"
    case wss = "wss"
}
