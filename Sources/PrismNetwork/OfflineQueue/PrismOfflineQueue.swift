//
//  PrismOfflineQueue.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Network

public struct PrismQueuedRequest: Sendable, Identifiable {
    public let id: UUID
    public let urlRequest: URLRequest
    public let createdAt: Date
    public var retryCount: Int
    public let priority: Int

    public init(
        id: UUID = UUID(),
        urlRequest: URLRequest,
        createdAt: Date = Date(),
        retryCount: Int = 0,
        priority: Int = 0
    ) {
        self.id = id
        self.urlRequest = urlRequest
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.priority = priority
    }
}

public actor PrismOfflineQueue {
    private var queue: [PrismQueuedRequest] = []
    private var monitor: PrismConnectivityMonitor?
    private var flushHandler: (([PrismQueuedRequest]) async -> Void)?

    public var count: Int {
        queue.count
    }

    public init(
        autoFlush: Bool = false,
        flushHandler: (([PrismQueuedRequest]) async -> Void)? = nil
    ) {
        self.flushHandler = flushHandler
        if autoFlush {
            let connectivityMonitor = PrismConnectivityMonitor()
            self.monitor = connectivityMonitor
            Task { [weak self] in
                for await isConnected in connectivityMonitor.connectionStream() {
                    if isConnected {
                        await self?.flush()
                    }
                }
            }
        }
    }

    public func enqueue(_ request: PrismQueuedRequest) {
        queue.append(request)
    }

    public func dequeueAll() -> [PrismQueuedRequest] {
        let sorted = queue.sorted { $0.priority > $1.priority }
        queue.removeAll()
        return sorted
    }

    private func flush() async {
        guard !queue.isEmpty else { return }
        let requests = dequeueAll()
        await flushHandler?(requests)
    }
}

public final class PrismConnectivityMonitor: Sendable {
    private let monitor: NWPathMonitor
    private let monitorQueue: DispatchQueue

    public var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }

    public init() {
        self.monitor = NWPathMonitor()
        self.monitorQueue = DispatchQueue(label: "com.prism.connectivity")
        self.monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }

    public func connectionStream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied)
            }
            continuation.onTermination = { [weak monitor] _ in
                monitor?.cancel()
            }
        }
    }
}
