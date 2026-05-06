import Foundation

public struct PrismGraphQLDocument: Sendable {
    public let operations: [PrismGraphQLOperation]

    public var firstOperation: PrismGraphQLOperation? { operations.first }

    public func operation(named name: String) -> PrismGraphQLOperation? {
        operations.first { $0.name == name }
    }
}

public struct PrismGraphQLOperation: Sendable {
    public enum OperationType: String, Sendable {
        case query
        case mutation
        case subscription
    }

    public let operationType: OperationType
    public let name: String?
    public let selectionSet: [PrismGraphQLSelection]
    public let variableDefinitions: [PrismGraphQLVariableDefinition]
}

public struct PrismGraphQLVariableDefinition: Sendable {
    public let name: String
    public let type: String
    public let defaultValue: PrismGraphQLValue?
}

public enum PrismGraphQLSelection: Sendable {
    case field(PrismGraphQLFieldSelection)
    case fragmentSpread(String)
}

public struct PrismGraphQLFieldSelection: Sendable {
    public let alias: String?
    public let name: String
    public let arguments: [PrismGraphQLArgumentValue]
    public let selectionSet: [PrismGraphQLSelection]

    public var responseName: String { alias ?? name }
}

public struct PrismGraphQLArgumentValue: Sendable {
    public let name: String
    public let value: PrismGraphQLValue
}

public indirect enum PrismGraphQLValue: Sendable {
    case string(String)
    case int(Int)
    case float(Double)
    case boolean(Bool)
    case null
    case variable(String)
    case list([PrismGraphQLValue])
    case object([String: PrismGraphQLValue])
    case `enum`(String)

    public func toAny() -> Any {
        switch self {
        case .string(let s): return s
        case .int(let i): return i
        case .float(let f): return f
        case .boolean(let b): return b
        case .null: return NSNull()
        case .variable: return NSNull()
        case .list(let arr): return arr.map { $0.toAny() }
        case .object(let dict): return dict.mapValues { $0.toAny() }
        case .enum(let e): return e
        }
    }

    public func resolveVariables(_ variables: [String: Any]) -> Any {
        switch self {
        case .variable(let name): return variables[name] ?? NSNull()
        case .list(let arr): return arr.map { $0.resolveVariables(variables) }
        case .object(let dict): return dict.mapValues { $0.resolveVariables(variables) }
        default: return toAny()
        }
    }
}
