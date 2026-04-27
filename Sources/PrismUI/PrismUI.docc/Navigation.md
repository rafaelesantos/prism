# Navigation

Navegação adaptativa com ``PrismNavigationView``: stack vs split-view automático.

## Visão Geral

``PrismNavigationView`` é o componente de navegação do PrismUI. Ele alterna automaticamente entre `NavigationStack` e `NavigationSplitView` com base na plataforma e na presença de sidebar.

### Navegação Simples (Stack)

```swift
PrismNavigationView(
    router: router,
    destination: { route in
        switch route {
        case .detail(let id):
            DetailView(id: id)
        case .settings:
            SettingsView()
        }
    },
    content: {
        HomeView()
    }
)
```

### Navegação com Sidebar (Split-view)

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
        ContentView()
    }
)
```

### Comportamento por Plataforma

| Plataforma | Sem sidebar | Com sidebar |
|------------|-------------|-------------|
| iPhone | NavigationStack | NavigationStack (sidebar vira sheet) |
| iPad | NavigationStack | NavigationSplitView |
| Mac | NavigationStack | NavigationSplitView |
| Apple TV | NavigationStack | NavigationStack (foco otimizado) |
| Apple Watch | NavigationStack | NavigationStack |

### Transições

No iOS, destinos push usam `.zoom` navigation transition para uma experiência visual premium:

```swift
// Automático — PrismNavigationView aplica .zoom em push destinations
```

### Integração com PrismRouter

O router controla a navegação de forma tipada:

```swift
let router = PrismRouter<AppRoute>()

// Push
router.push(.detail(id: "123"))

// Modal
router.present(.profile(userId: "456"))

// Full-screen
router.fullScreen(.onboarding)

// Dismiss
router.dismiss()
```

Veja ``Router`` (PrismArchitecture) para documentação completa do router.

## Topics

- ``PrismNavigationView``
- ``PrismRouter``
- ``PrismNavigationStyle``