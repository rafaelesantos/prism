import Foundation

// MARK: - Task Type

public enum PrismBackgroundTaskType: Sendable {
    case appRefresh
    case processing
}

// MARK: - Task Config

public struct PrismBackgroundTaskConfig: Sendable {
    public let identifier: String
    public let type: PrismBackgroundTaskType
    public let requiresNetwork: Bool
    public let requiresCharging: Bool
    public let earliestBeginDate: Date?

    public init(
        identifier: String, type: PrismBackgroundTaskType, requiresNetwork: Bool = false,
        requiresCharging: Bool = false, earliestBeginDate: Date? = nil
    ) {
        self.identifier = identifier
        self.type = type
        self.requiresNetwork = requiresNetwork
        self.requiresCharging = requiresCharging
        self.earliestBeginDate = earliestBeginDate
    }
}

// MARK: - Background Task Client

#if canImport(BackgroundTasks) && !os(macOS)
    import BackgroundTasks

    public final class PrismBackgroundTaskClient: Sendable {

        public init() {}

        public func register(config: PrismBackgroundTaskConfig, handler: @escaping @Sendable () async -> Bool) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: config.identifier, using: nil) { task in
                let work = Task {
                    let success = await handler()
                    task.setTaskCompleted(success: success)
                }
                task.expirationHandler = {
                    work.cancel()
                }
            }
        }

        public func schedule(config: PrismBackgroundTaskConfig) throws {
            let request: BGTaskRequest
            switch config.type {
            case .appRefresh:
                request = BGAppRefreshTaskRequest(identifier: config.identifier)
            case .processing:
                let processingRequest = BGProcessingTaskRequest(identifier: config.identifier)
                processingRequest.requiresNetworkConnectivity = config.requiresNetwork
                processingRequest.requiresExternalPower = config.requiresCharging
                request = processingRequest
            }
            request.earliestBeginDate = config.earliestBeginDate
            try BGTaskScheduler.shared.submit(request)
        }

        public func cancel(identifier: String) {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
        }

        public func cancelAll() {
            BGTaskScheduler.shared.cancelAllTaskRequests()
        }
    }
#endif
