//
//  PrismGraphQLClient.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public struct PrismGraphQLQuery: Sendable {
    public let query: String
    public let variables: [String: any Sendable]?
    public let operationName: String?

    public init(
        query: String,
        variables: [String: any Sendable]? = nil,
        operationName: String? = nil
    ) {
        self.query = query
        self.variables = variables
        self.operationName = operationName
    }
}

public struct PrismGraphQLResponse<T: Decodable & Sendable>: Sendable {
    public let data: T?
    public let errors: [PrismGraphQLError]?

    public init(data: T? = nil, errors: [PrismGraphQLError]? = nil) {
        self.data = data
        self.errors = errors
    }
}

public struct PrismGraphQLError: Decodable, Sendable, Equatable {
    public let message: String
    public let locations: [PrismGraphQLErrorLocation]?
    public let path: [String]?

    public init(
        message: String,
        locations: [PrismGraphQLErrorLocation]? = nil,
        path: [String]? = nil
    ) {
        self.message = message
        self.locations = locations
        self.path = path
    }
}

public struct PrismGraphQLErrorLocation: Decodable, Sendable, Equatable {
    public let line: Int
    public let column: Int

    public init(line: Int, column: Int) {
        self.line = line
        self.column = column
    }
}

public actor PrismGraphQLClient {
    private let endpointURL: URL
    private let session: URLSession
    private let additionalHeaders: [String: String]

    public init(
        endpointURL: URL,
        session: URLSession = .shared,
        additionalHeaders: [String: String] = [:]
    ) {
        self.endpointURL = endpointURL
        self.session = session
        self.additionalHeaders = additionalHeaders
    }

    public func execute<T: Decodable & Sendable>(
        _ query: PrismGraphQLQuery
    ) async throws -> PrismGraphQLResponse<T> {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        var bodyDict: [String: Any] = ["query": query.query]
        if let operationName = query.operationName {
            bodyDict["operationName"] = operationName
        }
        if let variables = query.variables {
            bodyDict["variables"] = variables
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)

        let (data, _) = try await session.data(for: request)
        let decoded = try JSONDecoder().decode(GraphQLRawResponse<T>.self, from: data)

        return PrismGraphQLResponse(data: decoded.data, errors: decoded.errors)
    }
}

private struct GraphQLRawResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [PrismGraphQLError]?
}
