//
//  PrismIntelligenceFeatureValue.swift
//  Prism
//
//  Created by Rafael Escaleira on 11/04/26.
//

import Foundation

/// A feature value for tabular data (int, double, string, or bool).
public enum PrismIntelligenceFeatureValue: Codable, Equatable, Hashable, Sendable {
    /// A string feature value.
    case string(String)
    /// An integer feature value.
    case int(Int)
    /// A double-precision floating-point feature value.
    case double(Double)
    /// A Boolean feature value.
    case bool(Bool)

    /// Creates a feature value by inspecting the runtime type of the given value.
    ///
    /// Supported types: `String`, `Int`, `Double`, `Float`, `Bool`, and `NSNumber`.
    ///
    /// - Parameter value: The value to wrap. Returns `nil` if the type is unsupported.
    public init?(_ value: Any) {
        switch value {
        case let string as String:
            self = .string(string)
        case let int as Int:
            self = .int(int)
        case let double as Double:
            self = .double(double)
        case let float as Float:
            self = .double(Double(float))
        case let bool as Bool:
            self = .bool(bool)
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                self = .bool(number.boolValue)
            } else if number.doubleValue.rounded(.towardZero) == number.doubleValue {
                self = .int(number.intValue)
            } else {
                self = .double(number.doubleValue)
            }
        default:
            return nil
        }
    }

    var foundationValue: Any {
        switch self {
        case .string(let string):
            string
        case .int(let int):
            int
        case .double(let double):
            double
        case .bool(let bool):
            bool
        }
    }

    var doubleValue: Double? {
        switch self {
        case .double(let double):
            double
        case .int(let int):
            Double(int)
        case .string, .bool:
            nil
        }
    }
}

/// A dictionary mapping feature names to their values, representing a single data row.
public typealias PrismIntelligenceFeatureRow = [String: PrismIntelligenceFeatureValue]

/// A training sample for text classification.
public struct PrismTextTrainingSample: Codable, Equatable, Hashable, Sendable {
    /// The input text to classify.
    public var text: String
    /// The expected classification label.
    public var label: String

    /// Creates a text training sample.
    ///
    /// - Parameters:
    ///   - text: The input text.
    ///   - label: The expected label.
    public init(
        text: String,
        label: String
    ) {
        self.text = text
        self.label = label
    }
}
