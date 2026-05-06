import SwiftUI

#if os(macOS)
    public struct PrismTable<Value: Identifiable, Content: View>: View {
        @Environment(\.prismTheme) private var theme

        private let data: [Value]
        private let content: ([Value]) -> Content

        public init(
            _ data: [Value],
            @ViewBuilder content: @escaping ([Value]) -> Content
        ) {
            self.data = data
            self.content = content
        }

        public var body: some View {
            content(data)
                .foregroundStyle(theme.color(.onBackground))
                .accessibilityElement(children: .contain)
        }
    }
#endif
