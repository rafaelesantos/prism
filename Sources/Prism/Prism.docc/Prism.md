# ``Prism``

Módulo umbrella que re-exporta todos os módulos core do Prism para conveniência no nível do app.

## Visão Geral

Prism é um framework Swift moderno para construir aplicativos Apple com uma camada de fundação compartilhada, primitivas de rede, blocos de arquitetura, componentes de UI adaptativos, helpers de mídia e experimentos de inteligência.

Importe o módulo umbrella para acessar toda a API pública em um único import:

```swift
import Prism
```

Ou importe apenas os módulos focados que você precisa:

```swift
import PrismFoundation
import PrismUI
```

### Módulos

| Módulo | Descrição |
|--------|-----------|
| ``PrismFoundation`` | Camada base: defaults, recursos, formatação, logging, locale, entidades |
| ``PrismNetwork`` | Infraestrutura HTTP/WebSocket, endpoints, caching, logging |
| ``PrismArchitecture`` | Store, reducer, middleware, router, test store |
| ``PrismUI`` | Design system adaptativo: átomos, moléculas, modificadores, tokens, temas |
| ``PrismVideo`` | Download de vídeo com streaming de progresso |
| ``PrismIntelligence`` | Treino local, inferência, Apple Intelligence e modelos remotos |

### Grafo de Dependências

```text
PrismFoundation  (camada base, sem dependências)
    ├── PrismNetwork
    ├── PrismArchitecture
    ├── PrismVideo
    ├── PrismIntelligence
    └── PrismUI  (também depende de PrismArchitecture)
            └── Prism  (umbrella, re-exporta todos)
```

## Topics

### Primeiros Passos

- ``GettingStarted``
- ``Installation``

### Arquitetura

- ``ArchitectureOverview``

### Módulos

- ``PrismFoundation``
- ``PrismNetwork``
- ``PrismArchitecture``
- ``PrismUI``
- ``PrismVideo``
- ``PrismIntelligence``