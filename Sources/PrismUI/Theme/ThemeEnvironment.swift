import SwiftUI

// MARK: - Environment Key

private struct PrismThemeKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: any PrismTheme = DefaultTheme()
}

extension EnvironmentValues {
    public var prismTheme: any PrismTheme {
        get { self[PrismThemeKey.self] }
        set { self[PrismThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {

    public func prismTheme(_ theme: some PrismTheme) -> some View {
        environment(\.prismTheme, theme)
    }
}
