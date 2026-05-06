import Foundation

public struct PrismConfig: Sendable {
    private let values: [String: String]

    public init(values: [String: String] = [:]) {
        self.values = values
    }

    public static func fromEnvironment(overrides: [String: String] = [:]) -> PrismConfig {
        var merged = ProcessInfo.processInfo.environment
        for (key, value) in overrides {
            merged[key] = value
        }
        return PrismConfig(values: merged)
    }

    public static func load(path: String = ".env", environment: String? = nil) -> PrismConfig {
        var envValues = ProcessInfo.processInfo.environment

        if let parsed = Self.parseEnvFile(at: path) {
            for (key, value) in parsed {
                if envValues[key] == nil {
                    envValues[key] = value
                }
            }
        }

        if let env = environment ?? envValues["PRISM_ENV"] {
            let envPath = ".env.\(env)"
            if let envSpecific = Self.parseEnvFile(at: envPath) {
                for (key, value) in envSpecific {
                    if envValues[key] == nil {
                        envValues[key] = value
                    }
                }
            }
        }

        return PrismConfig(values: envValues)
    }

    public func get(_ key: String) -> String? {
        values[key]
    }

    public func get(_ key: String, default defaultValue: String) -> String {
        values[key] ?? defaultValue
    }

    public func require(_ key: String) throws -> String {
        guard let value = values[key] else {
            throw PrismConfigError.missingKey(key)
        }
        return value
    }

    public func getInt(_ key: String) -> Int? {
        values[key].flatMap(Int.init)
    }

    public func getInt(_ key: String, default defaultValue: Int) -> Int {
        values[key].flatMap(Int.init) ?? defaultValue
    }

    public func getBool(_ key: String) -> Bool? {
        guard let raw = values[key]?.lowercased() else { return nil }
        switch raw {
        case "true", "1", "yes": return true
        case "false", "0", "no": return false
        default: return nil
        }
    }

    public func getBool(_ key: String, default defaultValue: Bool) -> Bool {
        getBool(key) ?? defaultValue
    }

    public func getDouble(_ key: String) -> Double? {
        values[key].flatMap(Double.init)
    }

    public var environment: String {
        self.get("PRISM_ENV", default: "development")
    }

    public var isProduction: Bool { environment == "production" }

    public var isDevelopment: Bool { environment == "development" }

    public var port: UInt16 {
        UInt16(getInt("PORT", default: 8080))
    }

    public var host: String {
        self.get("HOST", default: "0.0.0.0")
    }

    public var keys: [String] { Array(values.keys) }

    private static func parseEnvFile(at path: String) -> [String: String]? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }

        var result: [String: String] = [:]
        for line in content.split(separator: "\n", omittingEmptySubsequences: true) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }

            guard let equalsIndex = trimmed.firstIndex(of: "=") else { continue }
            let key = String(trimmed[trimmed.startIndex..<equalsIndex]).trimmingCharacters(in: .whitespaces)
            var value = String(trimmed[trimmed.index(after: equalsIndex)...]).trimmingCharacters(in: .whitespaces)

            if (value.hasPrefix("\"") && value.hasSuffix("\"")) || (value.hasPrefix("'") && value.hasSuffix("'")) {
                value = String(value.dropFirst().dropLast())
            }

            if !key.isEmpty {
                result[key] = value
            }
        }
        return result
    }
}

public enum PrismConfigError: Error, Sendable {
    case missingKey(String)
    case invalidValue(String, String)
}
