# Middleware

Interceptação de ações para concerns transversais com ``PrismMiddleware``.

## Visão Geral

Middleware intercepta ações antes que cheguem ao reducer, permitindo lógica transversal como analytics, logging e navegação.

### PrismSideEffect

Crie middleware com ``PrismSideEffect``:

```swift
import PrismArchitecture

let analyticsMiddleware = PrismSideEffect<AppState, AppAction> { state, action in
    // Registrar evento de analytics
    Analytics.track("\(action)")
    return .none
}
```

### Middleware com Effect

Middleware pode retornar effects, útil para lógica assíncrona:

```swift
let loggingMiddleware = PrismSideEffect<AppState, AppAction> { state, action in
    print("Action: \(action), State: \(state)")
    return .none
}

let navigationMiddleware = PrismSideEffect<AppState, AppAction> { state, action in
    switch action {
    case .loginSuccess:
        return .send(.navigateToHome)
    default:
        return .none
    }
}
```

### Composição de Middleware

Combine múltiplos middlewares:

```swift
let combined = PrismSideEffect.combine(
    analyticsMiddleware,
    loggingMiddleware,
    navigationMiddleware
)
```

### AnyPrismMiddleware

Type-erase um middleware para armazenamento em propriedades:

```swift
let erased: AnyPrismMiddleware<AppState, AppAction> = AnyPrismMiddleware(analyticsMiddleware)
```

### Uso com Store

Passe o middleware na criação do store:

```swift
let store = PrismStore(
    initialState: AppState(),
    reducer: MyReducer(),
    middleware: combinedMiddleware
)
```

## Topics

- ``PrismMiddleware``
- ``PrismSideEffect``
- ``AnyPrismMiddleware``