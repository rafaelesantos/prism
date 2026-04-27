//
//  PrismNetworkError.swift
//  Prism
//
//  Created by Rafael Escaleira on 29/03/25.
//

import Foundation
import PrismFoundation

/// Type-safe network errors with HTTP status code mapping.
public enum PrismNetworkError: PrismError {
    /// The URL could not be constructed from the endpoint's components.
    case invalidURL
    /// The server returned an unexpected or non-HTTP response.
    case invalidResponse
    /// The device has no network connectivity or the host is unreachable.
    case noConnectivity
    /// The server rejected the request (HTTP 400).
    case badRequest
    /// The server encountered an internal error (HTTP 5xx, 408, or 429).
    case serverError
    /// Authentication is required or the credentials are invalid (HTTP 401).
    case unauthorized
    /// The authenticated user lacks permission for this resource (HTTP 403).
    case forbidden
    /// No valid cached response is available for this request.
    case noCache

    /// A localized human-readable description of the error.
    public var description: String {
        switch self {
        case .invalidURL: return .localized(for: .invalidURLDescription)
        case .invalidResponse: return .localized(for: .invalidResponseDescription)
        case .noConnectivity: return .localized(for: .noConnectivityDescription)
        case .badRequest: return .localized(for: .badRequestDescription)
        case .serverError: return .localized(for: .serverErrorDescription)
        case .unauthorized: return .localized(for: .unauthorizedDescription)
        case .forbidden: return .localized(for: .forbiddenDescription)
        case .noCache: return .localized(for: .noCacheDescription)
        }
    }

    /// A localized description suitable for presenting to the user.
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return .localized(for: .invalidURLErrorDescription)
        case .invalidResponse: return .localized(for: .invalidResponseErrorDescription)
        case .noConnectivity: return .localized(for: .noConnectivityErrorDescription)
        case .badRequest: return .localized(for: .badRequestErrorDescription)
        case .serverError: return .localized(for: .serverErrorErrorDescription)
        case .unauthorized: return .localized(for: .unauthorizedErrorDescription)
        case .forbidden: return .localized(for: .forbiddenErrorDescription)
        case .noCache: return .localized(for: .noCacheErrorDescription)
        }
    }

    /// A localized explanation of why the error occurred.
    public var failureReason: String? {
        switch self {
        case .invalidURL: return .localized(for: .invalidURLFailureReason)
        case .invalidResponse: return .localized(for: .invalidResponseFailureReason)
        case .noConnectivity: return .localized(for: .noConnectivityFailureReason)
        case .badRequest: return .localized(for: .badRequestFailureReason)
        case .serverError: return .localized(for: .serverErrorFailureReason)
        case .unauthorized: return .localized(for: .unauthorizedFailureReason)
        case .forbidden: return .localized(for: .forbiddenFailureReason)
        case .noCache: return .localized(for: .noCacheFailureReason)
        }
    }

    /// A localized suggestion for how to recover from this error.
    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL: return .localized(for: .invalidURLRecoverySuggestion)
        case .invalidResponse: return .localized(for: .invalidResponseRecoverySuggestion)
        case .noConnectivity: return .localized(for: .noConnectivityRecoverySuggestion)
        case .badRequest: return .localized(for: .badRequestRecoverySuggestion)
        case .serverError: return .localized(for: .serverErrorRecoverySuggestion)
        case .unauthorized: return .localized(for: .unauthorizedRecoverySuggestion)
        case .forbidden: return .localized(for: .forbiddenRecoverySuggestion)
        case .noCache: return .localized(for: .noCacheRecoverySuggestion)
        }
    }
}

extension PrismNetworkError {
    /// Maps an HTTP status code to the corresponding ``PrismNetworkError``.
    ///
    /// - Parameter statusCode: The HTTP status code from the response.
    /// - Returns: A ``PrismNetworkError`` matching the status code.
    static func from(statusCode: Int) -> Self {
        switch statusCode {
        case 400:
            .badRequest
        case 401:
            .unauthorized
        case 403:
            .forbidden
        case 408, 429, 500...599:
            .serverError
        default:
            .invalidResponse
        }
    }

    /// Maps a generic `Error` (including `URLError`) to a ``PrismNetworkError``.
    ///
    /// - Parameter error: The underlying error to convert.
    /// - Returns: A ``PrismNetworkError`` matching the error's nature.
    static func from(error: Error) -> Self {
        if let networkError = error as? Self {
            return networkError
        }

        guard let urlError = error as? URLError else {
            return .invalidResponse
        }

        switch urlError.code {
        case .badURL, .unsupportedURL:
            return .invalidURL
        case .notConnectedToInternet,
            .networkConnectionLost,
            .cannotFindHost,
            .cannotConnectToHost,
            .dnsLookupFailed,
            .timedOut:
            return .noConnectivity
        default:
            return .invalidResponse
        }
    }
}
