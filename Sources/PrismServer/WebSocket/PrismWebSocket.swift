#if canImport(Network)
    import CryptoKit
    import Foundation
    import Network

    public enum PrismWebSocketOpcode: UInt8, Sendable {
        case continuation = 0x0
        case text = 0x1
        case binary = 0x2
        case close = 0x8
        case ping = 0x9
        case pong = 0xA
    }

    public struct PrismWebSocketFrame: Sendable {
        public let fin: Bool
        public let opcode: PrismWebSocketOpcode
        public let payload: Data

        public init(fin: Bool = true, opcode: PrismWebSocketOpcode, payload: Data) {
            self.fin = fin
            self.opcode = opcode
            self.payload = payload
        }

        public static func text(_ string: String) -> PrismWebSocketFrame {
            PrismWebSocketFrame(opcode: .text, payload: Data(string.utf8))
        }

        public static func binary(_ data: Data) -> PrismWebSocketFrame {
            PrismWebSocketFrame(opcode: .binary, payload: data)
        }

        public static func close(code: UInt16 = 1000) -> PrismWebSocketFrame {
            var data = Data()
            data.append(UInt8(code >> 8))
            data.append(UInt8(code & 0xFF))
            return PrismWebSocketFrame(opcode: .close, payload: data)
        }

        public static func ping(_ data: Data = Data()) -> PrismWebSocketFrame {
            PrismWebSocketFrame(opcode: .ping, payload: data)
        }

        public static func pong(_ data: Data = Data()) -> PrismWebSocketFrame {
            PrismWebSocketFrame(opcode: .pong, payload: data)
        }

        public func serialize() -> Data {
            var frame = Data()

            var firstByte: UInt8 = opcode.rawValue
            if fin { firstByte |= 0x80 }
            frame.append(firstByte)

            if payload.count < 126 {
                frame.append(UInt8(payload.count))
            } else if payload.count <= 65535 {
                frame.append(126)
                frame.append(UInt8(payload.count >> 8))
                frame.append(UInt8(payload.count & 0xFF))
            } else {
                frame.append(127)
                for i in (0..<8).reversed() {
                    frame.append(UInt8((payload.count >> (i * 8)) & 0xFF))
                }
            }

            frame.append(payload)
            return frame
        }
    }

    public struct PrismWebSocketParser: Sendable {

        public init() {}

        public func parse(_ data: Data) -> (PrismWebSocketFrame, Int)? {
            guard data.count >= 2 else { return nil }

            let firstByte = data[data.startIndex]
            let secondByte = data[data.startIndex + 1]

            let fin = (firstByte & 0x80) != 0
            guard let opcode = PrismWebSocketOpcode(rawValue: firstByte & 0x0F) else { return nil }
            let masked = (secondByte & 0x80) != 0
            var payloadLength = UInt64(secondByte & 0x7F)
            var offset = 2

            if payloadLength == 126 {
                guard data.count >= offset + 2 else { return nil }
                payloadLength =
                    UInt64(data[data.startIndex + offset]) << 8
                    | UInt64(data[data.startIndex + offset + 1])
                offset += 2
            } else if payloadLength == 127 {
                guard data.count >= offset + 8 else { return nil }
                payloadLength = 0
                for i in 0..<8 {
                    payloadLength = (payloadLength << 8) | UInt64(data[data.startIndex + offset + i])
                }
                offset += 8
            }

            var maskKey: [UInt8]?
            if masked {
                guard data.count >= offset + 4 else { return nil }
                maskKey = [
                    data[data.startIndex + offset],
                    data[data.startIndex + offset + 1],
                    data[data.startIndex + offset + 2],
                    data[data.startIndex + offset + 3],
                ]
                offset += 4
            }

            let totalNeeded = offset + Int(payloadLength)
            guard data.count >= totalNeeded else { return nil }

            var payload = Data(data[(data.startIndex + offset)..<(data.startIndex + totalNeeded)])

            if let mask = maskKey {
                for i in 0..<payload.count {
                    payload[i] ^= mask[i % 4]
                }
            }

            let frame = PrismWebSocketFrame(fin: fin, opcode: opcode, payload: payload)
            return (frame, totalNeeded)
        }
    }

    public struct PrismWebSocketUpgrade: Sendable {
        private static let webSocketGUID = "258EAFA5-E914-47DA-95CA-5AB5DC11D732"

        public static func isUpgradeRequest(_ request: PrismHTTPRequest) -> Bool {
            let upgrade = request.headers.value(for: "Upgrade")?.lowercased()
            let connection = request.headers.value(for: "Connection")?.lowercased()
            let key = request.headers.value(for: "Sec-WebSocket-Key")
            return upgrade == "websocket" && connection?.contains("upgrade") == true && key != nil
        }

        public static func upgradeResponse(for request: PrismHTTPRequest) -> PrismHTTPResponse? {
            guard let key = request.headers.value(for: "Sec-WebSocket-Key") else { return nil }

            let acceptValue = generateAcceptKey(from: key)

            var headers = PrismHTTPHeaders()
            headers.set(name: "Upgrade", value: "websocket")
            headers.set(name: "Connection", value: "Upgrade")
            headers.set(name: "Sec-WebSocket-Accept", value: acceptValue)

            if let protocol_ = request.headers.value(for: "Sec-WebSocket-Protocol") {
                let preferred = protocol_.split(separator: ",").first.map {
                    String($0).trimmingCharacters(in: .whitespaces)
                }
                if let preferred {
                    headers.set(name: "Sec-WebSocket-Protocol", value: preferred)
                }
            }

            return PrismHTTPResponse(status: .switchingProtocols, headers: headers)
        }

        private static func generateAcceptKey(from key: String) -> String {
            let combined = key + webSocketGUID
            let sha1Hash = Insecure.SHA1.hash(data: Data(combined.utf8))
            return Data(sha1Hash).base64EncodedString()
        }
    }

    public enum PrismWebSocketMessage: Sendable {
        case text(String)
        case binary(Data)
    }

    public protocol PrismWebSocketHandler: Sendable {
        func onConnect(connection: PrismWebSocketConnection) async
        func onMessage(connection: PrismWebSocketConnection, message: PrismWebSocketMessage) async
        func onDisconnect(connection: PrismWebSocketConnection) async
    }

    public actor PrismWebSocketConnection {
        private let sendFrame: @Sendable (PrismWebSocketFrame) async -> Void
        public nonisolated let id: String

        public init(id: String = UUID().uuidString, sendFrame: @escaping @Sendable (PrismWebSocketFrame) async -> Void)
        {
            self.id = id
            self.sendFrame = sendFrame
        }

        public func send(_ text: String) async {
            await sendFrame(.text(text))
        }

        public func send(_ data: Data) async {
            await sendFrame(.binary(data))
        }

        public func close(code: UInt16 = 1000) async {
            await sendFrame(.close(code: code))
        }

        public func ping() async {
            await sendFrame(.ping())
        }
    }
#endif
