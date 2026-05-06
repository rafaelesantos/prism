import SwiftUI

public protocol PrismPrefetchable: Sendable {
    func prefetch(id: String) async

    func cancelPrefetch(id: String)
}

@Observable @MainActor
public final class PrismPrefetchCoordinator {
    public private(set) var prefetchables: [any PrismPrefetchable] = []

    private var activeTasks: [String: Task<Void, Never>] = [:]

    public var activeIDs: Set<String> {
        Set(activeTasks.keys)
    }

    public init() {}

    public func register(_ prefetchable: any PrismPrefetchable) {
        prefetchables.append(prefetchable)
    }

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

    public func cancelPrefetch(ids: [String]) {
        for id in ids {
            activeTasks[id]?.cancel()
            activeTasks.removeValue(forKey: id)
            for source in prefetchables {
                source.cancelPrefetch(id: id)
            }
        }
    }

    public func reset() {
        for (_, task) in activeTasks {
            task.cancel()
        }
        activeTasks.removeAll()
        prefetchables.removeAll()
    }
}

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
    public func prismPrefetch(
        coordinator: PrismPrefetchCoordinator,
        id: String
    ) -> some View {
        modifier(PrismPrefetchModifier(coordinator: coordinator, id: id))
    }
}
