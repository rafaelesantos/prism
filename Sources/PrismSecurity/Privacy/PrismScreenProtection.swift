#if canImport(SwiftUI)
    import SwiftUI

    public struct PrismScreenProtectionModifier: ViewModifier {
        @Environment(\.scenePhase) private var scenePhase
        @State private var isProtected = false

        public func body(content: Content) -> some View {
            content
                .overlay {
                    if isProtected {
                        ProtectedOverlay()
                    }
                }
                .onChange(of: scenePhase) { _, newPhase in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isProtected = newPhase != .active
                    }
                }
        }
    }

    private struct ProtectedOverlay: View {
        var body: some View {
            ZStack {
                Color(.init(white: 0.98, alpha: 1.0))
                    .ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Content Protected")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .transition(.opacity)
        }
    }

    extension View {
        public func prismScreenProtection() -> some View {
            modifier(PrismScreenProtectionModifier())
        }
    }

    public struct PrismSecureView<Content: View>: View {
        private let content: Content

        public init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        public var body: some View {
            content
                .prismScreenProtection()
        }
    }
#endif
