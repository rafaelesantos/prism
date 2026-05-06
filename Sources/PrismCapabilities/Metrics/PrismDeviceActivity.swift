import Foundation

// MARK: - Schedule

public struct PrismDeviceActivitySchedule: Sendable {
    public let startHour: Int
    public let startMinute: Int
    public let endHour: Int
    public let endMinute: Int
    public let repeats: Bool

    public init(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, repeats: Bool = true) {
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        self.repeats = repeats
    }
}

// MARK: - Event

public struct PrismDeviceActivityEvent: Sendable {
    public let name: String
    public let threshold: TimeInterval
    public let includesAllActivity: Bool

    public init(name: String, threshold: TimeInterval, includesAllActivity: Bool = false) {
        self.name = name
        self.threshold = threshold
        self.includesAllActivity = includesAllActivity
    }
}

// MARK: - Device Activity Client

#if canImport(DeviceActivity) && os(iOS)
    import DeviceActivity

    public final class PrismDeviceActivityClient: Sendable {
        private nonisolated(unsafe) let center = DeviceActivityCenter()

        public init() {}

        public func startMonitoring(
            name: String, schedule: PrismDeviceActivitySchedule, events: [PrismDeviceActivityEvent]
        ) throws {
            let activityName = DeviceActivityName(rawValue: name)
            let startComponents = DateComponents(hour: schedule.startHour, minute: schedule.startMinute)
            let endComponents = DateComponents(hour: schedule.endHour, minute: schedule.endMinute)
            let activitySchedule = DeviceActivitySchedule(
                intervalStart: startComponents,
                intervalEnd: endComponents,
                repeats: schedule.repeats
            )
            let activityEvents: [DeviceActivityEvent.Name: DeviceActivityEvent] = Dictionary(
                uniqueKeysWithValues: events.map { event in
                    let eventName = DeviceActivityEvent.Name(rawValue: event.name)
                    let activityEvent = DeviceActivityEvent(
                        threshold: DateComponents(second: Int(event.threshold))
                    )
                    return (eventName, activityEvent)
                }
            )
            try center.startMonitoring(activityName, during: activitySchedule, events: activityEvents)
        }

        public func stopMonitoring(name: String) {
            center.stopMonitoring([DeviceActivityName(rawValue: name)])
        }

        public func stopAllMonitoring() {
            center.stopMonitoring()
        }
    }
#endif
