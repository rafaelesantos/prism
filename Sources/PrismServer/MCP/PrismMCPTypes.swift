import Foundation

/// An MCP tool that can be called by clients.
public struct PrismMCPTool: Sendable {
    public let name: String
    public let description: String
    public let inputSchema: [String: any Sendable]

    public init(name: String, description: String, inputSchema: [String: any Sendable] = [:]) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
    }

    func toJSON() -> [String: Any] {
        var schema: [String: Any] = ["type": "object"]
        for (k, v) in inputSchema { schema[k] = v }
        return [
            "name": name,
            "description": description,
            "inputSchema": schema
        ]
    }
}

/// An MCP resource exposed to clients.
public struct PrismMCPResource: Sendable {
    public let uri: String
    public let name: String
    public let description: String
    public let mimeType: String

    public init(uri: String, name: String, description: String, mimeType: String = "text/plain") {
        self.uri = uri
        self.name = name
        self.description = description
        self.mimeType = mimeType
    }

    func toJSON() -> [String: Any] {
        [
            "uri": uri,
            "name": name,
            "description": description,
            "mimeType": mimeType
        ]
    }
}

/// An MCP prompt template.
public struct PrismMCPPrompt: Sendable {
    public let name: String
    public let description: String
    public let arguments: [PrismMCPPromptArgument]

    public init(name: String, description: String, arguments: [PrismMCPPromptArgument] = []) {
        self.name = name
        self.description = description
        self.arguments = arguments
    }

    func toJSON() -> [String: Any] {
        [
            "name": name,
            "description": description,
            "arguments": arguments.map { $0.toJSON() }
        ]
    }
}

/// An argument for an MCP prompt.
public struct PrismMCPPromptArgument: Sendable {
    public let name: String
    public let description: String
    public let required: Bool

    public init(name: String, description: String, required: Bool = false) {
        self.name = name
        self.description = description
        self.required = required
    }

    func toJSON() -> [String: Any] {
        [
            "name": name,
            "description": description,
            "required": required
        ]
    }
}

/// Content returned by tools or in prompt messages.
public enum PrismMCPContent: Sendable {
    case text(String)
    case image(data: String, mimeType: String)
    case resource(uri: String, text: String, mimeType: String?)

    func toJSON() -> [String: Any] {
        switch self {
        case .text(let text):
            return ["type": "text", "text": text]
        case .image(let data, let mimeType):
            return ["type": "image", "data": data, "mimeType": mimeType]
        case .resource(let uri, let text, let mimeType):
            var dict: [String: Any] = ["type": "resource", "resource": ["uri": uri, "text": text]]
            if let mimeType {
                var res = dict["resource"] as! [String: Any]
                res["mimeType"] = mimeType
                dict["resource"] = res
            }
            return dict
        }
    }
}

/// Result from calling an MCP tool.
public struct PrismMCPToolResult: Sendable {
    public let content: [PrismMCPContent]
    public let isError: Bool

    public init(content: [PrismMCPContent], isError: Bool = false) {
        self.content = content
        self.isError = isError
    }

    public static func text(_ text: String) -> PrismMCPToolResult {
        PrismMCPToolResult(content: [.text(text)])
    }

    public static func error(_ message: String) -> PrismMCPToolResult {
        PrismMCPToolResult(content: [.text(message)], isError: true)
    }

    func toJSON() -> [String: Any] {
        var dict: [String: Any] = [
            "content": content.map { $0.toJSON() }
        ]
        if isError { dict["isError"] = true }
        return dict
    }
}

/// Role in an MCP prompt message.
public enum PrismMCPRole: String, Sendable {
    case user
    case assistant
}

/// A message in an MCP prompt response.
public struct PrismMCPMessage: Sendable {
    public let role: PrismMCPRole
    public let content: PrismMCPContent

    public init(role: PrismMCPRole, content: PrismMCPContent) {
        self.role = role
        self.content = content
    }

    func toJSON() -> [String: Any] {
        [
            "role": role.rawValue,
            "content": content.toJSON()
        ]
    }
}

/// MCP protocol errors.
public enum PrismMCPError: Error, Sendable {
    case methodNotFound(String)
    case invalidParams(String)
    case toolNotFound(String)
    case resourceNotFound(String)
    case promptNotFound(String)
    case internalError(String)
}
