#if canImport(Combine)
    import Foundation

    public actor PrismPermissionMonitor {
        private let client: PrismPermissionClient
        private let permissions: [PrismPermission]
        private let interval: TimeInterval

        public init(
            permissions: [PrismPermission],
            interval: TimeInterval = 2.0,
            client: PrismPermissionClient = PrismPermissionClient()
        ) {
            self.permissions = permissions
            self.interval = interval
            self.client = client
        }

        public func statusChanges() -> AsyncStream<PrismPermissionChange> {
            AsyncStream { continuation in
                let task = Task { [weak self] in
                    guard let self else {
                        continuation.finish()
                        return
                    }
                    var previous = await self.currentStatuses()
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(self.interval))
                        let current = await self.currentStatuses()
                        let perms = await self.permissions
                        for permission in perms {
                            let old = previous[permission]
                            let new = current[permission]
                            if old != new, let old, let new {
                                continuation.yield(
                                    PrismPermissionChange(
                                        permission: permission,
                                        oldStatus: old,
                                        newStatus: new
                                    )
                                )
                            }
                        }
                        previous = current
                    }
                    continuation.finish()
                }
                continuation.onTermination = { _ in task.cancel() }
            }
        }

        private func currentStatuses() -> [PrismPermission: PrismPermissionStatus] {
            client.statuses(for: permissions)
        }
    }

    public struct PrismPermissionChange: Sendable, Equatable {
        public let permission: PrismPermission
        public let oldStatus: PrismPermissionStatus
        public let newStatus: PrismPermissionStatus
    }
#endif
