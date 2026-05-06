import Foundation

public typealias PrismRouteHandler = @Sendable (PrismHTTPRequest) async throws -> PrismHTTPResponse

public struct PrismRoute: Sendable {
    public let method: PrismHTTPMethod
    public let pattern: String
    let segments: [RouteSegment]
    public let handler: PrismRouteHandler

    public init(method: PrismHTTPMethod, pattern: String, handler: @escaping PrismRouteHandler) {
        self.method = method
        self.pattern = pattern
        self.segments = RouteSegment.parse(pattern)
        self.handler = handler
    }

    func match(path: String) -> [String: String]? {
        let requestSegments = path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)

        if segments.last?.isWildcard == true {
            guard requestSegments.count >= segments.count - 1 else { return nil }
        } else {
            guard requestSegments.count == segments.count else { return nil }
        }

        var params: [String: String] = [:]

        for (i, segment) in segments.enumerated() {
            switch segment {
            case .literal(let value):
                guard i < requestSegments.count && requestSegments[i] == value else { return nil }
            case .parameter(let name):
                guard i < requestSegments.count else { return nil }
                params[name] = requestSegments[i]
            case .wildcard:
                let remaining = requestSegments[i...].joined(separator: "/")
                params["*"] = remaining
                return params
            }
        }

        return params
    }
}

enum RouteSegment: Sendable {
    case literal(String)
    case parameter(String)
    case wildcard

    var isWildcard: Bool {
        if case .wildcard = self { return true }
        return false
    }

    static func parse(_ pattern: String) -> [RouteSegment] {
        pattern
            .split(separator: "/", omittingEmptySubsequences: true)
            .map { segment in
                let s = String(segment)
                if s == "*" {
                    return .wildcard
                } else if s.hasPrefix(":") {
                    return .parameter(String(s.dropFirst()))
                } else {
                    return .literal(s)
                }
            }
    }
}
