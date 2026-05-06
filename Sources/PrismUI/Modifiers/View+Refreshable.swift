import SwiftUI

extension View {

    public func prismRefreshable(action: @escaping @Sendable () async -> Void) -> some View {
        refreshable(action: action)
    }
}
