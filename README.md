# Prism

[![CI](https://github.com/rafaelesantos/prism/actions/workflows/ci.yml/badge.svg)](https://github.com/rafaelesantos/prism/actions/workflows/ci.yml)
[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-F05138.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_|_macOS_|_tvOS_|_watchOS-blue.svg)](https://developer.apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modular Swift package for building Apple apps with shared foundation, networking, architecture, adaptive UI, media, and on-device intelligence.

## Modules

| Module | Description |
|--------|-------------|
| **PrismFoundation** | Entities, logging, analytics, locale, resources, defaults, formatting |
| **PrismNetwork** | HTTP client, socket transport, endpoints, caching, FIX protocol |
| **PrismArchitecture** | Router, store, reducer, middleware (unidirectional data flow) |
| **PrismUI** | Design tokens, atoms, molecules, modifiers, accessibility, theming |
| **PrismVideo** | Video download helpers and media entities |
| **PrismIntelligence** | CreateML training, CoreML inference, Apple Intelligence, remote LLM providers |
| **Prism** | Umbrella module that re-exports all of the above |

```
┌─────────────────────────────────────────────┐
│                   Prism                     │
├──────────┬──────────┬───────────┬───────────┤
│ PrismUI  │PrismVideo│PrismIntel.│PrismArch. │
├──────────┴──────────┴───────────┴───────────┤
│              PrismNetwork                   │
├─────────────────────────────────────────────┤
│             PrismFoundation                 │
└─────────────────────────────────────────────┘
```

## Requirements

- Swift 6.3 / Xcode 16.4+
- iOS 26, macOS 26, tvOS 26, watchOS 26

Deployment targets track the latest SDK generation — PrismUI adopts newer SwiftUI APIs like `glassEffect`.

## Installation

**Swift Package Manager:**

```swift
dependencies: [
    .package(url: "https://github.com/rafaelesantos/prism.git", from: "1.0.0")
]
```

Import the umbrella or individual modules:

```swift
import Prism          // everything
import PrismUI        // just the design system
import PrismNetwork   // just networking
```

## Quick Start

### Design System

```swift
PrismButton("Sign In", variant: .primary) {
    await viewModel.signIn()
}
.prism(testID: "sign_in_button")
```

### Analytics (Provider-Agnostic)

```swift
ContentView()
    .prism(analytics: FirebaseAnalytics())

// Components emit events automatically: button_tap, screen_view, field_interaction...
```

### Architecture (Unidirectional Data Flow)

```swift
let store = PrismStore(
    initialState: AppState(),
    reducer: appReducer
)

store.send(.loadData)
```

### Intelligence (Train + Predict)

```swift
// Train from any Codable struct
let training = PrismCodableTrainingData(data: houses)
let result = await training.trainRegressor(
    id: "price",
    name: "House Price",
    target: \.price
)

// Predict
let client = try await PrismIntelligenceClient.local(modelID: "price")
let prediction = try await client.regress(features: ["rooms": .int(3), "area": .double(120)])

// Or use a remote LLM
let remote = PrismIntelligenceClient.remote(
    endpoint: url,
    token: "sk-...",
    model: "gpt-4"
)
let answer = try await remote.generate("Summarize this document.")
```

### Runtime Locale Switching

```swift
@main struct MyApp: App {
    @State private var localeManager = PrismLocaleManager(initial: .englishUS)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .prism(localeManager: localeManager)
        }
    }
}
```

## Prefix Customization

PrismUI ships with `PrismUIPrefixAliases.swift` — copy it into your project and rename the prefix to match your brand:

```swift
public typealias AppButton = PrismButton
public typealias AppText = PrismText
// All Nova* aliases are provided as an example
```

## Development

```bash
make format     # auto-format with swift-format
make lint       # strict lint check
make build      # build all targets including tests
make test       # run tests with coverage
make validate   # format + lint + build + test
make docs       # generate DocC documentation
make docs-serve # generate and serve locally
```

## Quality

- 154 tests across 31 suites
- Strict concurrency: `Sendable`, `@MainActor`, actor isolation
- `swift-format` enforced in CI
- Explicit target dependency import checks
- DocC documentation on all public APIs

## License

MIT — see [LICENSE](LICENSE).
