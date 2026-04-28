import SwiftUI

/// Type-safe navigation path wrapper with convenience push/pop.
///
/// ```swift
/// @State private var path = PrismNavigationPath<Route>()
///
/// NavigationStack(path: $path.raw) {
///     content
///         .navigationDestination(for: Route.self) { route in ... }
/// }
///
/// path.push(.detail(id: 42))
/// path.pop()
/// path.popToRoot()
/// ```
@MainActor
@Observable
public final class PrismNavigationPath<Route: Hashable>: @unchecked Sendable {
    public var raw: [Route] = []

    public init(_ initial: [Route] = []) {
        self.raw = initial
    }

    public var count: Int { raw.count }
    public var isEmpty: Bool { raw.isEmpty }
    public var current: Route? { raw.last }

    public func push(_ route: Route) {
        raw.append(route)
    }

    public func pop() {
        guard !raw.isEmpty else { return }
        raw.removeLast()
    }

    public func popToRoot() {
        raw.removeAll()
    }

    public func replace(with routes: [Route]) {
        raw = routes
    }
}
