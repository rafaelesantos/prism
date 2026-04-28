# Plugin System

Extend Prism with custom themes, tokens, and components using the plugin architecture.

## Overview

The `PrismPlugin` protocol lets you package design tokens, themes, and components into a reusable unit that can be installed at app launch. This enables design system extensibility without forking.

## Creating a Plugin

Conform to `PrismPlugin` and implement `register(in:)`:

```swift
struct MyBrandPlugin: PrismPlugin {
    let id = "com.myapp.brand"
    let name = "My Brand"

    func register(in registry: PrismPluginRegistry) {
        // Register a custom theme
        let theme = BrandTheme(
            primary: .indigo,
            secondary: .mint,
            accent: .orange
        )
        registry.registerTheme(theme, id: "myBrand")

        // Override specific tokens
        registry.registerColorOverride(.brand, color: .indigo)
        registry.registerSpacingOverride(.md, value: 20)

        // Register custom components
        registry.registerComponent("brandCard") { @MainActor @Sendable in
            AnyView(PrismCard(surface: .surfaceSecondary) {
                Text("Branded Card")
            })
        }
    }
}
```

## Installing Plugins

Install plugins at app launch:

```swift
@main
struct MyApp: App {
    init() {
        PrismPluginRegistry.shared.install(MyBrandPlugin())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .prismPlugin(theme: "myBrand")
        }
    }
}
```

## Using Plugin Components

Retrieve registered components by ID:

```swift
if let card = PrismPluginRegistry.shared.component("brandCard") {
    card
}
```

## Querying the Registry

```swift
let registry = PrismPluginRegistry.shared

// List all installed plugins
for plugin in registry.plugins {
    print("\(plugin.name) v\(plugin.version)")
}

// Check available themes
print(registry.registeredThemeIDs)

// Check token overrides
if let brandColor = registry.colorOverride(for: .brand) {
    // Use the overridden color
}
```

## Best Practices

- Use reverse-DNS notation for plugin IDs (`com.company.feature`)
- Keep plugins focused — one plugin per design concern
- Document which tokens and themes your plugin provides
- Use `version` to track breaking changes in your plugin API
