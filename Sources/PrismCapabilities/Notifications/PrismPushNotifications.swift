#if canImport(UserNotifications)
    import UserNotifications

    #if canImport(UIKit)
        import UIKit
    #elseif canImport(AppKit)
        import AppKit
    #endif

    // MARK: - Permission

    public enum PrismNotificationPermission: Sendable, CaseIterable {
        case notDetermined
        case denied
        case authorized
        case provisional
        case ephemeral
    }

    // MARK: - Notification Option

    public enum PrismNotificationOption: Sendable {
        case alert
        case badge
        case sound
        case provisional
        case criticalAlert
    }

    // MARK: - Sound

    public enum PrismNotificationSound: Sendable {
        case default_
        case named(String)
        case critical
    }

    // MARK: - Content

    public struct PrismNotificationContent: Sendable {
        public let title: String
        public let body: String
        public let subtitle: String?
        public let badge: Int?
        public let sound: PrismNotificationSound?
        public let categoryIdentifier: String?
        public let userInfo: [String: String]

        public init(
            title: String, body: String, subtitle: String? = nil, badge: Int? = nil,
            sound: PrismNotificationSound? = nil, categoryIdentifier: String? = nil, userInfo: [String: String] = [:]
        ) {
            self.title = title
            self.body = body
            self.subtitle = subtitle
            self.badge = badge
            self.sound = sound
            self.categoryIdentifier = categoryIdentifier
            self.userInfo = userInfo
        }
    }

    // MARK: - Trigger

    public enum PrismNotificationTrigger: Sendable {
        case immediate
        case timeInterval(TimeInterval)
        case calendar(DateComponents)
        case location(latitude: Double, longitude: Double, radius: Double)
    }

    // MARK: - Push Notification Client

    @MainActor @Observable
    public final class PrismPushNotificationClient {
        public private(set) var permissionStatus: PrismNotificationPermission = .notDetermined
        public var deviceToken: Data?

        private let center = UNUserNotificationCenter.current()

        public init() {}

        public func requestPermission(options: [PrismNotificationOption]) async throws -> Bool {
            var authOptions: UNAuthorizationOptions = []
            for option in options {
                switch option {
                case .alert: authOptions.insert(.alert)
                case .badge: authOptions.insert(.badge)
                case .sound: authOptions.insert(.sound)
                case .provisional: authOptions.insert(.provisional)
                case .criticalAlert: authOptions.insert(.criticalAlert)
                }
            }
            let granted = try await center.requestAuthorization(options: authOptions)
            await refreshPermissionStatus()
            return granted
        }

        public func scheduleLocal(
            content: PrismNotificationContent, trigger: PrismNotificationTrigger, identifier: String
        ) async throws {
            let unContent = UNMutableNotificationContent()
            unContent.title = content.title
            unContent.body = content.body
            if let subtitle = content.subtitle {
                unContent.subtitle = subtitle
            }
            if let badge = content.badge {
                unContent.badge = NSNumber(value: badge)
            }
            if let sound = content.sound {
                switch sound {
                case .default_: unContent.sound = .default
                case .named(let name):
                    unContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: name))
                case .critical: unContent.sound = .defaultCritical
                }
            }
            if let category = content.categoryIdentifier {
                unContent.categoryIdentifier = category
            }
            unContent.userInfo = content.userInfo

            let unTrigger: UNNotificationTrigger?
            switch trigger {
            case .immediate:
                unTrigger = nil
            case .timeInterval(let interval):
                unTrigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            case .calendar(let components):
                unTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            case .location:
                // Location triggers require CoreLocation import; simplified here
                unTrigger = nil
            }

            let request = UNNotificationRequest(identifier: identifier, content: unContent, trigger: unTrigger)
            try await center.add(request)
        }

        public func removeDelivered(identifiers: [String]) {
            center.removeDeliveredNotifications(withIdentifiers: identifiers)
        }

        public func removePending(identifiers: [String]) {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }

        public func registerForRemoteNotifications() {
            #if canImport(UIKit)
                UIApplication.shared.registerForRemoteNotifications()
            #elseif canImport(AppKit)
                NSApplication.shared.registerForRemoteNotifications()
            #endif
        }

        // MARK: - Private

        private func refreshPermissionStatus() async {
            let settings = await center.notificationSettings()
            permissionStatus =
                switch settings.authorizationStatus {
                case .notDetermined: .notDetermined
                case .denied: .denied
                case .authorized: .authorized
                case .provisional: .provisional
                case .ephemeral: .ephemeral
                @unknown default: .notDetermined
                }
        }
    }
#endif
