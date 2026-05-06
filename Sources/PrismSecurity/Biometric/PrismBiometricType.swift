import Foundation

public enum PrismBiometricType: String, Sendable, Hashable, CaseIterable {
    case none
    case touchID
    case faceID
    case opticID

    public var displayName: String {
        switch self {
        case .none: "None"
        case .touchID: "Touch ID"
        case .faceID: "Face ID"
        case .opticID: "Optic ID"
        }
    }
}

public enum PrismBiometricPolicy: Sendable, Hashable {
    case biometricsOnly
    case biometricsOrPasscode

    public var allowsPasscodeFallback: Bool {
        self == .biometricsOrPasscode
    }
}
