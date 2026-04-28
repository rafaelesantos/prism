# Architecture & Ecosystem

Understand Prism's module structure and how to use only what you need.

## Overview

Prism is organized as a modular monorepo. Each module has a clear responsibility and minimal dependencies. You can import only the modules you need.

## Module Graph

```
┌─────────────────────────────────────────────────┐
│                    Prism                        │  ← umbrella
├──────────┬──────────┬───────────┬───────────────┤
│ PrismUI  │PrismVideo│PrismIntel.│PrismArchitect.│  ← feature
├──────────┴──────────┴───────────┴───────────────┤
│                PrismNetwork                     │  ← transport
├─────────────────────────────────────────────────┤
│               PrismFoundation                   │  ← core
└─────────────────────────────────────────────────┘
```

## Module Responsibilities

| Module | Depends On | Purpose |
|--------|-----------|---------|
| `PrismFoundation` | — | Entities, logging, analytics, locale, resources |
| `PrismNetwork` | PrismFoundation | HTTP client, WebSocket, caching, FIX protocol |
| `PrismArchitecture` | PrismFoundation | Store, Reducer, Middleware, Router |
| `PrismUI` | PrismFoundation | Design system: 100+ components, tokens, themes |
| `PrismVideo` | PrismFoundation, PrismNetwork | Video download, media entities |
| `PrismIntelligence` | PrismFoundation | CoreML, CreateML, Apple Intelligence |
| `Prism` | All | Umbrella re-export |

## Selective Import

Import only what you need:

```swift
import PrismUI          // Design system only
import PrismNetwork     // Networking only
import PrismArchitecture // State management only
import Prism            // Everything
```

## PrismUI Internal Structure

PrismUI organizes its 100+ components into clear directories:

| Directory | Contents |
|-----------|----------|
| `Tokens/` | ColorToken, TypographyToken, SpacingToken, etc. |
| `Theme/` | PrismTheme protocol, DefaultTheme, BrandTheme, etc. |
| `Primitives/` | Button, Card, Tag, Avatar, TextField, etc. |
| `Composites/` | SearchBar, Banner, BottomSheet, Carousel, etc. |
| `Forms/` | Toggle, Picker, Slider, DatePicker, etc. |
| `Layout/` | AdaptiveStack, Grid, Section, Scaffold |
| `Navigation/` | NavigationView, TabView, SplitView, Settings |
| `Modifiers/` | Typography, spacing, elevation, animation modifiers |
| `Animation/` | Spring configs, keyframes, gesture animations |
| `Plugin/` | Plugin protocol and registry |
| `Export/` | Figma sync, token export |
| `Testing/` | Preview catalog, storybook, benchmarks |
| `Accessibility/` | A11y modifiers, audit tools |
| `Charts/` | Bar, Line, Donut charts |
| `Widgets/` | WidgetKit components |

## Design Token Flow

```
PrismTheme (protocol)
    │
    ├── DefaultTheme
    ├── DarkTheme
    ├── HighContrastTheme
    └── BrandTheme(primary, secondary, accent)
           │
           ▼
    ColorToken.brand → resolves to → Color
    SpacingToken.md  → resolves to → CGFloat
    RadiusToken.lg   → resolves to → Shape
    MotionToken.fast → resolves to → Animation
```

## When to Split

The monorepo approach works well when:
- A single team owns the design system
- All modules share the same release cadence
- Cross-module integration is frequent

Consider splitting if:
- Different teams own different modules
- You need independent versioning
- Binary size of unused modules matters for your app
