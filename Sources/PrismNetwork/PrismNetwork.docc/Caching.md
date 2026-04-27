# Caching

Estratégia de cache HTTP por endpoint via `cacheInterval`.

## Visão Geral

Cada ``PrismNetworkEndpoint`` pode definir um `cacheInterval` que controla por quanto tempo a resposta pode ser servida do cache antes de fazer uma nova requisição.

### Como Funciona

Quando `cacheInterval` é definido no endpoint, o ``PrismNetworkAdapter`` configura a política de cache da `URLRequest`:

- **Com `cacheInterval`**: Usa `returnCacheDataElseLoad` — serve do cache se disponível, senão faz a requisição
- **Sem `cacheInterval`** (`nil`): Usa `reloadIgnoringLocalCacheData` — sempre faz a requisição ao servidor

### Uso

```swift
struct CachedEndpoint: PrismNetworkEndpoint {
    var scheme: PrismNetworkScheme { .https }
    var host: String { "api.example.com" }
    var path: String { "/config" }
    var method: PrismNetworkMethod { .get }
    var headers: [String: String] { [:] }
    var body: (any Encodable)? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var timeoutInterval: TimeInterval? { nil }

    // Cache por 5 minutos
    var cacheInterval: TimeInterval? { 300 }
}
```

### Quando Usar Cache

| Situação | Recomendação |
|----------|-------------|
| Configuração do app | `cacheInterval: 300` (5 min) |
| Lista de categorias | `cacheInterval: 600` (10 min) |
| Dados do usuário | `cacheInterval: nil` (sem cache) |
| Operações POST/PUT | `cacheInterval: nil` (nunca cache) |

- Tip: Use cache apenas para endpoints GET com dados que mudam com baixa frequência. Nunca cacheie endpoints de escrita.

### URLCache Customizado

O ``PrismNetworkAdapter`` aceita um `URLCache` customizado no inicializador, permitindo controlar a capacidade de memória e disco:

```swift
let cache = URLCache(
    memoryCapacity: 256_000_000,   // 256 MB
    diskCapacity: 512_000_000      // 512 MB
)
let adapter = PrismNetworkAdapter(cache: cache)
```

## Topics

- ``PrismNetworkEndpoint``
- ``PrismNetworkAdapter``