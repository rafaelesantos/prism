import Foundation

// MARK: - OpenAPI Schema Types

public enum PrismOpenAPIType: String, Sendable {
    case string, integer, number, boolean, array, object
}

public struct PrismOpenAPISchema: Sendable {
    public let type: PrismOpenAPIType
    public let properties: [(String, PrismOpenAPIProperty)]
    public let required: [String]
    public let items: PrismOpenAPIProperty?
    public let description: String?

    public init(
        type: PrismOpenAPIType,
        properties: [(String, PrismOpenAPIProperty)] = [],
        required: [String] = [],
        items: PrismOpenAPIProperty? = nil,
        description: String? = nil
    ) {
        self.type = type
        self.properties = properties
        self.required = required
        self.items = items
        self.description = description
    }

    public static func object(
        _ properties: [(String, PrismOpenAPIProperty)], required: [String] = [], description: String? = nil
    ) -> PrismOpenAPISchema {
        PrismOpenAPISchema(type: .object, properties: properties, required: required, description: description)
    }

    public static func array(of items: PrismOpenAPIProperty, description: String? = nil) -> PrismOpenAPISchema {
        PrismOpenAPISchema(type: .array, items: items, description: description)
    }

    package func toDict() -> [String: Any] {
        var dict: [String: Any] = ["type": type.rawValue]
        if let description { dict["description"] = description }
        if !properties.isEmpty {
            var props: [String: Any] = [:]
            for (name, prop) in properties {
                props[name] = prop.toDict()
            }
            dict["properties"] = props
        }
        if !required.isEmpty { dict["required"] = required }
        if let items { dict["items"] = items.toDict() }
        return dict
    }
}

public struct PrismOpenAPIProperty: Sendable {
    public let type: PrismOpenAPIType
    public let format: String?
    public let description: String?
    public let enumValues: [String]?
    public let nullable: Bool

    public init(
        type: PrismOpenAPIType, format: String? = nil, description: String? = nil, enumValues: [String]? = nil,
        nullable: Bool = false
    ) {
        self.type = type
        self.format = format
        self.description = description
        self.enumValues = enumValues
        self.nullable = nullable
    }

    public static func string(_ description: String? = nil, format: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .string, format: format, description: description)
    }

    public static func integer(_ description: String? = nil, format: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .integer, format: format ?? "int64", description: description)
    }

    public static func number(_ description: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .number, description: description)
    }

    public static func boolean(_ description: String? = nil) -> PrismOpenAPIProperty {
        PrismOpenAPIProperty(type: .boolean, description: description)
    }

    package func toDict() -> [String: Any] {
        var dict: [String: Any] = ["type": type.rawValue]
        if let format { dict["format"] = format }
        if let description { dict["description"] = description }
        if let enumValues { dict["enum"] = enumValues }
        if nullable { dict["nullable"] = true }
        return dict
    }
}

// MARK: - Route Metadata

public struct PrismOpenAPIParameter: Sendable {
    public enum Location: String, Sendable { case path, query, header }

    public let name: String
    public let location: Location
    public let description: String?
    public let required: Bool
    public let type: PrismOpenAPIType

    public init(
        name: String, in location: Location, description: String? = nil, required: Bool = false,
        type: PrismOpenAPIType = .string
    ) {
        self.name = name
        self.location = location
        self.description = description
        self.required = location == .path ? true : required
        self.type = type
    }

    package func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "in": location.rawValue,
            "required": self.required,
            "schema": ["type": type.rawValue],
        ]
        if let description { dict["description"] = description }
        return dict
    }
}

public struct PrismOpenAPIResponseSpec: Sendable {
    public let statusCode: Int
    public let description: String
    public let schema: PrismOpenAPISchema?
    public let contentType: String

    public init(
        statusCode: Int, description: String, schema: PrismOpenAPISchema? = nil,
        contentType: String = "application/json"
    ) {
        self.statusCode = statusCode
        self.description = description
        self.schema = schema
        self.contentType = contentType
    }

    package func toDict() -> [String: Any] {
        var dict: [String: Any] = ["description": description]
        if let schema {
            dict["content"] = [contentType: ["schema": schema.toDict()]]
        }
        return dict
    }
}

public struct PrismRouteMetadata: Sendable {
    public let summary: String?
    public let description: String?
    public let tags: [String]
    public let parameters: [PrismOpenAPIParameter]
    public let requestBody: PrismOpenAPISchema?
    public let responses: [PrismOpenAPIResponseSpec]
    public let deprecated: Bool

    public init(
        summary: String? = nil,
        description: String? = nil,
        tags: [String] = [],
        parameters: [PrismOpenAPIParameter] = [],
        requestBody: PrismOpenAPISchema? = nil,
        responses: [PrismOpenAPIResponseSpec] = [],
        deprecated: Bool = false
    ) {
        self.summary = summary
        self.description = description
        self.tags = tags
        self.parameters = parameters
        self.requestBody = requestBody
        self.responses = responses
        self.deprecated = deprecated
    }
}
