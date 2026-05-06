import Foundation

public enum PrismNotificationTrigger: Sendable, Equatable {
    case timeInterval(seconds: TimeInterval, repeats: Bool)
    case daily(hour: Int, minute: Int)
}

public struct PrismNotificationRequest: Sendable {
    public let identifier: String
    public let title: String
    public let body: String
    public let trigger: PrismNotificationTrigger

    public init(identifier: String, title: String, body: String, trigger: PrismNotificationTrigger) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.trigger = trigger
    }
}

public protocol PrismNotificationScheduling: Sendable {
    func schedule(_ request: PrismNotificationRequest) async throws
    func cancel(identifier: String) async
    func cancelAll() async
}
