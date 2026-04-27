# Logging

Sistema de logging estruturado do Prism com integração ao `os.Logger`.

## Visão Geral

O Prism usa ``PrismLogger`` e ``PrismSystemLogger`` como protocolos base para logging. Cada módulo define seus próprios log messages conformando ``PrismResourceLogMessage``, garantindo que strings de log sejam localizáveis e tipadas.

### PrismLogger

``PrismLogger`` é o protocolo mais simples — qualquer tipo pode conformar para ganhar logging automático via `os.Logger`:

```swift
struct MyService: PrismLogger {
    enum LogMessage: String, PrismResourceLogMessage {
        case operationStarted = "Operation started"
        case operationCompleted = "Operation completed"
        var value: String { rawValue }
    }
}

let service = MyService()
service.info(.operationStarted)
service.warning(.operationCompleted)
service.error(.operationStarted)
```

### PrismSystemLogger

``PrismSystemLogger`` é uma extensão de ``PrismLogger`` que adiciona um `Logger` do sistema. Tipos que conformam com ``PrismSystemLogger`` fornecem uma instância `Logger` personalizada com subsystem e category específicos.

### PrismResourceLogMessage

``PrismResourceLogMessage`` garante que cada mensagem de log seja tipada e acessível como `String`. Módulos do Prism definem enums que conformam este protocolo, mantendo todas as mensagens centralizadas e localizáveis:

```swift
enum PrismNetworkLogMessage: String, PrismResourceLogMessage {
    case requestStarted = "Network request started"
    case requestCompleted = "Network request completed"
    var value: String { rawValue }
}
```

### Integração Automática

Os protocolos ``PrismEntity`` e ``PrismError`` já conformam com ``PrismLogger``. Isso significa que toda entidade e erro do Prism tem acesso a `info()`, `warning()` e `error()` automaticamente:

```swift
struct User: PrismEntity {
    let name: String
}

let user = User(name: "Maria")
user.log() // Registra a representação JSON do objeto
```

## Topics

- ``PrismLogger``
- ``PrismSystemLogger``
- ``PrismResourceLogMessage``