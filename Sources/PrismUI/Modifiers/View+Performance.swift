import SwiftUI
import os.log

private let performanceLog = Logger(subsystem: "PrismUI", category: "Performance")

private struct PrismLazyModifier<Placeholder: View>: ViewModifier {
    @State private var isVisible = false
    let placeholder: Placeholder

    func body(content: Content) -> some View {
        if isVisible {
            content
        } else {
            placeholder
                .onAppear { isVisible = true }
        }
    }
}

private struct PrismBodyCountModifier: ViewModifier {
    let label: String
    @State private var count = 0

    func body(content: Content) -> some View {
        #if DEBUG
            let _ = {
                count += 1
                performanceLog.debug("\(label) body evaluated \(count) time(s)")
            }()
        #endif
        content
    }
}

extension View {

    public func prismLazy<Placeholder: View>(
        @ViewBuilder placeholder: () -> Placeholder = { ProgressView() }
    ) -> some View {
        modifier(PrismLazyModifier(placeholder: placeholder()))
    }

    public func prismBodyCount(_ label: String) -> some View {
        modifier(PrismBodyCountModifier(label: label))
    }
}
