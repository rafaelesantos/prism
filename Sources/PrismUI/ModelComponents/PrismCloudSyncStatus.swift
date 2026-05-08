#if canImport(SwiftData)
    import PrismStorage
    import SwiftUI

    public struct PrismSyncStatusView: View {
        @Environment(\.prismTheme) private var theme

        private let monitor: PrismCloudSyncMonitor

        public init(monitor: PrismCloudSyncMonitor) {
            self.monitor = monitor
        }

        public var body: some View {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                    .imageScale(.small)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(theme.color(.onBackgroundSecondary))
            }
            .accessibilityLabel("Sync status: \(statusText)")
        }

        private var iconName: String {
            switch monitor.state {
            case .idle: "cloud"
            case .syncing: "arrow.triangle.2.circlepath"
            case .synced: "checkmark.icloud"
            case .error: "exclamationmark.icloud"
            }
        }

        private var iconColor: Color {
            switch monitor.state {
            case .idle: theme.color(.onBackgroundSecondary)
            case .syncing: theme.color(.brand)
            case .synced: theme.color(.success)
            case .error: theme.color(.error)
            }
        }

        private var statusText: String {
            switch monitor.state {
            case .idle: "Idle"
            case .syncing: "Syncing..."
            case .synced: "Synced"
            case .error(let message): "Error: \(message)"
            }
        }
    }

    public struct PrismSyncStatusModifier: ViewModifier {
        let monitor: PrismCloudSyncMonitor

        public func body(content: Content) -> some View {
            content
                .overlay(alignment: .topTrailing) {
                    PrismSyncStatusView(monitor: monitor)
                        .padding(8)
                }
        }
    }

    extension View {
        public func prismSyncStatus(monitor: PrismCloudSyncMonitor) -> some View {
            modifier(PrismSyncStatusModifier(monitor: monitor))
        }
    }
#endif
