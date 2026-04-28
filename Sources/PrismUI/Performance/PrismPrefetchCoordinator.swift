import SwiftUI

/// A type that can prefetch and cancel prefetch operations for items.
public protocol PrismPrefetchable: Sendable {
    /// Begins prefetching data for the given identifier.
    func prefetch(id: String) async

    /// Cancels an in-flight prefetch for the given identifier.
    func cancelPrefetch(id: String)
}

/// Coordinates prefetch tasks for visible and buffered items.
@Observable @MainActor
public final class PrismPrefetchCoordinator {
    /// Registered prefetchable data sources.
    public private(set) var prefetchables: [any PrismPrefetchable] = []

    /// Currently running prefetch tasks keyed by item id.
    private var activeTasks: [String: Task<Void, Never>] = [:]

    /// The set of ids currently being prefetched.
    public var activeIDs: Set<String> {
        Set(activeTasks.keys)
    }

    /// Creates a new prefetch coordinator.
    public init() {}

    /// Registers a prefetchable data source.
    /// - Parameter prefetchable: The data source to register.
    public func register(_ prefetchable: any PrismPrefetchable) {
        prefetchables.append(prefetchable)
    }

    /// Starts prefetch tasks for the given item identifiers.
    /// - Parameter ids: Item identifiers to prefetch.
    public func prefetch(ids: [String]) {
        for id in ids where activeTasks[id] == nil {
            let sources = prefetchables
            activeTasks[id] = Task {
                for source in sources {
                    await source.prefetch(id: id)
                }
            }
        }
    }

    /// Cancels prefetch tasks for the given item identifiers.
    /// - Parameter ids: Item identifiers whose prefetch to cancel.
    public func cancelPrefetch(ids: [String]) {
        for id in ids {
            activeTasks[id]?.cancel()
            activeTasks.removeValue(forKey: id)
            for source in prefetchables {
                source.cancelPrefetch(id: id)
            }
        }
    }

    /// Cancels all active prefetch tasks and clears registrations.
    public func reset() {
        for (_, task) in activeTasks {
            task.cancel()
        }
        activeTasks.removeAll()
        prefetchables.removeAll()
    }
}

/// View modifier that triggers prefetch on appear and cancels on disappear.
private struct PrismPrefetchModifier: ViewModifier {
    let coordinator: PrismPrefetchCoordinator
    let id: String

    func body(content: Content) -> some View {
        content
            .onAppear {
                coordinator.prefetch(ids: [id])
            }
            .onDisappear {
                coordinator.cancelPrefetch(ids: [id])
            }
    }
}

extension View {
    /// Triggers prefetch on appear and cancels on disappear.
    /// - Parameters:
    ///   - coordinator: The prefetch coordinator managing tasks.
    ///   - id: The item identifier to prefetch.
    public func prismPrefetch(
        coordinator: PrismPrefetchCoordinator,
        id: String
    ) -> some View {
        modifier(PrismPrefetchModifier(coordinator: coordinator, id: id))
    }
}
