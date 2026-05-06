import CryptoKit
import Foundation

public struct PrismKeyDerivation: Sendable {
    public init() {}

    // MARK: - HKDF

    public func deriveKey(
        from inputKey: SymmetricKey,
        salt: Data? = nil,
        info: Data = Data(),
        outputByteCount: Int = 32
    ) -> SymmetricKey {
        let saltData = salt ?? Data(repeating: 0, count: 32)
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKey,
            salt: saltData,
            info: info,
            outputByteCount: outputByteCount
        )
    }

    public func deriveKey(
        from sharedSecret: Data,
        salt: Data? = nil,
        info: Data = Data(),
        outputByteCount: Int = 32
    ) -> SymmetricKey {
        let inputKey = SymmetricKey(data: sharedSecret)
        return deriveKey(from: inputKey, salt: salt, info: info, outputByteCount: outputByteCount)
    }

    // MARK: - Password-Based

    public func deriveKey(
        fromPassword password: String,
        salt: Data,
        outputByteCount: Int = 32
    ) -> SymmetricKey {
        let passwordData = Data(password.utf8)
        let inputKey = SymmetricKey(data: passwordData)
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKey,
            salt: salt,
            info: Data("PrismSecurity.PasswordDerived".utf8),
            outputByteCount: outputByteCount
        )
    }

    public func generateSalt(byteCount: Int = 32) -> Data {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        return Data(bytes)
    }
}
