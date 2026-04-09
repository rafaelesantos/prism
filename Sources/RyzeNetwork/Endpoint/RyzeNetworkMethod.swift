//
//  RyzeNetworkMethod.swift
//  Ryze
//
//  Created by Rafael Escaleira on 28/03/25.
//

public enum RyzeNetworkMethod: String, Sendable, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
