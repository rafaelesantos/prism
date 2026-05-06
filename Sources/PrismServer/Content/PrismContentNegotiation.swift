import Foundation

extension PrismHTTPRequest {
    public func decodeJSON<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let body else {
            throw PrismContentError.emptyBody
        }
        do {
            return try decoder.decode(type, from: body)
        } catch {
            throw PrismContentError.decodingFailed(error.localizedDescription)
        }
    }

    public var bodyString: String? {
        body.flatMap { String(data: $0, encoding: .utf8) }
    }

    public var formData: [String: String] {
        guard let body, let string = String(data: body, encoding: .utf8) else { return [:] }
        var result: [String: String] = [:]
        for pair in string.split(separator: "&") {
            let kv = pair.split(separator: "=", maxSplits: 1)
            if kv.count == 2 {
                let key = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                let value = String(kv[1]).removingPercentEncoding ?? String(kv[1])
                result[key] = value
            }
        }
        return result
    }
}

public enum PrismContentError: Error, Sendable {
    case emptyBody
    case decodingFailed(String)
    case unsupportedContentType(String)
    case multipartBoundaryMissing
    case multipartParsingFailed
}
