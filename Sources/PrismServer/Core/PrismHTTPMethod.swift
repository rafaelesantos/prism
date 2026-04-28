import Foundation

/// HTTP methods as defined in RFC 7231.
public enum PrismHTTPMethod: String, Sendable, CaseIterable {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
    case HEAD
    case OPTIONS
    case TRACE
    case CONNECT
}
