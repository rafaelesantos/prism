# Migration Guide

Migrate from raw SwiftUI to PrismUI's token-driven design system.

## Overview

This guide walks through adopting PrismUI in an existing project — replacing hardcoded values with tokens, wrapping views with themed components, and setting up the theme environment.

## Step 1: Add the Package

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/rafaelesantos/prism.git", from: "1.0.0")
]

// Target
.target(name: "MyApp", dependencies: ["PrismUI"])
```

## Step 2: Set Up the Theme

Apply a theme at the root of your app:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .prismTheme(DefaultTheme())
        }
    }
}
```

For custom branding:

```swift
let theme = BrandTheme(primary: .indigo, secondary: .mint, accent: .orange)
ContentView().prismTheme(theme)
```

## Step 3: Replace Hardcoded Values

### Colors

```swift
// Before
Text("Hello").foregroundColor(.blue)

// After
Text("Hello").prismColor(.interactive)
```

### Typography

```swift
// Before
Text("Title").font(.title)

// After
Text("Title").prismFont(.title)
```

### Spacing

```swift
// Before
VStack(spacing: 16) { ... }

// After
VStack(spacing: SpacingToken.lg.rawValue) { ... }
```

### Corner Radius

```swift
// Before
RoundedRectangle(cornerRadius: 12)

// After
RadiusToken.lg.shape
```

## Step 4: Adopt Components

Replace standard SwiftUI views with Prism equivalents:

```swift
// Before
Button("Sign In") { signIn() }
    .buttonStyle(.borderedProminent)

// After
PrismButton("Sign In", variant: .filled) {
    await signIn()
}
```

```swift
// Before
TextField("Email", text: $email)

// After
PrismTextField("Email", text: $email, validation: .pattern(
    "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
    "Invalid email"
))
```

## Step 5: Verify Accessibility

Use the built-in audit tools:

```swift
#if DEBUG
PrismAccessibilityAudit()
#endif
```

Test across themes and dynamic type sizes using `PrismPreviewCatalog`:

```swift
#Preview {
    PrismPreviewCatalog {
        MyView()
    }
}
```
