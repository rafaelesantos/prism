import Foundation

public struct PrismRequestID: Sendable, CustomStringConvertible {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public static func generate() -> PrismRequestID {
        PrismRequestID(UUID().uuidString.lowercased())
    }

    public var description: String { value }
}

public struct PrismTraceContext: Sendable {
    public let requestID: String
    public let correlationID: String?
    public let parentID: String?
    public let startTime: ContinuousClock.Instant
    public var extra: [String: String]

    public init(
        requestID: String,
        correlationID: String? = nil,
        parentID: String? = nil,
        startTime: ContinuousClock.Instant = .now,
        extra: [String: String] = [:]
    ) {
        self.requestID = requestID
        self.correlationID = correlationID
        self.parentID = parentID
        self.startTime = startTime
        self.extra = extra
    }

    public var elapsed: Duration {
        ContinuousClock.now - startTime
    }
}

public struct PrismTracingMiddleware: PrismMiddleware, Sendable {
    private let headerName: String
    private let correlationHeader: String
    private let generateIfMissing: Bool

    public init(
        headerName: String = "X-Request-ID",
        correlationHeader: String = "X-Correlation-ID",
        generateIfMissing: Bool = true
    ) {
        self.headerName = headerName
        self.correlationHeader = correlationHeader
        self.generateIfMissing = generateIfMissing
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse
    {
        var req = request

        let requestID: String
        if let existing = req.headers.value(for: headerName) {
            requestID = existing
        } else if generateIfMissing {
            requestID = PrismRequestID.generate().value
        } else {
            return try await next(req)
        }

        let correlationID = req.headers.value(for: correlationHeader)
        let parentID = req.headers.value(for: "X-Parent-ID")

        let context = PrismTraceContext(
            requestID: requestID,
            correlationID: correlationID,
            parentID: parentID
        )

        req.userInfo["traceContext.requestID"] = context.requestID
        if let cid = context.correlationID {
            req.userInfo["traceContext.correlationID"] = cid
        }
        if let pid = context.parentID {
            req.userInfo["traceContext.parentID"] = pid
        }

        var response = try await next(req)
        response.headers.set(name: headerName, value: requestID)
        if let cid = correlationID {
            response.headers.set(name: correlationHeader, value: cid)
        }
        return response
    }
}

extension PrismHTTPRequest {
    public var traceContext: PrismTraceContext? {
        guard let requestID = userInfo["traceContext.requestID"] else { return nil }
        return PrismTraceContext(
            requestID: requestID,
            correlationID: userInfo["traceContext.correlationID"],
            parentID: userInfo["traceContext.parentID"]
        )
    }
}

public struct PrismTracingLogger: Sendable {
    public let requestID: String
    public let correlationID: String?

    public init(context: PrismTraceContext) {
        self.requestID = context.requestID
        self.correlationID = context.correlationID
    }

    public init(requestID: String, correlationID: String? = nil) {
        self.requestID = requestID
        self.correlationID = correlationID
    }

    public func log(_ message: String) -> String {
        if let cid = correlationID {
            return "[\(requestID)] [\(cid)] \(message)"
        }
        return "[\(requestID)] \(message)"
    }
}
