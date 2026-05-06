//
//  PrismRequestDeduplicator.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public actor PrismRequestDeduplicator {
    private var inFlight: [String: Task<any Sendable, Error>] = [:]

    public init() {}

    public func deduplicate<T: Sendable>(
        _ request: @Sendable @escaping () async throws -> T,
        key: String
    ) async throws -> T {
        if let existingTask = inFlight[key] {
            return try await existingTask.value as! T
        }

        let task = Task<any Sendable, Error> {
            try await request()
        }

        inFlight[key] = task

        do {
            let result = try await task.value
            inFlight.removeValue(forKey: key)
            return result as! T
        } catch {
            inFlight.removeValue(forKey: key)
            throw error
        }
    }

    public static func key(
        url: URL,
        method: String,
        body: Data? = nil
    ) -> String {
        var components = "\(method):\(url.absoluteString)"
        if let body {
            let hash = body.hashValue
            components += ":\(hash)"
        }
        return components
    }
}
