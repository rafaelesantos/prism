import SwiftUI

public protocol PrismLiveReloadable: AnyObject, Sendable {
    @MainActor func reload()
}

@Observable
@MainActor
public final class PrismLiveReloadServer {
    public private(set) var isConnected: Bool = false
    public private(set) var lastReloadDate: Date?

    private var reloadables: [any PrismLiveReloadable] = []

    public init() {}

    public func register(_ reloadable: any PrismLiveReloadable) {
        reloadables.append(reloadable)
        isConnected = true
    }

    public func triggerReload() {
        for reloadable in reloadables {
            reloadable.reload()
        }
        lastReloadDate = Date()
    }

    public func disconnect() {
        reloadables.removeAll()
        isConnected = false
    }
}

// MARK: - Status Banner

public struct PrismLiveReloadBanner: View {
    let server: PrismLiveReloadServer

    public init(server: PrismLiveReloadServer) {
        self.server = server
    }

    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            Circle()
                .fill(server.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)

            Text(server.isConnected ? "Live Reload Connected" : "Live Reload Disconnected")
                .font(TypographyToken.caption.font)
                .foregroundStyle(server.isConnected ? .primary : .secondary)

            if let date = server.lastReloadDate {
                Spacer()
                Text(date, style: .time)
                    .font(TypographyToken.caption2.font)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, SpacingToken.md.rawValue)
        .padding(.vertical, SpacingToken.xs.rawValue)
        .background(.ultraThinMaterial)
        .clipShape(RadiusToken.sm.shape)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            server.isConnected ? "Live reload connected" : "Live reload disconnected"
        )
    }
}
