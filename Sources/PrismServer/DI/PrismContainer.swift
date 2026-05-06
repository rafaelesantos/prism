import Foundation

public enum PrismServiceLifetime: Sendable {
    case singleton
    case transient
    case scoped
}

public enum PrismServiceError: Error, Sendable {
    case notRegistered(String)
    case resolutionFailed(String)
}

public actor PrismContainer {
    private var registrations: [String: ServiceRegistration] = [:]
    private var singletons: [String: Any] = [:]

    public init() {}

    public func register<T>(
        _ type: T.Type,
        lifetime: PrismServiceLifetime = .singleton,
        factory: @escaping @Sendable () async throws -> T
    ) {
        let key = String(describing: type)
        registrations[key] = ServiceRegistration(lifetime: lifetime, factory: factory)
    }

    public func resolve<T>(_ type: T.Type) async throws -> T {
        let key = String(describing: type)
        guard let registration = registrations[key] else {
            throw PrismServiceError.notRegistered(key)
        }

        switch registration.lifetime {
        case .singleton:
            if let cached = singletons[key] as? T {
                return cached
            }
            let instance = try await registration.factory()
            guard let typed = instance as? T else {
                throw PrismServiceError.resolutionFailed(key)
            }
            singletons[key] = typed
            return typed
        case .transient, .scoped:
            let instance = try await registration.factory()
            guard let typed = instance as? T else {
                throw PrismServiceError.resolutionFailed(key)
            }
            return typed
        }
    }

    public func createScope() -> PrismScope {
        PrismScope(registrations: registrations)
    }
}

public actor PrismScope {
    private let registrations: [String: ServiceRegistration]
    private var scopedInstances: [String: Any] = [:]

    init(registrations: [String: ServiceRegistration]) {
        self.registrations = registrations
    }

    public func resolve<T>(_ type: T.Type) async throws -> T {
        let key = String(describing: type)
        guard let registration = registrations[key] else {
            throw PrismServiceError.notRegistered(key)
        }

        switch registration.lifetime {
        case .singleton:
            throw PrismServiceError.resolutionFailed("Resolve singletons from PrismContainer directly")
        case .scoped:
            if let cached = scopedInstances[key] as? T {
                return cached
            }
            let instance = try await registration.factory()
            guard let typed = instance as? T else {
                throw PrismServiceError.resolutionFailed(key)
            }
            scopedInstances[key] = typed
            return typed
        case .transient:
            let instance = try await registration.factory()
            guard let typed = instance as? T else {
                throw PrismServiceError.resolutionFailed(key)
            }
            return typed
        }
    }
}

struct ServiceRegistration: Sendable {
    let lifetime: PrismServiceLifetime
    let factory: @Sendable () async throws -> Any
}

extension PrismContainer {
    public func scoped<T: Sendable>(_ block: (PrismScope) async throws -> T) async throws -> T {
        let scope = createScope()
        return try await block(scope)
    }
}
