import Foundation

public protocol PrismJob: Sendable {
    static var name: String { get }
    func execute() async throws
}

extension PrismJob {
    public static var name: String { String(describing: Self.self) }
}

public struct PrismJobSchedule: Sendable {
    public let initialDelay: TimeInterval
    public let repeatInterval: TimeInterval?
    public let maxRetries: Int
    public let retryDelay: TimeInterval

    public init(
        initialDelay: TimeInterval = 0,
        repeatInterval: TimeInterval? = nil,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1
    ) {
        self.initialDelay = initialDelay
        self.repeatInterval = repeatInterval
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }

    public static let immediate = PrismJobSchedule()

    public static func delayed(_ seconds: TimeInterval) -> PrismJobSchedule {
        PrismJobSchedule(initialDelay: seconds)
    }

    public static func every(_ seconds: TimeInterval) -> PrismJobSchedule {
        PrismJobSchedule(repeatInterval: seconds)
    }
}

public actor PrismJobQueue {
    private var runningTasks: [String: Task<Void, Never>] = [:]
    private var isRunning = false

    public init() {}

    @discardableResult
    public func enqueue(_ job: any PrismJob, schedule: PrismJobSchedule = .immediate, id: String? = nil) -> String {
        let jobID = id ?? UUID().uuidString

        let task = Task { [schedule] in
            if schedule.initialDelay > 0 {
                try? await Task.sleep(for: .seconds(schedule.initialDelay))
            }

            var attempt = 0
            var shouldContinue = true

            while shouldContinue && !Task.isCancelled {
                do {
                    try await job.execute()
                    attempt = 0
                } catch {
                    attempt += 1
                    if attempt > schedule.maxRetries {
                        break
                    }
                    let backoff = schedule.retryDelay * pow(2.0, Double(attempt - 1))
                    try? await Task.sleep(for: .seconds(backoff))
                    continue
                }

                if let interval = schedule.repeatInterval {
                    try? await Task.sleep(for: .seconds(interval))
                } else {
                    shouldContinue = false
                }
            }
        }

        runningTasks[jobID] = task
        return jobID
    }

    public func cancel(_ jobID: String) {
        runningTasks[jobID]?.cancel()
        runningTasks.removeValue(forKey: jobID)
    }

    public func cancelAll() {
        for task in runningTasks.values {
            task.cancel()
        }
        runningTasks.removeAll()
    }

    public var activeJobCount: Int {
        runningTasks.count
    }
}

public actor PrismScheduler {
    private let queue: PrismJobQueue

    public init(queue: PrismJobQueue = PrismJobQueue()) {
        self.queue = queue
    }

    @discardableResult
    public func every(_ seconds: TimeInterval, job: any PrismJob) async -> String {
        await queue.enqueue(job, schedule: .every(seconds))
    }

    @discardableResult
    public func after(_ seconds: TimeInterval, job: any PrismJob) async -> String {
        await queue.enqueue(job, schedule: .delayed(seconds))
    }

    public func cancel(_ jobID: String) async {
        await queue.cancel(jobID)
    }

    public func cancelAll() async {
        await queue.cancelAll()
    }
}
