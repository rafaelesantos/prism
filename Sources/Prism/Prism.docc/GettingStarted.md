# GettingStarted

Comece a usar o Prism em poucos minutos.

## Visão Geral

Este guia mostra como adicionar o Prism ao seu projeto, configurar um store com reducer, fazer uma requisição de rede e montar uma tela adaptativa.

### 1. Adicionar o Pacote

No Xcode, vá em **File → Add Package Dependencies** e adicione a URL do repositório. Ou configure manualmente no `Package.swift`:

```swift
dependencies: [
    .package(url: "<repository-url>", branch: "main")
]
```

E adicione o produto como dependência do seu target:

```swift
.product(name: "Prism", package: "prism")
```

### 2. Importar

```swift
import Prism
```

### 3. Criar um Store

Defina o estado e as ações, depois crie um reducer e um store:

```swift
// Estado
struct CounterState: PrismState {
    var count = 0
}

// Ações
enum CounterAction: PrismAction {
    case increment
    case decrement
}

// Reducer
let counterReducer = PrismReduce { (state: inout CounterState, action: CounterAction) in
    switch action {
    case .increment:
        state.count += 1
        return .none
    case .decrement:
        state.count -= 1
        return .none
    }
}

// Store
let store = PrismStore(initialState: CounterState(), reducer: counterReducer)
```

### 4. Montar uma Tela Adaptativa

Use os componentes do PrismUI para construir telas que funcionam em todas as plataformas Apple:

```swift
PrismScaffold("Contador", subtitle: "Exemplo Prism") {
    PrismButton("Incrementar") {
        store.send(.increment)
    }
} content: {
    PrismText("Contagem: \(store.state.count)")
}
```

### 5. Fazer uma Requisição de Rede

Defina um endpoint tipado e use o adapter:

```swift
struct UsersEndpoint: PrismNetworkEndpoint {
    var scheme: PrismNetworkScheme { .https }
    var host: String { "api.example.com" }
    var path: String { "/users" }
    var method: PrismNetworkMethod { .get }
    var headers: [String: String] { [:] }
    var body: (any Encodable)? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var timeoutInterval: TimeInterval? { nil }
    var cacheInterval: TimeInterval? { 300 }
}
```

### Próximos Passos

- ``Installation`` para detalhes de configuração
- ``ArchitectureOverview`` para entender a arquitetura completa
- Explore os módulos individuais para documentação detalhada