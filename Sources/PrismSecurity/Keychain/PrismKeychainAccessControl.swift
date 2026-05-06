import Foundation
import Security

public struct PrismKeychainAccessControl: Sendable {
    public let flags: SecAccessControlCreateFlags
    public let accessibility: PrismKeychainAccessibility

    public static let `default` = PrismKeychainAccessControl(
        flags: [],
        accessibility: .whenUnlocked
    )

    public static let biometricAny = PrismKeychainAccessControl(
        flags: .biometryAny,
        accessibility: .whenPasscodeSet
    )

    public static let biometricCurrentSet = PrismKeychainAccessControl(
        flags: .biometryCurrentSet,
        accessibility: .whenPasscodeSet
    )

    public static let devicePasscode = PrismKeychainAccessControl(
        flags: .devicePasscode,
        accessibility: .whenPasscodeSet
    )

    public static let biometricOrPasscode = PrismKeychainAccessControl(
        flags: [.biometryAny, .or, .devicePasscode],
        accessibility: .whenPasscodeSet
    )

    public init(flags: SecAccessControlCreateFlags, accessibility: PrismKeychainAccessibility) {
        self.flags = flags
        self.accessibility = accessibility
    }
}

public enum PrismKeychainAccessibility: Sendable, Hashable {
    case whenUnlocked
    case afterFirstUnlock
    case whenPasscodeSet

    var cfValue: CFString {
        switch self {
        case .whenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock
        case .whenPasscodeSet: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
