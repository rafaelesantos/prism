import SwiftUI

/// Convenience for injecting `@Observable` objects into the environment.
extension View {

    /// Injects an `@Observable` model as an environment object.
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public func prismObservable<T: AnyObject & Observable>(_ object: T) -> some View {
        self.environment(object)
    }
}

/// Protocol for view models that integrate with Prism theming.
@MainActor
public protocol PrismViewModel: AnyObject, Observable {
    associatedtype State
    var state: State { get }
}
