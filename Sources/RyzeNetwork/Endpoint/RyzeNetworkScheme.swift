//
//  RyzeNetworkScheme.swift
//  Ryze
//
//  Created by Rafael Escaleira on 28/03/25.
//

public enum RyzeNetworkScheme: String, Sendable, CaseIterable {
    case http = "http"
    case https = "https"
    case ws = "ws"
    case wss = "wss"
}
