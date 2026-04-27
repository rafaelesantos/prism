//
//  PrismNetworkMethod.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

/// Supported HTTP methods.
public enum PrismNetworkMethod: String, Sendable, CaseIterable {
    /// The HTTP GET method, used to retrieve resources.
    case get = "GET"
    /// The HTTP POST method, used to create resources.
    case post = "POST"
    /// The HTTP PUT method, used to replace resources.
    case put = "PUT"
    /// The HTTP PATCH method, used to partially update resources.
    case patch = "PATCH"
    /// The HTTP DELETE method, used to remove resources.
    case delete = "DELETE"
}
