import SwiftUI

#if os(macOS)
    public struct PrismMenuBarContent<Content: View>: View {
        @Environment(\.prismTheme) private var theme

        private let content: Content

        public init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        public var body: some View {
            VStack(spacing: 0) {
                content
            }
            .frame(minWidth: 200)
        }
    }

    public struct PrismMenuBarButton: View {
        @Environment(\.prismTheme) private var theme

        private let title: LocalizedStringKey
        private let icon: String?
        private let action: () -> Void

        public init(
            _ title: LocalizedStringKey,
            systemImage icon: String? = nil,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.icon = icon
            self.action = action
        }

        public var body: some View {
            Button(action: action) {
                if let icon {
                    Label(title, systemImage: icon)
                } else {
                    Text(title)
                }
            }
            .foregroundStyle(theme.color(.onBackground))
        }
    }
#endif
