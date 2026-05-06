import Foundation

public actor PrismRoom {
    public nonisolated let name: String
    private var connections: [String: PrismWebSocketConnection] = [:]

    public init(name: String) {
        self.name = name
    }

    public func join(_ connection: PrismWebSocketConnection) async {
        let connID = connection.id
        connections[connID] = connection
    }

    public func leave(_ connectionID: String) {
        connections.removeValue(forKey: connectionID)
    }

    public func broadcast(_ message: PrismWebSocketMessage) async {
        for (_, conn) in connections {
            switch message {
            case .text(let text):
                await conn.send(text)
            case .binary(let data):
                await conn.send(data)
            }
        }
    }

    public func broadcast(_ message: PrismWebSocketMessage, excluding connectionID: String) async {
        for (id, conn) in connections where id != connectionID {
            switch message {
            case .text(let text):
                await conn.send(text)
            case .binary(let data):
                await conn.send(data)
            }
        }
    }

    public func send(to connectionID: String, message: PrismWebSocketMessage) async {
        guard let conn = connections[connectionID] else { return }
        switch message {
        case .text(let text):
            await conn.send(text)
        case .binary(let data):
            await conn.send(data)
        }
    }

    public var memberCount: Int { connections.count }

    public var memberIDs: [String] { Array(connections.keys) }

    public var isEmpty: Bool { connections.isEmpty }
}

public actor PrismRoomManager {
    private var roomMap: [String: PrismRoom] = [:]

    public init() {}

    public func room(_ name: String) -> PrismRoom {
        if let existing = roomMap[name] {
            return existing
        }
        let newRoom = PrismRoom(name: name)
        roomMap[name] = newRoom
        return newRoom
    }

    public func join(_ roomName: String, connection: PrismWebSocketConnection) async {
        let r = room(roomName)
        await r.join(connection)
    }

    public func leave(_ roomName: String, connectionID: String) async {
        guard let r = roomMap[roomName] else { return }
        await r.leave(connectionID)
        if await r.isEmpty {
            roomMap.removeValue(forKey: roomName)
        }
    }

    public func leaveAll(connectionID: String) async {
        for (name, r) in roomMap {
            await r.leave(connectionID)
            if await r.isEmpty {
                roomMap.removeValue(forKey: name)
            }
        }
    }

    public func broadcast(_ roomName: String, message: PrismWebSocketMessage) async {
        guard let r = roomMap[roomName] else { return }
        await r.broadcast(message)
    }

    public var rooms: [String] { Array(roomMap.keys) }

    public var roomCount: Int { roomMap.count }
}

public actor PrismPresence {
    private var presenceMap: [String: [String: [String: String]]] = [:]

    public init() {}

    public func track(roomName: String, connectionID: String, meta: [String: String] = [:]) {
        presenceMap[roomName, default: [:]][connectionID] = meta
    }

    public func untrack(roomName: String, connectionID: String) {
        presenceMap[roomName]?.removeValue(forKey: connectionID)
        if presenceMap[roomName]?.isEmpty == true {
            presenceMap.removeValue(forKey: roomName)
        }
    }

    public func list(roomName: String) -> [(connectionID: String, meta: [String: String])] {
        guard let entries = presenceMap[roomName] else { return [] }
        return entries.map { (connectionID: $0.key, meta: $0.value) }
    }

    public func count(roomName: String) -> Int {
        presenceMap[roomName]?.count ?? 0
    }
}
