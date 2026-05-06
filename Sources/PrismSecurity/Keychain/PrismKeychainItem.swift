import Foundation

public struct PrismKeychainItem: Sendable, Identifiable {
    public let id: String
    public let service: String
    public let accessGroup: String?
    public let accessControl: PrismKeychainAccessControl
    public let synchronizable: Bool

    public init(
        id: String,
        service: String = "PrismSecurity",
        accessGroup: String? = nil,
        accessControl: PrismKeychainAccessControl = .default,
        synchronizable: Bool = false
    ) {
        self.id = id
        self.service = service
        self.accessGroup = accessGroup
        self.accessControl = accessControl
        self.synchronizable = synchronizable
    }
}
