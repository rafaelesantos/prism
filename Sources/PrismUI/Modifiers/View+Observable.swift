import SwiftUI

extension View {

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public func prismObservable<T: AnyObject & Observable>(_ object: T) -> some View {
        self.environment(object)
    }
}

@MainActor
public protocol PrismViewModel: AnyObject, Observable {
    associatedtype State
    var state: State { get }
}
