import SwiftUI

/// Toolbar placement presets.
public enum PrismToolbarPlacement: Sendable {
    case leading
    case trailing
    case principal
    case primaryAction
    case secondaryAction
    case navigation
    case status

    var placement: ToolbarItemPlacement {
        switch self {
        case .leading: .navigation
        case .trailing: .primaryAction
        case .principal: .principal
        case .primaryAction: .primaryAction
        case .secondaryAction: .secondaryAction
        case .navigation: .navigation
        case .status: .status
        }
    }
}

/// Themed toolbar button.
public struct PrismToolbarButton: View {
    @Environment(\.prismTheme) private var theme

    private let title: LocalizedStringKey
    private let icon: String
    private let action: () -> Void

    public init(
        _ title: LocalizedStringKey,
        systemImage icon: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
        .foregroundStyle(theme.color(.interactive))
    }
}

/// Toolbar menu with themed styling.
public struct PrismToolbarMenu<Content: View>: View {
    @Environment(\.prismTheme) private var theme

    private let icon: String
    private let content: Content

    public init(
        systemImage icon: String = "ellipsis.circle",
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.content = content()
    }

    public var body: some View {
        Menu {
            content
        } label: {
            Image(systemName: icon)
                .foregroundStyle(theme.color(.interactive))
        }
    }
}
