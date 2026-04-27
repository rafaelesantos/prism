# Modifiers

Modificadores de view que adicionam efeitos visuais e comportamentos ao design system.

## Visão Geral

Modificadores PrismUI seguem a convenção `prism*` para evitar conflitos com modificadores nativos do SwiftUI.

### prismSkeleton

Loading skeleton que aparece automaticamente quando `@Environment(\.isLoading)` é `true`:

```swift
PrismText("Dados do usuário")
    .prismSkeleton()

// Com configuração customizada
PrismText("Título")
    .prismSkeleton(lineHeight: 20, cornerRadius: 4)
```

### prismGlow

Efeito de brilho/glow em views:

```swift
PrismSymbol("star.fill")
    .prismGlow(color: .yellow)
```

### prismConfetti

Efeito de confete para celebrações:

```swift
PrismView {
    SuccessContent()
}
.prismConfetti(trigger: $showConfetti)
```

### prismParallax

Efeito parallax em resposta a movimentos do dispositivo:

```swift
CardView()
    .prismParallax(magnitude: 10)
```

### prismScreen

Modificador que aplica comportamento de tela adaptativa:

```swift
ContentView()
    .prismScreen()
```

### prismSpacing

Aplica espaçamento do token system:

```swift
VStack {
    TitleView()
    ContentView()
}
.prismSpacing(.large)
```

### prismBackground

Background com cores semânticas do design system:

```swift
// Background principal
ContentView()
    .prismBackground()

// Background secundário
CardView()
    .prismBackgroundSecondary()

// Background de linha (para listas)
RowView()
    .prismBackgroundRow()
```

### prismSize

Modificador de tamanho baseado em tokens:

```swift
PrismSymbol("star.fill")
    .prismSize(.large)
```

### prismSystemMonitor

Monitora estado do sistema (memória, CPU):

```swift
DebugView()
    .prismSystemMonitor()
```

### prismAccessibility

Aplica propriedades de acessibilidade completa:

```swift
PrismText("Valor")
    .prismAccessibility(.text("Valor monetário", testID: "amount"))
```

Veja ``Accessibility`` para documentação completa.

## Topics

- ``PrismSkeletonModifier``
- ``PrismGlowModifier``
- ``PrismConfettiModifier``
- ``PrismParallax``
- ``PrismScreenModifier``
- ``PrismSpacingModifier``
- ``PrismBackgroundModifier``
- ``PrismBackgroundRowModifier``
- ``PrismBackgroundSecondaryModifier``
- ``PrismSizeModifier``
- ``PrismSystemMonitorModifier``
- ``PrismAccessibilityModifier``