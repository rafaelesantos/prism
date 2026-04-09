# Adaptive UI Guidelines

RyzeUI should feel consistent across Apple platforms without pretending every platform behaves the same.

## Principles

- One design language, native interaction patterns
- Shared tokens for color, spacing, radius, and size
- Platform-aware wrappers when UIKit and AppKit diverge
- Respect focus, pointer, keyboard, touch, remote, and watch input models

## Implementation Direction

- Use SwiftUI first
- Add platform-specific adapters only when behavior or APIs truly diverge
- Prefer environment-driven theming and platform capability checks
- Keep component APIs stable while adapting internals per OS

## Platform Notes

- iOS and Mac Catalyst should prioritize touch plus pointer-friendly ergonomics
- macOS should feel native with keyboard, menu, and window behavior
- tvOS should optimize for focus and remote navigation
- watchOS should keep density, motion, and interaction lightweight

## Review Checklist

- Does the component degrade gracefully on every supported Apple OS?
- Does it respect the correct interaction model for each platform?
- Is the design token-driven instead of hardcoded for one screen class?
- Is the public API platform-agnostic where possible?
