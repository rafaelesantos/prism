import SwiftUI

/// Convenience modifier that injects all Prism environment values in one call.
///
/// ```swift
/// ContentView()
///     .prismEnvironment(theme: DefaultTheme())
/// ```
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

    /// Injects theme and optional color scheme override.
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
