import SwiftUI

public struct PrismSettingsView<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        Form {
            content
        }
        .formStyle(.grouped)
        .background(theme.color(.background))
    }
}

public struct PrismSettingsSection<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let footer: LocalizedStringKey?
    private let content: Content

    public init(
        _ title: LocalizedStringKey,
        footer: LocalizedStringKey? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    public var body: some View {
        if let footer {
            Section {
                content
            } header: {
                Text(title)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            } footer: {
                Text(footer)
                    .foregroundStyle(theme.color(.onBackgroundTertiary))
            }
        } else {
            Section {
                content
            } header: {
                Text(title)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
        }
    }
}

extension View {

    #if os(iOS) || os(visionOS)
        public func prismOpenSettings() -> some View {
            self.environment(
                \.openURL,
                OpenURLAction { url in
                    return .systemAction
                })
        }
    #endif
}
