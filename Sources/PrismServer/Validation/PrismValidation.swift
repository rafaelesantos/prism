import Foundation

public struct PrismValidationRule: Sendable {
    private let name: String
    private let check: @Sendable (String?) -> String?

    public init(name: String, check: @escaping @Sendable (String?) -> String?) {
        self.name = name
        self.check = check
    }

    func validate(_ value: String?) -> String? {
        check(value)
    }

    public static let required = PrismValidationRule(name: "required") { value in
        guard let value, !value.isEmpty else { return "is required" }
        return nil
    }

    public static let email = PrismValidationRule(name: "email") { value in
        guard let value, !value.isEmpty else { return nil }
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard value.range(of: pattern, options: .regularExpression) != nil else {
            return "must be a valid email"
        }
        return nil
    }

    public static func minLength(_ n: Int) -> PrismValidationRule {
        PrismValidationRule(name: "minLength") { value in
            guard let value, !value.isEmpty else { return nil }
            guard value.count >= n else { return "must be at least \(n) characters" }
            return nil
        }
    }

    public static func maxLength(_ n: Int) -> PrismValidationRule {
        PrismValidationRule(name: "maxLength") { value in
            guard let value, !value.isEmpty else { return nil }
            guard value.count <= n else { return "must be at most \(n) characters" }
            return nil
        }
    }

    public static let integer = PrismValidationRule(name: "integer") { value in
        guard let value, !value.isEmpty else { return nil }
        guard Int(value) != nil else { return "must be an integer" }
        return nil
    }

    public static let numeric = PrismValidationRule(name: "numeric") { value in
        guard let value, !value.isEmpty else { return nil }
        guard Double(value) != nil else { return "must be a number" }
        return nil
    }

    public static func min(_ n: Int) -> PrismValidationRule {
        PrismValidationRule(name: "min") { value in
            guard let value, let num = Int(value) else { return nil }
            guard num >= n else { return "must be at least \(n)" }
            return nil
        }
    }

    public static func max(_ n: Int) -> PrismValidationRule {
        PrismValidationRule(name: "max") { value in
            guard let value, let num = Int(value) else { return nil }
            guard num <= n else { return "must be at most \(n)" }
            return nil
        }
    }

    public static func pattern(_ regex: String, _ message: String = "has invalid format") -> PrismValidationRule {
        PrismValidationRule(name: "pattern") { value in
            guard let value, !value.isEmpty else { return nil }
            guard value.range(of: regex, options: .regularExpression) != nil else { return message }
            return nil
        }
    }

    public static func oneOf(_ allowed: [String]) -> PrismValidationRule {
        PrismValidationRule(name: "oneOf") { value in
            guard let value, !value.isEmpty else { return nil }
            guard allowed.contains(value) else { return "must be one of: \(allowed.joined(separator: ", "))" }
            return nil
        }
    }

    public static let url = PrismValidationRule(name: "url") { value in
        guard let value, !value.isEmpty else { return nil }
        guard URL(string: value) != nil, value.hasPrefix("http://") || value.hasPrefix("https://") else {
            return "must be a valid URL"
        }
        return nil
    }

    public static let uuid = PrismValidationRule(name: "uuid") { value in
        guard let value, !value.isEmpty else { return nil }
        guard UUID(uuidString: value) != nil else { return "must be a valid UUID" }
        return nil
    }
}

public struct PrismValidator: Sendable {
    private var fieldRules: [(String, [PrismValidationRule])]

    public init() {
        self.fieldRules = []
    }

    public mutating func field(_ name: String, _ rules: PrismValidationRule...) {
        fieldRules.append((name, rules))
    }

    public func validate(_ data: [String: String]) -> PrismValidationResult {
        var errors: [String: [String]] = [:]
        for (field, rules) in fieldRules {
            let value = data[field]
            for rule in rules {
                if let error = rule.validate(value) {
                    errors[field, default: []].append(error)
                }
            }
        }
        return PrismValidationResult(errors: errors)
    }
}

public struct PrismValidationResult: Sendable {
    public let errors: [String: [String]]

    public var isValid: Bool { errors.isEmpty }

    public var allErrors: [String] {
        errors.flatMap { field, messages in
            messages.map { "\(field) \($0)" }
        }
    }

    public func errorResponse() -> PrismHTTPResponse? {
        guard !isValid else { return nil }
        return PrismHTTPResponse.json(
            ["errors": errors],
            status: .unprocessableEntity
        )
    }
}

extension PrismHTTPRequest {
    public func validate(_ configure: (inout PrismValidator) -> Void) -> PrismValidationResult {
        var validator = PrismValidator()
        configure(&validator)
        let data = body != nil ? formData : queryParameters
        return validator.validate(data)
    }

    public func validateJSON(_ configure: (inout PrismValidator) -> Void) -> PrismValidationResult {
        var validator = PrismValidator()
        configure(&validator)
        guard let body,
            let dict = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
        else {
            return PrismValidationResult(errors: ["_body": ["invalid JSON"]])
        }
        let stringDict = dict.mapValues { "\($0)" }
        return validator.validate(stringDict)
    }
}
