import SwiftUI
import os

public struct PrismAccessibilityAudit: ViewModifier {
    private static let logger = Logger(
        subsystem: "com.prism.ui",
        category: "accessibility-audit"
    )

    private let context: String

    public init(context: String = "") {
        self.context = context
    }

    public func body(content: Content) -> some View {
        #if DEBUG
            content.onAppear {
                Self.logger.debug("♿ Accessibility audit active: \(context.isEmpty ? "unnamed view" : context)")
            }
        #else
            content
        #endif
    }
}

extension View {

    public func prismAccessibilityAudit(_ context: String = "") -> some View {
        modifier(PrismAccessibilityAudit(context: context))
    }
}
