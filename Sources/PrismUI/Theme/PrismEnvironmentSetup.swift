import SwiftUI

private struct PrismEnvironmentModifier<T: PrismTheme>: ViewModifier {
    let theme: T
    let colorScheme: ColorScheme?

    func body(content: Content) -> some View {
        if let colorScheme {
            content
                .prismTheme(theme)
                .preferredColorScheme(colorScheme)
        } else {
            content
                .prismTheme(theme)
        }
    }
}

extension View {

    @ViewBuilder
    public func prismEnvironment<T: PrismTheme>(
        theme: T,
        colorScheme: ColorScheme? = nil
    ) -> some View {
        if let colorScheme {
            self
                .prismTheme(theme)
                .preferredColorScheme(colorScheme)
        } else {
            self
                .prismTheme(theme)
        }
    }
}
