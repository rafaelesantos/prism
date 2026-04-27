# AdaptiveUI

Estratégia de UI adaptativa: um design language, padrões nativos por plataforma.

## Visão Geral

O PrismUI é construído com o princípio de **um design language, padrões de interação nativos**. Componentes adaptam seu comportamento automaticamente com base na plataforma e classe de tamanho, sem que o código do app precise de `#if os(...)`.

### Princípios

- Tokens compartilhados para cor, espaçamento, raio e tamanho
- SwiftUI-first com wrappers platform-aware quando APIs divergem
- Comportamento adaptativo resolvido via `PrismPlatformContext`
- API pública platform-agnostic

### Composição Recomendada

```swift
PrismNavigationView(
    router: router,
    sidebar: {
        SidebarView()
    },
    destination: { route in
        RouteView(route: route)
    },
    content: {
        PrismScaffold(
            "Workspace",
            subtitle: "Um único código com comportamento adaptativo"
        ) {
            PrismAdaptiveStack(style: .actions) {
                PrismPrimaryButton("Ação Primária") {
                    primaryAction()
                }
                PrismSecondaryButton("Ação Secundária") {
                    secondaryAction()
                }
            }
        } content: {
            MainContent()
        }
    }
)
```

### PrismAdaptiveStack

O componente central da adaptação. Resolve automaticamente o eixo do layout:

| Estilo | Compact (iPhone) | Regular (iPad) | Expansive (Mac) |
|--------|------------------|----------------|-----------------|
| `.automatic` | Vertical | Vertical | Horizontal |
| `.actions` | Vertical | Horizontal | Horizontal |
| `.form` | Vertical | Vertical | Horizontal |
| `.content` | Vertical | Vertical | Horizontal |

```swift
PrismAdaptiveStack(style: .actions) {
    PrismPrimaryButton("Salvar") { save() }
    PrismSecondaryButton("Cancelar") { cancel() }
}
```

### PrismLayoutTier

O layout tier é resolvido automaticamente por ``PrismDesignTokens``:

| Tier | Largura | Plataformas típicas |
|------|---------|---------------------|
| `.compact` | < phoneMax | iPhone portrait |
| `.regular` | phoneMax – desktop | iPad split, iPhone landscape |
| `.expansive` | > desktop | Mac, iPad full, visionOS |

### Notas por Plataforma

- **iOS e Mac Catalyst**: Prioriza touch + pointer-friendly ergonomics
- **macOS**: Nativo com keyboard, menu e window behavior
- **tvOS**: Otimizado para foco e remote navigation
- **watchOS**: Densidade e interação lightweight
- **visionOS**: Canvas centrado e layouts espaçosos

### Checklist de Review

- O componente degrada graciosamente em cada plataforma suportada?
- Respeita o modelo de interação correto para cada plataforma?
- É token-driven ao invés de hardcoded para uma classe de tela?
- A API pública é platform-agnostic?
- Uma feature screen pode ser composta sem `#if os(...)` no código do produto?

## Topics

- ``PrismAdaptiveStack``
- ``PrismAdaptiveStackStyle``
- ``PrismPlatform``
- ``PrismLayoutTier``
- ``PrismDesignTokens``