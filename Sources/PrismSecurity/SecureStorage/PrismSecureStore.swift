import CryptoKit
import Foundation

public struct PrismSecureStore: Sendable {
    private let encryptor: PrismEncryptor
    private let keychain: PrismKeychain
    private let configuration: PrismSecureStoreConfiguration

    public init(configuration: PrismSecureStoreConfiguration = .default) {
        self.encryptor = PrismEncryptor(algorithm: configuration.algorithm)
        self.keychain = PrismKeychain(service: configuration.service)
        self.configuration = configuration
    }

    // MARK: - Codable Operations

    public func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws {
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw PrismSecurityError.serializationFailed
        }

        try saveData(data, forKey: key)
    }

    public func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) throws -> T {
        let data = try loadData(forKey: key)

        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw PrismSecurityError.deserializationFailed
        }
    }

    // MARK: - String Operations

    public func save(_ string: String, forKey key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw PrismSecurityError.serializationFailed
        }
        try saveData(data, forKey: key)
    }

    public func loadString(forKey key: String) throws -> String {
        let data = try loadData(forKey: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PrismSecurityError.deserializationFailed
        }
        return string
    }

    // MARK: - Data Operations

    public func saveData(_ data: Data, forKey key: String) throws {
        let encryptionKey = try getOrCreateEncryptionKey(forKey: key)
        let encrypted = try encryptor.encrypt(data, using: encryptionKey)

        let dataItem = PrismKeychainItem(
            id: "data_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        try keychain.save(data: encrypted, for: dataItem)
    }

    public func loadData(forKey key: String) throws -> Data {
        let encryptionKey = try loadEncryptionKey(forKey: key)

        let dataItem = PrismKeychainItem(
            id: "data_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        let encrypted = try keychain.load(for: dataItem)
        return try encryptor.decrypt(encrypted, using: encryptionKey)
    }

    // MARK: - Management

    public func delete(forKey key: String) throws {
        let keyItem = PrismKeychainItem(
            id: "key_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        let dataItem = PrismKeychainItem(
            id: "data_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        try keychain.delete(for: keyItem)
        try keychain.delete(for: dataItem)
    }

    public func exists(forKey key: String) -> Bool {
        let dataItem = PrismKeychainItem(
            id: "data_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        return keychain.exists(for: dataItem)
    }

    public func deleteAll() throws {
        try keychain.deleteAll()
    }

    // MARK: - Private Key Management

    private func getOrCreateEncryptionKey(forKey key: String) throws -> SymmetricKey {
        let keyItem = PrismKeychainItem(
            id: "key_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )

        if keychain.exists(for: keyItem) {
            let keyData = try keychain.load(for: keyItem)
            return SymmetricKey(data: keyData)
        }

        let newKey = encryptor.generateKey()
        let keyData = encryptor.exportKey(newKey)
        try keychain.save(data: keyData, for: keyItem)
        return newKey
    }

    private func loadEncryptionKey(forKey key: String) throws -> SymmetricKey {
        let keyItem = PrismKeychainItem(
            id: "key_\(key)",
            service: configuration.service,
            accessControl: configuration.keyAccessControl,
            synchronizable: configuration.synchronizeKey
        )
        let keyData = try keychain.load(for: keyItem)
        return SymmetricKey(data: keyData)
    }
}
