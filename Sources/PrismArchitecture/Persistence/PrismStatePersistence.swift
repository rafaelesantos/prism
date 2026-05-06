//
//  PrismStatePersistence.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Security

public protocol PrismPersistenceStrategy: Sendable {
    func save<State: Codable & Sendable>(_ state: State, key: String) throws

    func load<State: Codable & Sendable>(key: String) throws -> State?

    func clear(key: String) throws
}

// MARK: - Disk Persistence

public struct PrismDiskPersistence: PrismPersistenceStrategy, Sendable {
    private let directory: URL

    public init() {
        self.directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
    }

    public init(directory: URL) {
        self.directory = directory
    }

    public func save<State: Codable & Sendable>(_ state: State, key: String) throws {
        let data = try JSONEncoder().encode(state)
        let fileURL = directory.appendingPathComponent("\(key).json")
        try data.write(to: fileURL, options: .atomic)
    }

    public func load<State: Codable & Sendable>(key: String) throws -> State? {
        let fileURL = directory.appendingPathComponent("\(key).json")
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(State.self, from: data)
    }

    public func clear(key: String) throws {
        let fileURL = directory.appendingPathComponent("\(key).json")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }
}

// MARK: - Keychain Persistence

public struct PrismKeychainPersistence: PrismPersistenceStrategy, Sendable {
    public init() {}

    public func save<State: Codable & Sendable>(_ state: State, key: String) throws {
        let data = try JSONEncoder().encode(state)

        // Remove existing item first to avoid errSecDuplicateItem
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "PrismStatePersistence",
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "PrismStatePersistence",
            kSecValueData as String: data,
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw PrismPersistenceError.keychainWriteFailed(status)
        }
    }

    public func load<State: Codable & Sendable>(key: String) throws -> State? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "PrismStatePersistence",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess, let data = result as? Data else {
            throw PrismPersistenceError.keychainReadFailed(status)
        }

        return try JSONDecoder().decode(State.self, from: data)
    }

    public func clear(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "PrismStatePersistence",
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw PrismPersistenceError.keychainDeleteFailed(status)
        }
    }
}

// MARK: - UserDefaults Persistence

public struct PrismUserDefaultsPersistence: PrismPersistenceStrategy, Sendable {
    private let suiteName: String?

    public init() {
        self.suiteName = nil
    }

    public init(suiteName: String) {
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults {
        if let suiteName {
            return UserDefaults(suiteName: suiteName) ?? .standard
        }
        return .standard
    }

    public func save<State: Codable & Sendable>(_ state: State, key: String) throws {
        let data = try JSONEncoder().encode(state)
        defaults.set(data, forKey: "PrismState.\(key)")
    }

    public func load<State: Codable & Sendable>(key: String) throws -> State? {
        guard let data = defaults.data(forKey: "PrismState.\(key)") else {
            return nil
        }
        return try JSONDecoder().decode(State.self, from: data)
    }

    public func clear(key: String) throws {
        defaults.removeObject(forKey: "PrismState.\(key)")
    }
}

// MARK: - Persistence Errors

public enum PrismPersistenceError: Error, Sendable {
    case keychainWriteFailed(OSStatus)

    case keychainReadFailed(OSStatus)

    case keychainDeleteFailed(OSStatus)
}

// MARK: - Persist Middleware

public struct PrismPersistMiddleware<State: PrismState & Codable, Action: Sendable>: PrismMiddleware, Sendable {
    private let strategy: any PrismPersistenceStrategy
    private let key: String

    public init(
        strategy: any PrismPersistenceStrategy,
        key: String
    ) {
        self.strategy = strategy
        self.key = key
    }

    public func run(
        state: State,
        action: Action
    ) -> PrismEffect<Action> {
        try? strategy.save(state, key: key)
        return .none
    }
}

public func prismPersist<State: PrismState & Codable, Action: Sendable>(
    strategy: any PrismPersistenceStrategy,
    key: String
) -> PrismPersistMiddleware<State, Action> {
    PrismPersistMiddleware(strategy: strategy, key: key)
}
