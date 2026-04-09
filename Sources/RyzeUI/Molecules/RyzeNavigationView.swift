//
//  RyzeNavigationView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 05/04/25.
//

import Observation
import RyzeArchitecture
import SwiftUI

public struct RyzeNavigationView<Content: View, Route: RyzeRoutable, Destination: View>: View {
    @Namespace private var transitionNamespace

    @Bindable private var router: RyzeRouter<Route>
    private let content: () -> Content
    private let destination: (Route) -> Destination

    public init(
        router: RyzeRouter<Route>,
        @ViewBuilder destination: @escaping (Route) -> Destination,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.router = router
        self.destination = destination
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .navigationDestination(for: Route.self, destination: pushDestination)
        }
        .sheet(item: $router.presentedRoute, content: modalDestination)
        #if os(iOS)
            .fullScreenCover(item: $router.fullScreenRoute, content: fullScreenDestination)
        #else
            .sheet(item: $router.fullScreenRoute, content: fullScreenDestination)
        #endif
    }

    @ViewBuilder
    func pushDestination(for route: Route) -> some View {
        #if os(iOS)
            destination(route)
                .navigationTransition(.zoom(sourceID: route.id, in: transitionNamespace))
        #else
            destination(route)
        #endif
    }

    @ViewBuilder
    func modalDestination(for route: Route) -> some View {
        destination(route)
    }

    @ViewBuilder
    func fullScreenDestination(for route: Route) -> some View {
        destination(route)
    }
}
