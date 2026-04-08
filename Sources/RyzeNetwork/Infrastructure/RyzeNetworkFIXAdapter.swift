//
//  RyzeFIXSocketAdapter.swift
//  Ryze
//
//  Created by Rafael Escaleira on 05/04/26.
//


import Foundation
import Network
import RyzeFoundation
import RyzeNetwork

public actor RyzeFIXSocketAdapter: RyzeNetworkSocketClient {
    private let logger = RyzeNetworkLogger()
    private let soh = UInt8(1)

    private var connection: NWConnection?
    private var receiveBuffer = Data()

    public init() {}

    public func connect<Request: RyzeNetworkSocketRequest>(with request: Request) async throws -> AsyncStream<Data> {
        guard let endpoint = await request.endpoint else {
            logger.error("❌ Invalid FIX endpoint: \(String(describing: request))")
            throw RyzeNetworkError.invalidURL
        }

        let port = try endpoint.port.rawValue
        logger.info("🌐 Connecting FIX socket to \(endpoint.host) on port \(port)")

        connection = try NWConnection(
            host: endpoint.host,
            port: endpoint.port,
            using: endpoint.parameters
        )

        return AsyncStream { continuation in
            Task(priority: .high) {
                continuation.onTermination = { [weak self] _ in
                    guard let self else { return }
                    Task {
                        await self.disconnect()
                    }
                }

                let stateStream = await connectionStates()

                for await status in stateStream {
                    switch status {
                    case .open:
                        logger.info("✅ FIX socket connected to \(endpoint.host) on port \(port)")
                        await receive(on: continuation)

                    case .close:
                        logger.info("🔌 FIX socket disconnected from \(endpoint.host) on port \(port)")
                        continuation.finish()
                    }
                }
            }
        }
    }

    public func send(command: RyzeNetworkSocketCommand) async throws {
        guard connection != nil else {
            throw RyzeNetworkError.badRequest
        }

        guard let content = command.message.data(using: .utf8) else {
            throw RyzeNetworkError.badRequest
        }

        logger.info("✉️ Sending FIX message")

        try await withCheckedThrowingContinuation { continuation in
            connection?.send(
                content: content,
                completion: .contentProcessed { error in
                    guard let error else {
                        return continuation.resume()
                    }

                    continuation.resume(throwing: error)
                }
            )
        }
    }

    private func connectionStates() async -> AsyncStream<RyzeNetworkSocketStatus> {
        AsyncStream { continuation in
            connection?.stateUpdateHandler = { [logger] state in
                switch state {
                case .ready:
                    continuation.yield(.open)

                case .cancelled:
                    continuation.yield(.close)

                case .failed(let error):
                    logger.error("❗️FIX connection failed: \(error.localizedDescription)")
                    continuation.yield(.close)

                default:
                    break
                }
            }

            connection?.start(
                queue: DispatchQueue(
                    label: UUID().uuidString,
                    qos: .userInitiated,
                    attributes: .concurrent
                )
            )
        }
    }

    private func receive(on continuation: AsyncStream<Data>.Continuation) {
        connection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: 10 * 1024 * 1024
        ) { [weak self] content, _, isComplete, error in
            guard let self else { return }

            Task {
                await self.processReceive(
                    content: content,
                    isComplete: isComplete,
                    error: error,
                    continuation: continuation
                )
            }
        }
    }

    private func processReceive(
        content: Data?,
        isComplete: Bool,
        error: Error?,
        continuation: AsyncStream<Data>.Continuation
    ) async {
        if connection?.state == .cancelled {
            continuation.finish()
            return
        }

        if let error {
            logger.error("📭 FIX receive error: \(error.localizedDescription)")
        }

        if let content, !content.isEmpty {
            receiveBuffer.append(content)
            emitFrames(on: continuation)
        }

        if isComplete {
            receiveBuffer.removeAll(keepingCapacity: true)
            continuation.finish()
            return
        }

        receive(on: continuation)
    }

    private func emitFrames(on continuation: AsyncStream<Data>.Continuation) {
        while let length = frameLength(in: receiveBuffer) {
            let frame = receiveBuffer.prefix(length)
            continuation.yield(Data(frame))
            receiveBuffer.removeFirst(length)
        }
    }

    private func frameLength(in buffer: Data) -> Int? {
        guard !buffer.isEmpty else { return nil }

        guard let beginIndex = indexOfBeginString(in: buffer) else {
            receiveBuffer.removeAll(keepingCapacity: true)
            return nil
        }

        if beginIndex > .zero {
            receiveBuffer.removeFirst(beginIndex)
            return frameLength(in: receiveBuffer)
        }

        guard let firstSeparator = buffer.firstIndex(of: soh) else {
            return nil
        }

        let afterFirst = buffer.index(after: firstSeparator)
        guard afterFirst < buffer.endIndex else { return nil }
        guard let secondSeparator = buffer[afterFirst...].firstIndex(of: soh) else {
            return nil
        }

        let bodyLengthFieldData = buffer[afterFirst..<secondSeparator]
        guard let bodyLengthField = String(data: bodyLengthFieldData, encoding: .utf8),
              bodyLengthField.hasPrefix("9="),
              let bodyLength = Int(bodyLengthField.dropFirst(2))
        else {
            return nil
        }

        let headerLength = buffer.distance(from: buffer.startIndex, to: buffer.index(after: secondSeparator))
        let totalLength = headerLength + bodyLength + 7

        guard buffer.count >= totalLength else {
            return nil
        }

        return totalLength
    }

    private func indexOfBeginString(in buffer: Data) -> Int? {
        let prefix = Array("8=FIX".utf8)

        guard buffer.count >= prefix.count else {
            return nil
        }

        for start in 0...(buffer.count - prefix.count) {
            let end = start + prefix.count
            if Array(buffer[start..<end]) == prefix {
                return start
            }
        }

        return nil
    }

    private func disconnect() {
        connection?.cancel()
    }
}
