# Theming

Sistema de temas com suporte a customização via protocolos e injeção por environment.

## Visão Geral

O sistema de temas do PrismUI é baseado em protocolos. ``PrismThemeProtocol`` compõe sub-protocolos para cor, espaçamento, raio e tamanho, permitindo override granular.

### PrismThemeProtocol

``PrismThemeProtocol`` requer:

| Propriedade | Protocolo | Descrição |
|-------------|----------|-----------|
| `color` | ``PrismColorProtocol`` | Cores semânticas |
| `spacing` | ``PrismSpacingProtocol`` | Valores de espaçamento |
| `radius` | ``PrismRadiusProtocol`` | Raios de borda |
| `size` | ``PrismSizeProtocol`` | Tamanhos de componentes |
| `locale` | ``PrismLocale`` | Locale do tema |
| `animation` | `Animation?` | Animação padrão |
| `feedback` | `SensoryFeedback` | Feedback háptico |
| `colorScheme` | `ColorScheme?` | Esquema de cores (light/dark) |
| `tokens` | ``PrismDesignTokens`` | Tokens de design |

### Tema Padrão

O PrismUI inclui `PrismDefaultTheme` com valores padrão:

```swift
let theme = PrismDefaultTheme()
// color: PrismDefaultColor
// spacing: PrismDefaultSpacing
// radius: PrismDefaultRadius
// size: PrismDefaultSize
// tokens: PrismDesignTokens.default
```

### Criar um Tema Customizado

```swift
struct MyAppTheme: PrismThemeProtocol {
    let color: PrismColorProtocol = AppColor()
    let spacing: PrismSpacingProtocol = PrismDefaultSpacing()
    let radius: PrismRadiusProtocol = AppRadius()
    let size: PrismSizeProtocol = PrismDefaultSize()
    let locale: PrismLocale = .brazil
    let animation: Animation? = .easeInOut(duration: 0.3)
    let feedback: SensoryFeedback = .success
    let colorScheme: ColorScheme? = nil
    let tokens: PrismDesignTokens = .default
}

struct AppColor: PrismColorProtocol {
    // Override cores semânticas
}
```

### Injeção via Environment

Aplique o tema na raiz da view hierarchy:

```swift
@State private var theme: PrismThemeProtocol = MyAppTheme()

var body: some View {
    ContentView()
        .environment(theme)
}
```

### Override Parcial

Use os sub-protocolos para override apenas do que precisa:

```swift
// Apenas cores customizadas
struct AppColor: PrismColorProtocol {
    // Implemente apenas as cores que diferem do padrão
}

// Apenas raios customizados
struct AppRadius: PrismRadiusProtocol {
    // Implemente apenas os raios que diferem
}
```

### Prefix Aliases

O PrismUI inclui um sistema de prefix aliases que permite usar um nome customizado para os componentes:

```swift
// NovaButton = PrismButton
// NovaText = PrismText
// NovaScaffold = PrismScaffold
```

Veja `Sources/PrismUI/Exports/PrismUIPrefixAliases.swift` para a lista completa.

## Topics

- ``PrismThemeProtocol``
- ``PrismColorProtocol``
- ``PrismSpacingProtocol``
- ``PrismRadiusProtocol``
- ``PrismSizeProtocol``
- ``PrismFontProtocol``
- ``PrismFontFamilyProtocol``