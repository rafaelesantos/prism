//
//  PrismAnalyticsFunnel.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

/// A single step in an analytics funnel with its count and conversion rate from the previous step.
public struct PrismFunnelStep: Sendable {
    /// The display name of this funnel step.
    public let name: String
    /// The number of unique users who reached this step.
    public let count: Int
    /// The conversion rate from the previous step, nil for the first step.
    public let conversionRate: Double?

    /// Creates a new funnel step.
    public init(name: String, count: Int, conversionRate: Double? = nil) {
        self.name = name
        self.count = count
        self.conversionRate = conversionRate
    }
}

/// Thread-safe analytics funnel that tracks user progression through defined steps.
public actor PrismAnalyticsFunnel {
    private var stepNames: [String] = []
    private var stepUsers: [String: Set<String>] = [:]

    /// Creates a new analytics funnel.
    public init() {}

    /// Defines the ordered steps of this funnel, resetting any existing data.
    public func define(steps: [String]) {
        stepNames = steps
        stepUsers = [:]
        for step in steps {
            stepUsers[step] = []
        }
    }

    /// Records a user reaching a specific funnel step.
    public func record(step: String, userId: String) {
        guard stepUsers[step] != nil else { return }
        stepUsers[step]?.insert(userId)
    }

    /// Generates a report with conversion rates between consecutive steps.
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

    /// Resets all funnel data, keeping step definitions.
    public func reset() {
        for key in stepUsers.keys {
            stepUsers[key] = []
        }
    }
}
