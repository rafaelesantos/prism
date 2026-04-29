import Foundation

/// A Server-Sent Event.
public struct PrismSSEvent: Sendable {
    public let id: String?
    public let event: String?
    public let data: String
    public let retry: Int?

    public init(data: String, id: String? = nil, event: String? = nil, retry: Int? = nil) {
        self.data = data
        self.id = id
        self.event = event
        self.retry = retry
    }

    /// Serializes to SSE wire format.
    public func serialize() -> String {
        var result = ""
        if let id { result += "id: \(id)\n" }
        if let event { result += "event: \(event)\n" }
        if let retry { result += "retry: \(retry)\n" }
        for line in data.split(separator: "\n", omittingEmptySubsequences: false) {
            result += "data: \(line)\n"
        }
        result += "\n"
        return result
    }
}

/// A single SSE client connection.
public actor PrismSSEConnection {
    public let id: String
    private var connected = true
    private var continuation: AsyncStream<PrismSSEvent>.Continuation?
    public let stream: AsyncStream<PrismSSEvent>

    public init(id: String = UUID().uuidString) {
        self.id = id
        var cont: AsyncStream<PrismSSEvent>.Continuation?
        self.stream = AsyncStream { cont = $0 }
        self.continuation = cont
    }

    /// Sends an event to this connection.
    public func send(_ event: PrismSSEvent) {
        guard connected else { return }
        continuation?.yield(event)
    }

    /// Closes this connection.
    public func close() {
        connected = false
        continuation?.finish()
        continuation = nil
    }

    /// Whether this connection is still active.
    public var isConnected: Bool { connected }
}

/// Manages multiple SSE client connections.
public actor PrismSSEManager {
    private var connections: [String: PrismSSEConnection] = [:]

    public init() {}

    /// Creates and registers a new SSE connection.
    public func addConnection() -> PrismSSEConnection {
        let conn = PrismSSEConnection()
        connections[conn.id] = conn
        return conn
    }

    /// Removes a connection by ID.
    public func removeConnection(id: String) async {
        if let conn = connections.removeValue(forKey: id) {
            await conn.close()
        }
    }

    /// Broadcasts an event to all connected clients.
    public func broadcast(_ event: PrismSSEvent) async {
        for conn in connections.values {
            await conn.send(event)
        }
    }

    /// Sends an event to a specific connection.
    public func send(_ event: PrismSSEvent, to connectionId: String) async {
        await connections[connectionId]?.send(event)
    }

    /// Number of active connections.
    public var connectionCount: Int { connections.count }

    /// Returns a specific connection by ID.
    public func connection(id: String) -> PrismSSEConnection? {
        connections[id]
    }
}

/// Middleware that serves SSE endpoint.
public struct PrismSSEMiddleware: PrismMiddleware, Sendable {
    private let manager: PrismSSEManager
    private let path: String

    public init(manager: PrismSSEManager, path: String = "/events") {
        self.manager = manager
        self.path = path
    }

    public func handle(_ request: PrismHTTPRequest, next: @escaping PrismRouteHandler) async throws -> PrismHTTPResponse {
        guard request.path == path && request.method == .GET else {
            return try await next(request)
        }

        let connection = await manager.addConnection()

        var body = Data()
        for await event in await connection.stream {
            body.append(Data(event.serialize().utf8))
        }

        var headers = PrismHTTPHeaders()
        headers.set(name: "Content-Type", value: "text/event-stream")
        headers.set(name: "Cache-Control", value: "no-cache")
        headers.set(name: "Connection", value: "keep-alive")
        headers.set(name: "Content-Length", value: "\(body.count)")
        return PrismHTTPResponse(status: .ok, headers: headers, body: .data(body))
    }
}
