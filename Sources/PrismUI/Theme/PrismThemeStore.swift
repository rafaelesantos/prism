import SwiftUI

@MainActor
public final class PrismThemeStore: ObservableObject {
    @AppStorage("prism.theme.identifier") private var themeIdentifier: String = "default"
    @Published public private(set) var currentTheme: any PrismTheme

    private var registry: [String: any PrismTheme]

    public init(
        customThemes: [String: any PrismTheme] = [:]
    ) {
        var reg: [String: any PrismTheme] = [
            "default": DefaultTheme(),
            "dark": DarkTheme(),
            "highContrast": HighContrastTheme(),
        ]
        for (key, theme) in customThemes {
            reg[key] = theme
        }
        self.registry = reg
        self.currentTheme = reg["default"]!
        self.currentTheme = registry[themeIdentifier] ?? registry["default"]!
    }

    public var availableThemes: [String] {
        Array(registry.keys).sorted()
    }

    public func setTheme(_ identifier: String, animated: Bool = true) {
        guard let theme = registry[identifier] else { return }
        themeIdentifier = identifier
        if animated {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentTheme = theme
            }
        } else {
            currentTheme = theme
        }
    }

    public func register(_ identifier: String, theme: some PrismTheme) {
        registry[identifier] = theme
    }

    public var currentIdentifier: String {
        themeIdentifier
    }
}

private struct PrismThemeStoreModifier: ViewModifier {
    @ObservedObject var store: PrismThemeStore

    func body(content: Content) -> some View {
        content
            .environment(\.prismTheme, store.currentTheme)
    }
}

extension View {

    public func prismThemeStore(_ store: PrismThemeStore) -> some View {
        modifier(PrismThemeStoreModifier(store: store))
    }
}
