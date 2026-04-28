import SwiftUI

/// Extension point for registering custom tokens, components, and themes.
///
/// ```swift
/// struct MyPlugin: PrismPlugin {
///     let id = "com.myapp.brand"
///     let name = "My Brand Plugin"
///
///     func register(in registry: PrismPluginRegistry) {
///         registry.registerTheme(MyCustomTheme(), id: "myTheme")
///         registry.registerColorOverride(.brand, color: .indigo)
///     }
/// }
///
/// // At app launch:
/// PrismPluginRegistry.shared.install(MyPlugin())
/// ```
@MainActor
public protocol PrismPlugin: Sendable {
    var id: String { get }
    var name: String { get }
    var version: String { get }
    func register(in registry: PrismPluginRegistry)
}

extension PrismPlugin {
    public var version: String { "1.0.0" }
}

/// Central registry for installed plugins.
@MainActor
public final class PrismPluginRegistry: @unchecked Sendable {
    public static let shared = PrismPluginRegistry()

    private var installedPlugins: [String: any PrismPlugin] = [:]
    private var themeOverrides: [String: any PrismTheme] = [:]
    private var colorOverrides: [ColorToken: Color] = [:]
    private var spacingOverrides: [SpacingToken: CGFloat] = [:]
    private var radiusOverrides: [RadiusToken: CGFloat] = [:]
    private var componentFactories: [String: @MainActor @Sendable () -> AnyView] = [:]

    private init() {}

    // MARK: - Plugin Lifecycle

    public func install(_ plugin: some PrismPlugin) {
        guard installedPlugins[plugin.id] == nil else { return }
        installedPlugins[plugin.id] = plugin
        plugin.register(in: self)
    }

    public func uninstall(pluginID: String) {
        installedPlugins.removeValue(forKey: pluginID)
    }

    public var plugins: [any PrismPlugin] {
        Array(installedPlugins.values)
    }

    public func isInstalled(_ pluginID: String) -> Bool {
        installedPlugins[pluginID] != nil
    }

    // MARK: - Theme Registration

    public func registerTheme(_ theme: some PrismTheme, id: String) {
        themeOverrides[id] = theme
    }

    public func theme(id: String) -> (any PrismTheme)? {
        themeOverrides[id]
    }

    public var registeredThemeIDs: [String] {
        Array(themeOverrides.keys.sorted())
    }

    // MARK: - Token Overrides

    public func registerColorOverride(_ token: ColorToken, color: Color) {
        colorOverrides[token] = color
    }

    public func colorOverride(for token: ColorToken) -> Color? {
        colorOverrides[token]
    }

    public func registerSpacingOverride(_ token: SpacingToken, value: CGFloat) {
        spacingOverrides[token] = value
    }

    public func spacingOverride(for token: SpacingToken) -> CGFloat? {
        spacingOverrides[token]
    }

    public func registerRadiusOverride(_ token: RadiusToken, value: CGFloat) {
        radiusOverrides[token] = value
    }

    public func radiusOverride(for token: RadiusToken) -> CGFloat? {
        radiusOverrides[token]
    }

    // MARK: - Component Factory

    public func registerComponent(
        _ id: String,
        factory: @MainActor @Sendable @escaping () -> AnyView
    ) {
        componentFactories[id] = factory
    }

    public func component(_ id: String) -> AnyView? {
        componentFactories[id]?()
    }

    public var registeredComponentIDs: [String] {
        Array(componentFactories.keys.sorted())
    }

    // MARK: - Reset

    public func reset() {
        installedPlugins.removeAll()
        themeOverrides.removeAll()
        colorOverrides.removeAll()
        spacingOverrides.removeAll()
        radiusOverrides.removeAll()
        componentFactories.removeAll()
    }
}

/// View modifier that applies plugin overrides to the environment.
private struct PrismPluginModifier: ViewModifier {
    let registry: PrismPluginRegistry
    let themeID: String?

    func body(content: Content) -> some View {
        if let themeID, let theme = registry.theme(id: themeID) {
            content.environment(\.prismTheme, theme)
        } else {
            content
        }
    }
}

extension View {

    /// Applies a plugin-registered theme by ID.
    @MainActor
    public func prismPlugin(
        theme themeID: String,
        registry: PrismPluginRegistry = .shared
    ) -> some View {
        modifier(PrismPluginModifier(registry: registry, themeID: themeID))
    }
}
