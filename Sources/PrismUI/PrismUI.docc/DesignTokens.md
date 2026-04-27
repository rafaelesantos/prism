# DesignTokens

Sistema de tokens de design: espaçamento, raios, fontes, animações e breakpoints.

## Visão Geral

``PrismDesignTokens`` centraliza todos os valores visuais do design system em um único lugar. Tokens garantem consistência entre componentes e permitem adaptação automática por plataforma e classe de tamanho.

### Estrutura dos Tokens

| Categoria | Tipo | Exemplos |
|-----------|------|----------|
| Spacing | `SpacingToken` | `.none`, `.small`, `.medium`, `.large`, `.section` |
| Radius | `RadiusToken` | `.none`, `.small`, `.medium`, `.large`, `.circle` |
| Font Size | `FontSizeToken` | `.caption2`, `.body`, `.title`, `.largeTitle` |
| Motion | `MotionToken` | `.instant`, `.fast`, `.normal`, `.slow` |
| Breakpoint | `Breakpoint` | `.phoneCompact`, `.tabletMax`, `.desktop` |

### Variantes Pré-definidas

```swift
// Padrão — balanceado para a maioria das plataformas
PrismDesignTokens.default

// Compact — mais denso, para iPhones e Apple Watch
PrismDesignTokens.compact

// Expanded — mais espaçoso, para iPad e Mac
PrismDesignTokens.expanded
```

### Uso Programático

```swift
let tokens = PrismDesignTokens.default

tokens.spacing(for: .medium)    // 16pt
tokens.radius(for: .large)      // 16pt
tokens.fontSize(for: .title)    // 28pt
tokens.duration(for: .normal)   // 0.35s
tokens.animation(for: .fast)    // .easeInOut(duration: 0.2)
tokens.breakpoint(for: .desktop) // 1024pt
```

### Layout Tier

``PrismDesignTokens`` resolve automaticamente o layout tier com base na largura:

```swift
let tier = tokens.layoutTier(for: 400)  // .compact
let tier = tokens.layoutTier(for: 700)  // .regular
let tier = tokens.layoutTier(for: 1200) // .expansive
```

- Tip: Use `layoutTier(for:)` para adaptar layouts programaticamente. Componentes do Prism já fazem isso internamente.

### Tokens Customizados

Crie conjuntos de tokens customizados para marcas específicas:

```swift
let customTokens = PrismDesignTokens(
    spacing: PrismDesignTokens.defaultSpacing,
    radius: [
        .small: 6, .medium: 12, .large: 20, .extraLarge: 28, .circle: 0
    ],
    fontSizes: PrismDesignTokens.defaultFontSizes,
    durations: PrismDesignTokens.defaultDurations,
    breakpoints: PrismDesignTokens.defaultBreakpoints
)
```

## Topics

- ``PrismDesignTokens``
- ``PrismLayoutTier``
- ``PrismPlatform``