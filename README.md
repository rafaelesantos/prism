```
Prism
Modular Swift SDK for Apple platforms and servers
```

![Swift](https://img.shields.io/badge/Swift-6.3-orange)
![Platforms](https://img.shields.io/badge/iOS_|_macOS_|_tvOS_|_watchOS_|_visionOS-grey)
![License](https://img.shields.io/github/license/byescaleira/prism)
![CI](https://img.shields.io/github/actions/workflow/status/byescaleira/prism/ci.yml?label=CI)
![Release](https://img.shields.io/github/v/release/byescaleira/prism)
![Coverage](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/byescaleira/prism/main/coverage-badge.json)

---

## Architecture

```
                              Prism                              umbrella
  ┌──────────┬──────────┬────────────┬───────────┬──────────────┐
  │ PrismUI  │  Video   │  Intel.    │  Arch.    │  Capabil.    │  client
  ├──────────┴──────────┴────────────┴───────────┴──────────────┤
  │                    Gamification                              │  engagement
  ├─────────────────────────────────────────────────────────────┤
  │                      Security                                │  security
  ├─────────────────────────────────────────────────────────────┤
  │                      Storage                                 │  persistence
  ├─────────────────────────────────────────────────────────────┤
  │                      Server                                  │  server
  ├─────────────────────────────────────────────────────────────┤
  │                     Network                                  │  transport
  ├─────────────────────────────────────────────────────────────┤
  │                    Foundation                                │  zero-dep core
  └─────────────────────────────────────────────────────────────┘
```

```
Module              Role
──────────────────  ──────────────────────────────────────────
PrismFoundation     Entities, logging, analytics, locale, resources
PrismNetwork        HTTP client, WebSocket, endpoints, cache, retry
PrismArchitecture   Store, reducer, middleware, router (UDF)
PrismUI             80+ components, 4 themes, token-driven design system
PrismVideo          Video download, media entities
PrismIntelligence   CoreML, Apple Intelligence, LLM, RAG, NLP
PrismCapabilities   StoreKit, HealthKit, CloudKit, Camera, NFC
PrismServer         HTTP server, WebSocket, SSE, GraphQL, MCP
PrismGamification   Challenges, streaks, badges, leaderboards, AI
PrismSecurity       Biometrics, keychain, encryption, cert pinning, JWT
PrismStorage        UserDefaults, Disk, Memory, SwiftData, Keychain
PrismPreview        Interactive component catalog
Prism               Umbrella — import Prism gives you everything
```

---

## Quick start

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/byescaleira/prism.git", from: "1.0.0")
]
```

```swift
import Prism
```

Requires Swift 6.3, Xcode 16.4+, iOS 26 / macOS 26 / tvOS 26 / watchOS 26 / visionOS 26.

---

## Development

```
make menu
```

```
  Prism — development toolkit

  Quality
    make format     auto-format sources
    make lint       strict lint check
    make build      build all targets
    make test       run tests + coverage
    make validate   full pipeline (lint > build > test)
    make coverage   generate coverage report
    make clean      remove build artifacts

  GitFlow
    make feature name=xyz       create feature branch
    make release version=1.0.0  create release branch
    make hotfix  version=1.0.1  create hotfix branch
    make finish-release         merge release to main
    make finish-hotfix          merge hotfix to main
```

---

## Testing

```
make test
```

3000+ tests across 250+ suites. Swift Testing framework, strict concurrency.

```
Layer               Coverage
──────────────────  ────────
Foundation          95%+
Network             95%+
Architecture        80%+
Security            95%+
Storage             95%+
Gamification        95%+
Server              80%+
```

---

## CI/CD

```
PR > lint (--strict) > build (-warnings-as-errors) > test (+coverage) > merge
                                                                          |
                                               auto release > tag + changelog
```

---

## Commit convention

```
feat      new feature       minor
feat!     breaking change   major
fix       bug fix           patch
refactor  restructure       patch
test      tests only        —
docs      documentation     —
chore     maintenance       patch
```

---

## Documentation

Full documentation on [Mintlify](https://prism-docs.mintlify.app) — 110+ pages covering every module.

---

```
MIT License
https://github.com/byescaleira
```
