import SwiftUI

private struct VoiceControlLabelModifier: ViewModifier {
    let label: String

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(Text(label))
            .accessibilityInputLabels([Text(label)])
    }
}

private struct VoiceControlHintModifier: ViewModifier {
    let hint: String

    func body(content: Content) -> some View {
        content
            .accessibilityHint(Text(hint))
    }
}

extension View {

    public func prismVoiceControlLabel(_ label: String) -> some View {
        modifier(VoiceControlLabelModifier(label: label))
    }

    public func prismVoiceControlHint(_ hint: String) -> some View {
        modifier(VoiceControlHintModifier(hint: hint))
    }
}

public struct PrismVoiceControlGroup<Content: View>: View {
    private let label: String
    private let content: Content

    public init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    public var body: some View {
        Group {
            content
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(label))
    }
}
