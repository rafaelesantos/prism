import SwiftUI

public struct PrismReadReceipt: Identifiable, Sendable, Equatable {
    public let userId: String
    public let name: String
    public let readAt: Date

    public var id: String { userId }

    public init(userId: String, name: String, readAt: Date = .now) {
        self.userId = userId
        self.name = name
        self.readAt = readAt
    }
}

@MainActor
public struct PrismReadReceiptIndicator: View {
    @Environment(\.prismTheme) private var theme

    private let status: PrismMessageStatus

    public init(status: PrismMessageStatus) {
        self.status = status
    }

    public var body: some View {
        Group {
            switch status {
            case .sending:
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundStyle(theme.color(.onSurfaceSecondary))
            case .sent:
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(theme.color(.onSurfaceSecondary))
            case .delivered:
                doubleCheck(color: theme.color(.onSurfaceSecondary))
            case .read:
                doubleCheck(color: theme.color(.brand))
            case .failed:
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(theme.color(.error))
            }
        }
        .accessibilityLabel(status.rawValue)
    }

    private func doubleCheck(color: Color) -> some View {
        HStack(spacing: -4) {
            Image(systemName: "checkmark")
            Image(systemName: "checkmark")
        }
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(color)
    }
}

@MainActor
public struct PrismReadReceiptList: View {
    @Environment(\.prismTheme) private var theme

    private let receipts: [PrismReadReceipt]

    @State private var isExpanded = false

    public init(receipts: [PrismReadReceipt]) {
        self.receipts = receipts
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: SpacingToken.xs.rawValue) {
                    Image(systemName: "eye")
                        .font(.system(size: 12))
                    Text("Read by \(receipts.count)")
                        .font(TypographyToken.caption.font(weight: .medium))
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundStyle(theme.color(.onSurfaceSecondary))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Read by \(receipts.count) people, \(isExpanded ? "collapse" : "expand")")

            if isExpanded {
                VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
                    ForEach(receipts) { receipt in
                        HStack(spacing: SpacingToken.sm.rawValue) {
                            Text(receipt.name)
                                .font(TypographyToken.caption.font)
                                .foregroundStyle(theme.color(.onSurface))

                            Spacer()

                            Text(receipt.readAt, style: .time)
                                .font(TypographyToken.caption2.font)
                                .foregroundStyle(theme.color(.onSurfaceSecondary))
                        }
                    }
                }
                .padding(.leading, SpacingToken.md.rawValue)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .accessibilityElement(children: .contain)
    }
}
