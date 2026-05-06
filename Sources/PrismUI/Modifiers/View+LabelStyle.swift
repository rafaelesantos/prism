import SwiftUI

public enum PrismLabelStyle: Sendable {
    case automatic
    case iconOnly
    case titleOnly
    case titleAndIcon
}

extension View {

    @ViewBuilder
    public func prismLabelStyle(_ style: PrismLabelStyle) -> some View {
        switch style {
        case .automatic:
            self.labelStyle(.automatic)
        case .iconOnly:
            self.labelStyle(.iconOnly)
        case .titleOnly:
            self.labelStyle(.titleOnly)
        case .titleAndIcon:
            self.labelStyle(.titleAndIcon)
        }
    }
}
