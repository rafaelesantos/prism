import SwiftUI

public struct PrismStatItem: Sendable, Identifiable {
    public let id = UUID()
    public let label: String
    public let value: String
    public let icon: String?
    public let trend: PrismTrend?

    public init(
        label: String,
        value: String,
        icon: String? = nil,
        trend: PrismTrend? = nil
    ) {
        self.label = label
        self.value = value
        self.icon = icon
        self.trend = trend
    }
}

public struct PrismStatGrid: View {
    @Environment(\.prismTheme) private var theme

    private let items: [PrismStatItem]
    private let minimumColumnWidth: CGFloat

    public init(
        items: [PrismStatItem],
        minimumColumnWidth: CGFloat = 160
    ) {
        self.items = items
        self.minimumColumnWidth = minimumColumnWidth
    }

    public var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: minimumColumnWidth), spacing: SpacingToken.md.rawValue)],
            spacing: SpacingToken.md.rawValue
        ) {
            ForEach(items) { item in
                statCell(item)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Statistics grid")
    }

    private func statCell(_ item: PrismStatItem) -> some View {
        PrismCard {
            VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
                HStack {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .font(.body)
                            .foregroundStyle(theme.color(.brand))
                    }
                    Text(item.label)
                        .font(.caption)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                    Spacer()
                    if let trend = item.trend {
                        Image(systemName: trend.systemImage)
                            .font(.caption2)
                            .foregroundStyle(theme.color(trend.colorToken))
                    }
                }
                Text(item.value)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(theme.color(.onBackground))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.label): \(item.value)")
    }
}
