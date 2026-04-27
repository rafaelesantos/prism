# SemanticColors

Sistema de cores semânticas e gradientes do design system.

## Visão Geral

O PrismUI usa cores semânticas que se adaptam automaticamente a light/dark mode e a temas customizados. Em vez de valores hexadecimais fixos, os componentes referenciam cores por seu propósito semântico.

### Cores Semânticas Padrão

O asset catalog `Media.xcassets` inclui 15 cores semânticas:

| Cor | Uso |
|-----|-----|
| Background | Fundo principal da tela |
| BackgroundSecondary | Fundo de cards e superfícies elevadas |
| Border | Bordas e divisores |
| Disabled | Elementos desabilitados |
| Error | Estados de erro |
| Hover | Hover state (macOS) |
| Info | Informação contextual |
| Pressed | Pressed state |
| Primary | Ação primária |
| Secondary | Ação secundária |
| Shadow | Sombras |
| Success | Estados de sucesso |
| Surface | Superfícies elevadas |
| Warning | Estados de aviso |

### PrismSemanticColors

``PrismSemanticColors`` mapeia nomes semânticos a cores SwiftUI:

```swift
let colors = PrismSemanticColors()

colors.primary     // Cor da ação primária
colors.error       // Cor de erro
colors.surface     // Cor de superfície
```

### PrismGradient

``PrismGradient`` fornece gradientes baseados nas cores semânticas:

```swift
let gradient = PrismGradient.primary

Rectangle()
    .fill(gradient)
```

### Override em Custom Themes

Substitua cores semânticas criando um ``PrismColorProtocol`` customizado:

```swift
struct BrandColors: PrismColorProtocol {
    // Override apenas as cores que diferem do padrão
    // As demais herdam de PrismDefaultColor
}
```

Injete via tema:

```swift
struct BrandTheme: PrismThemeProtocol {
    let color: PrismColorProtocol = BrandColors()
    // ...
}
```

## Topics

- ``PrismSemanticColors``
- ``PrismGradient``
- ``PrismColorProtocol``
- ``PrismColor``