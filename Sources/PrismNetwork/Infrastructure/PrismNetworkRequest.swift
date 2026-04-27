//
//  PrismNetworkRequest.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/03/25.
//

import Foundation
import PrismFoundation

/// A protocol for network requests with type-safe decoding.
public protocol PrismNetworkRequest: Sendable {
    /// The endpoint type associated with this request.
    associatedtype Endpoint: PrismNetworkEndpoint
    /// The decodable response type returned by this request.
    associatedtype Response: PrismEntity & Sendable

    /// The endpoint that defines the URL, method, headers, and body for this request.
    var endpoint: Endpoint { get }

    /// Decodes raw response data into the associated `Response` type.
    ///
    /// - Parameters:
    ///   - data: The raw data received from the network.
    ///   - formatter: An optional date formatter for custom date decoding.
    /// - Returns: The decoded response object.
    /// - Throws: A decoding error if the data cannot be parsed.
    func decode(
        data: Data,
        with formatter: DateFormatter?
    ) throws -> Response
}

extension PrismNetworkRequest {
    /// Default decoding implementation that uses `PrismEntity` deserialization.
    ///
    /// - Parameters:
    ///   - data: The raw data received from the network.
    ///   - formatter: An optional date formatter for custom date decoding.
    /// - Returns: The decoded response object.
    /// - Throws: A decoding error if the data cannot be parsed.
    public func decode(
        data: Data,
        with formatter: DateFormatter?
    ) throws -> Response {
        let decoded = try data.entity(
            for: Response.self,
            with: formatter
        )
        decoded.log()
        return decoded
    }
}
