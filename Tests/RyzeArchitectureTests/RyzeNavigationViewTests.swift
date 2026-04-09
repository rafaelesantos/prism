import RyzeArchitecture
import SwiftUI
import Testing

@testable import RyzeUI

@MainActor
struct RyzeNavigationViewTests {
    @Test
    func navigationViewBuildsBodyAndDestinations() {
        let router = RyzeRouter<SampleRoute>()
        let view = RyzeNavigationView(
            router: router,
            destination: { route in
                Text(String(describing: route))
            },
            content: {
                Text("Root")
            }
        )

        _ = view.body
        _ = view.pushDestination(for: .home)
        _ = view.modalDestination(for: .modal)
        _ = view.fullScreenDestination(for: .fullScreen)
    }
}
