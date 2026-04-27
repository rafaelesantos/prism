# Scaffold

Composição de tela com título, subtítulo, ações e conteúdo adaptativo.

## Visão Geral

``PrismScaffold`` é o componente de composição de tela do PrismUI. Fornece uma estrutura consistente com header (título + subtítulo), área de ações e área de conteúdo escrolável.

### Uso Básico

```swift
PrismScaffold("Configurações") {
    SettingsContent()
}
```

### Com Subtítulo

```swift
PrismScaffold("Workspace", subtitle: "Gerencie seus projetos") {
    ProjectList()
}
```

### Com Ações

```swift
PrismScaffold("Projetos", subtitle: "3 projetos ativos") {
    PrismPrimaryButton("Novo Projeto") {
        createProject()
    }
} content: {
    ProjectList()
}
```

### Com PrismResourceString

```swift
PrismScaffold(AppString.dashboardTitle) {
    DashboardContent()
}
```

### Adaptação por Plataforma

O Scaffold adapta automaticamente:

| Elemento | iOS | macOS | tvOS | watchOS |
|----------|-----|-------|------|---------|
| Título | Large title | Title3 | Title | Title3 |
| Subtítulo | Subheadline | Subheadline | Caption | Caption |
| Ações | Horizontal stack | Toolbar area | Foco remoto | Vertical stack |
| Conteúdo | Scrollable | Scrollable | Foco | Compact |

### Scrollable

Por padrão, o conteúdo é escrolável. Desative quando não necessário:

```swift
PrismScaffold("Tela Fixa", scrollable: false) {
    FixedContent()
}
```

## Topics

- ``PrismScaffold``