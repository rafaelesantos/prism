# Router

Navegação tipada com push, modal e full-screen via ``PrismRouter``.

## Visão Geral

``PrismRouter`` gerencia a navegação com rotas tipadas. É `@Observable` e `@MainActor`, integrando-se nativamente com o SwiftUI.

### Definir Rotas

Conforme ``PrismRoutable``:

```swift
import PrismArchitecture

enum AppRoute: PrismRoutable {
    case home
    case profile(userId: String)
    case settings
    case editProfile

    var id: Self { self }
}
```

### Criar o Router

```swift
let router = PrismRouter<AppRoute>()

// Com estado inicial
let router = PrismRouter<AppRoute>(
    path: [.home],
    presentedRoute: nil,
    fullScreenRoute: nil
)
```

### Navegar

```swift
// Push (stack navigation)
router.push(.settings)

// Modal
router.present(.profile(userId: "123"))

// Full-screen
router.fullScreen(.editProfile)

// Método unificado
router.route(to: .settings, style: .push)
router.route(to: .profile(userId: "123"), style: .present)
```

### Voltar

```swift
// Dismiss modal ou full-screen, ou pop do stack
router.dismiss()

// Voltar à raiz
router.root()
```

### Propriedades Observáveis

```swift
router.path           // [Route] — stack de navegação
router.presentedRoute // Route? — modal ativo
router.fullScreenRoute // Route? — tela cheia ativa
router.isPresenting   // Bool — se há apresentação ativa
router.topRoute       // Route? — rota no topo da hierarquia
```

### PrismNavigationStyle

| Estilo | Descrição |
|--------|-----------|
| `push` | Navegação em stack |
| `present` | Modal (sheet) |
| `fullScreen` | Tela cheia |

## Topics

- ``PrismRouter``
- ``PrismRoutable``
- ``PrismNavigationStyle``