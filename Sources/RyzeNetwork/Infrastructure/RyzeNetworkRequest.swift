//
//  RyzeNetworkRequest.swift
//  Ryze
//
//  Created by Rafael Escaleira on 29/03/25.
//

import Foundation
import RyzeFoundation

public protocol RyzeNetworkRequest: Sendable {
    associatedtype Endpoint: RyzeNetworkEndpoint
    associatedtype Response: RyzeEntity & Sendable

    var endpoint: Endpoint { get }

    func decode(
        data: Data,
        with formatter: DateFormatter?
    ) throws -> Response
}

extension RyzeNetworkRequest {
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
