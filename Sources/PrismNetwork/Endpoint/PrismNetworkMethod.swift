//
//  PrismNetworkMethod.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/03/25.
//

/// Métodos HTTP suportados.
public enum PrismNetworkMethod: String, Sendable, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
