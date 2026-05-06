import Foundation

public struct PrismSecureStoreConfiguration: Sendable {
    public let algorithm: PrismEncryptor.Algorithm
    public let service: String
    public let keyAccessControl: PrismKeychainAccessControl
    public let synchronizeKey: Bool

    public static let `default` = PrismSecureStoreConfiguration(
        algorithm: .aesGCM,
        service: "PrismSecureStore",
        keyAccessControl: .default,
        synchronizeKey: false
    )

    public static let biometricProtected = PrismSecureStoreConfiguration(
        algorithm: .aesGCM,
        service: "PrismSecureStore",
        keyAccessControl: .biometricAny,
        synchronizeKey: false
    )

    public static let highSecurity = PrismSecureStoreConfiguration(
        algorithm: .chaChaPoly,
        service: "PrismSecureStore",
        keyAccessControl: .biometricCurrentSet,
        synchronizeKey: false
    )

    public init(
        algorithm: PrismEncryptor.Algorithm = .aesGCM,
        service: String = "PrismSecureStore",
        keyAccessControl: PrismKeychainAccessControl = .default,
        synchronizeKey: Bool = false
    ) {
        self.algorithm = algorithm
        self.service = service
        self.keyAccessControl = keyAccessControl
        self.synchronizeKey = synchronizeKey
    }
}
