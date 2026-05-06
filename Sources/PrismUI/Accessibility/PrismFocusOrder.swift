import SwiftUI

public struct PrismFocusOrderItem: Sendable, Hashable, Identifiable {
    public let id: String
    public let label: String
    public let priority: Int

    public init(id: String, label: String, priority: Int) {
        self.id = id
        self.label = label
        self.priority = priority
    }
}

public struct PrismFocusOrderValidationResult: Sendable, Hashable {
    public let isValid: Bool
    public let warnings: [String]

    public init(isValid: Bool, warnings: [String]) {
        self.isValid = isValid
        self.warnings = warnings
    }
}

public struct PrismFocusOrderValidator: Sendable {

    public static func validate(_ items: [PrismFocusOrderItem]) -> PrismFocusOrderValidationResult {
        var warnings: [String] = []
        for i in 0..<items.count - 1 where items[i].priority < items[i + 1].priority {
            warnings.append(
                "'\(items[i].label)' (priority \(items[i].priority)) should come after '\(items[i + 1].label)' (priority \(items[i + 1].priority))"
            )
        }
        return PrismFocusOrderValidationResult(isValid: warnings.isEmpty, warnings: warnings)
    }
}

private struct FocusOrderModifier: ViewModifier {
    let priority: Double
    let label: String

    func body(content: Content) -> some View {
        content
            .accessibilityAddTraits(.isStaticText)
            .accessibilitySortPriority(priority)
            .accessibilityLabel(Text(label))
    }
}

extension View {

    public func prismFocusOrder(priority: Int, label: String) -> some View {
        modifier(FocusOrderModifier(priority: Double(priority), label: label))
    }
}
