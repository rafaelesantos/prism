import Foundation

public enum PrismPermissionStatus: String, Sendable, Hashable, CaseIterable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case limited
    case provisional

    public var isGranted: Bool {
        switch self {
        case .authorized, .limited, .provisional: true
        case .notDetermined, .denied, .restricted: false
        }
    }

    public var canRequest: Bool {
        self == .notDetermined
    }
}
