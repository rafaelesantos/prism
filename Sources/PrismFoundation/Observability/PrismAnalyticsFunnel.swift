//
//  PrismAnalyticsFunnel.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public struct PrismFunnelStep: Sendable {
    public let name: String
    public let count: Int
    public let conversionRate: Double?

    public init(name: String, count: Int, conversionRate: Double? = nil) {
        self.name = name
        self.count = count
        self.conversionRate = conversionRate
    }
}

public actor PrismAnalyticsFunnel {
    private var stepNames: [String] = []
    private var stepUsers: [String: Set<String>] = [:]

    public init() {}

    public func define(steps: [String]) {
        stepNames = steps
        stepUsers = [:]
        for step in steps {
            stepUsers[step] = []
        }
    }

    public func record(step: String, userId: String) {
        guard stepUsers[step] != nil else { return }
        stepUsers[step]?.insert(userId)
    }

    public func report() -> [PrismFunnelStep] {
        var result: [PrismFunnelStep] = []
        var previousCount: Int?

        for name in stepNames {
            let count = stepUsers[name]?.count ?? 0
            let rate: Double? = previousCount.map { prev in
                prev > 0 ? Double(count) / Double(prev) : 0.0
            }
            result.append(PrismFunnelStep(name: name, count: count, conversionRate: rate))
            previousCount = count
        }

        return result
    }

    public func reset() {
        for key in stepUsers.keys {
            stepUsers[key] = []
        }
    }
}
