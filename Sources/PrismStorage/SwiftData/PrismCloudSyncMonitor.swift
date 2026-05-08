#if canImport(SwiftData)
    import Foundation
    import Observation
    import SwiftData

    public enum PrismSyncState: Sendable, Equatable {
        case idle
        case syncing
        case synced
        case error(String)
    }

    @Observable
    @MainActor
    public final class PrismCloudSyncMonitor {
        public private(set) var state: PrismSyncState
        public private(set) var lastSyncDate: Date?

        public init() {
            self.state = .idle
            self.lastSyncDate = nil
        }

        public func startMonitoring() {
            state = .syncing
        }

        public func forceSync() {
            state = .syncing
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(500))
                self?.state = .synced
                self?.lastSyncDate = Date()
            }
        }

        public func updateState(_ newState: PrismSyncState) {
            state = newState
            if case .synced = newState {
                lastSyncDate = Date()
            }
        }
    }
#endif
