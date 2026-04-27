# Changelog

All notable changes to Prism will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Baseline project tooling with `swift format`, quality scripts, CI, contribution docs, and security guidance.
- 134 tests across 29 suites covering all 6 modules (PrismFoundation, PrismArchitecture, PrismNetwork, PrismUI, PrismVideo, PrismIntelligence).
- DocC documentation on ~516 public declarations with parameter/return/throws annotations.
- Thread-safety documentation on all 7 `@unchecked Sendable` types.
- `PrismVideoTests` test target for video entity, resolution, error, and downloader types.

### Changed

- Package manifest updated for Swift 6.3 and an explicit Swift 6 language mode baseline.
- Public products clarified around the `Prism` umbrella module and focused domain modules.
- All documentation comments standardized to English across all modules.
- `PrismRouter.present(_:)` and `fullScreen(_:)` now enforce mutual exclusivity to match SwiftUI semantics.
- `PrismDefaults.userDefaults` changed from `var` to `let` for immutability after initialization.

### Fixed

- `PrismVideoEntity.id` was a computed property generating a new UUID on every access; changed to a stored `let` property.
- `PrismStore.send(_:)` replaced force-unwrap of optional reducer with safe `guard let`.
- `PrismVideoResolution` now conforms to `Sendable` to satisfy `PrismVideoEntity: Sendable`.
- Pre-existing test bug comparing `"Prism".dropFirst()` hash with incorrect expected value.
