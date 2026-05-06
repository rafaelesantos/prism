#if canImport(LocalAuthentication)
    import LocalAuthentication

    // MARK: - Biometric Type

    public enum PrismBiometricType: Sendable, CaseIterable {
        case none
        case touchID
        case faceID
        case opticID
    }

    // MARK: - Biometric Policy

    public enum PrismBiometricPolicy: Sendable, CaseIterable {
        case deviceOwnerAuthenticationWithBiometrics
        case deviceOwnerAuthentication
    }

    // MARK: - Biometric Error

    public enum PrismBiometricError: Sendable, CaseIterable {
        case authenticationFailed
        case userCancel
        case userFallback
        case systemCancel
        case passcodeNotSet
        case biometryNotAvailable
        case biometryNotEnrolled
        case biometryLockout
    }

    // MARK: - Biometric Result

    public struct PrismBiometricResult: Sendable {
        public let success: Bool
        public let error: PrismBiometricError?

        public init(success: Bool, error: PrismBiometricError? = nil) {
            self.success = success
            self.error = error
        }
    }

    // MARK: - Biometric Client

    public final class PrismBiometricClient: Sendable {

        public init() {}

        public func availableBiometricType() -> PrismBiometricType {
            let context = LAContext()
            var error: NSError?
            _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            return context.biometryType.toPrism
        }

        public func canEvaluate(policy: PrismBiometricPolicy) -> Bool {
            let context = LAContext()
            var error: NSError?
            return context.canEvaluatePolicy(policy.toLAPolicy, error: &error)
        }

        public func authenticate(reason: String, policy: PrismBiometricPolicy) async -> PrismBiometricResult {
            let context = LAContext()
            do {
                let success = try await context.evaluatePolicy(policy.toLAPolicy, localizedReason: reason)
                return PrismBiometricResult(success: success)
            } catch let error as LAError {
                return PrismBiometricResult(success: false, error: error.toPrism)
            } catch {
                return PrismBiometricResult(success: false, error: .authenticationFailed)
            }
        }
    }

    // MARK: - Internal Mapping

    extension LABiometryType {
        var toPrism: PrismBiometricType {
            switch self {
            case .none: .none
            case .touchID: .touchID
            case .faceID: .faceID
            case .opticID: .opticID
            @unknown default: .none
            }
        }
    }

    extension PrismBiometricPolicy {
        var toLAPolicy: LAPolicy {
            switch self {
            case .deviceOwnerAuthenticationWithBiometrics: .deviceOwnerAuthenticationWithBiometrics
            case .deviceOwnerAuthentication: .deviceOwnerAuthentication
            }
        }
    }

    extension LAError {
        var toPrism: PrismBiometricError {
            switch self.code {
            case .authenticationFailed: .authenticationFailed
            case .userCancel: .userCancel
            case .userFallback: .userFallback
            case .systemCancel: .systemCancel
            case .passcodeNotSet: .passcodeNotSet
            case .biometryNotAvailable: .biometryNotAvailable
            case .biometryNotEnrolled: .biometryNotEnrolled
            case .biometryLockout: .biometryLockout
            case .appCancel: .systemCancel
            case .invalidContext: .authenticationFailed
            case .notInteractive: .authenticationFailed
            case .biometryNotPaired: .biometryNotAvailable
            case .biometryDisconnected: .biometryNotAvailable
            case .invalidDimensions: .authenticationFailed
            case .companionNotAvailable: .biometryNotAvailable
            @unknown default: .authenticationFailed
            }
        }
    }
#endif
