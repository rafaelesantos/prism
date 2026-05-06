import Foundation

public actor PrismStreamWriter {
    private var chunks: [Data] = []
    private var ended = false

    public init() {}

    public func write(_ data: Data) {
        guard !ended else { return }
        chunks.append(data)
    }

    public func write(_ string: String) {
        write(Data(string.utf8))
    }

    public func end() {
        ended = true
    }

    public var isEnded: Bool { ended }

    public func serialize() -> Data {
        var result = Data()
        for chunk in chunks {
            let sizeHex = String(chunk.count, radix: 16)
            result.append(Data("\(sizeHex)\r\n".utf8))
            result.append(chunk)
            result.append(Data("\r\n".utf8))
        }
        result.append(Data("0\r\n\r\n".utf8))
        return result
    }
}

public enum PrismChunkedResponse {
    public static func chunked(contentType: String = "application/octet-stream") -> PrismHTTPResponse {
        var headers = PrismHTTPHeaders()
        headers.set(name: "Transfer-Encoding", value: "chunked")
        headers.set(name: "Content-Type", value: contentType)
        return PrismHTTPResponse(status: .ok, headers: headers, body: .empty)
    }
}

extension PrismHTTPResponse {
    public static func streaming(_ stream: AsyncStream<Data>, contentType: String = "application/octet-stream") async
        -> PrismHTTPResponse
    {
        var body = Data()
        for await chunk in stream {
            let sizeHex = String(chunk.count, radix: 16)
            body.append(Data("\(sizeHex)\r\n".utf8))
            body.append(chunk)
            body.append(Data("\r\n".utf8))
        }
        body.append(Data("0\r\n\r\n".utf8))

        var headers = PrismHTTPHeaders()
        headers.set(name: "Transfer-Encoding", value: "chunked")
        headers.set(name: "Content-Type", value: contentType)
        return PrismHTTPResponse(status: .ok, headers: headers, body: .data(body))
    }
}

extension PrismHTTPRequest {
    public func bodyChunks(size: Int = 8192) -> [Data] {
        guard let body, !body.isEmpty else { return [] }
        var chunks: [Data] = []
        var offset = body.startIndex
        while offset < body.endIndex {
            let end = min(offset + size, body.endIndex)
            chunks.append(body[offset..<end])
            offset = end
        }
        return chunks
    }
}
