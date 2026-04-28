import Foundation

/// Errors emitted by the PrismServer module.
public enum PrismHTTPError: Error, Sendable {
    case bindFailed(String)
    case connectionFailed(String)
    case parsingFailed(String)
    case timeout
    case serverAlreadyRunning
    case serverNotRunning
    case tlsConfigurationFailed(String)
    case webSocketUpgradeFailed
    case fileMissing(String)
}
