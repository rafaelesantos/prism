import SwiftUI

public enum PrismFeatureValue: Sendable {
    case check
    case cross
    case text(String)
    case number(Double)
}

public struct PrismComparisonColumn: Sendable, Identifiable {
    public let id = UUID()
    public let header: String
    public let values: [String]

    public init(header: String, values: [String]) {
        self.header = header
        self.values = values
    }
}

public struct PrismComparisonFeature: Sendable, Identifiable {
    public let id = UUID()
    public let name: String
    public let values: [PrismFeatureValue]

    public init(name: String, values: [PrismFeatureValue]) {
        self.name = name
        self.values = values
    }
}

public struct PrismComparisonTable: View {
    @Environment(\.prismTheme) private var theme

    private let columnHeaders: [String]
    private let features: [PrismComparisonFeature]
    private let highlightedColumn: Int?

    public init(
        columnHeaders: [String],
        features: [PrismComparisonFeature],
        highlightedColumn: Int? = nil
    ) {
        self.columnHeaders = columnHeaders
        self.features = features
        self.highlightedColumn = highlightedColumn
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                headerRow
                ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                    featureRow(feature, isEven: index.isMultiple(of: 2))
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Comparison table")
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Feature")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.color(.onBackgroundSecondary))
                .frame(width: 140, alignment: .leading)
                .padding(.horizontal, SpacingToken.sm.rawValue)

            ForEach(Array(columnHeaders.enumerated()), id: \.offset) { index, header in
                Text(header)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(
                        index == highlightedColumn
                            ? theme.color(.brand)
                            : theme.color(.onBackground)
                    )
                    .frame(width: 120)
                    .padding(.vertical, SpacingToken.sm.rawValue)
                    .background(
                        index == highlightedColumn
                            ? theme.color(.brand).opacity(0.08)
                            : Color.clear
                    )
            }
        }
        .padding(.vertical, SpacingToken.sm.rawValue)
        .background(theme.color(.surfaceSecondary))
    }

    // MARK: - Feature Rows

    private func featureRow(_ feature: PrismComparisonFeature, isEven: Bool) -> some View {
        HStack(spacing: 0) {
            Text(feature.name)
                .font(.subheadline)
                .foregroundStyle(theme.color(.onBackground))
                .frame(width: 140, alignment: .leading)
                .padding(.horizontal, SpacingToken.sm.rawValue)

            ForEach(Array(feature.values.enumerated()), id: \.offset) { index, value in
                featureValueView(value)
                    .frame(width: 120)
                    .padding(.vertical, SpacingToken.xs.rawValue)
                    .background(
                        index == highlightedColumn
                            ? theme.color(.brand).opacity(0.04)
                            : Color.clear
                    )
            }
        }
        .padding(.vertical, SpacingToken.xs.rawValue)
        .background(isEven ? theme.color(.surface) : Color.clear)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(featureAccessibilityLabel(feature))
    }

    @ViewBuilder
    private func featureValueView(_ value: PrismFeatureValue) -> some View {
        switch value {
        case .check:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(theme.color(.success))
                .font(.body)
        case .cross:
            Image(systemName: "xmark.circle")
                .foregroundStyle(theme.color(.onBackgroundTertiary))
                .font(.body)
        case .text(let text):
            Text(text)
                .font(.subheadline)
                .foregroundStyle(theme.color(.onBackground))
        case .number(let number):
            Text(String(format: "%.0f", number))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.color(.onBackground))
        }
    }

    private func featureAccessibilityLabel(_ feature: PrismComparisonFeature) -> String {
        var parts = [feature.name]
        for (index, value) in feature.values.enumerated() {
            let header = index < columnHeaders.count ? columnHeaders[index] : "Column \(index + 1)"
            switch value {
            case .check: parts.append("\(header): yes")
            case .cross: parts.append("\(header): no")
            case .text(let text): parts.append("\(header): \(text)")
            case .number(let number): parts.append("\(header): \(String(format: "%.0f", number))")
            }
        }
        return parts.joined(separator: ", ")
    }
}
