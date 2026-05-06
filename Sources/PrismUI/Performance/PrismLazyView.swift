import SwiftUI

public struct PrismLazyView<Content: View>: View {
    @State private var shouldLoad = false

    private let placeholder: AnyView
    private let content: () -> Content

    public init<Placeholder: View>(
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.placeholder = AnyView(placeholder())
        self.content = content
    }

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.placeholder = AnyView(ProgressView())
        self.content = content
    }

    public var body: some View {
        if shouldLoad {
            content()
        } else {
            placeholder
                .onAppear { shouldLoad = true }
        }
    }
}

public struct PrismLazyNavigationDestination<Content: View>: View {
    @State private var shouldLoad = false

    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        if shouldLoad {
            content()
        } else {
            ProgressView()
                .onAppear { shouldLoad = true }
        }
    }
}
