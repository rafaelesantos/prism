# NetworkLogging

Logging automático de requisições e respostas de rede.

## Visão Geral

O PrismNetwork integra-se ao sistema de logging do ``PrismFoundation``. Cada ``PrismNetworkEndpoint`` conforma com ``PrismLogger``, permitindo que as requisições sejam registradas automaticamente.

### Mensagens de Log

O módulo define mensagens de log tipadas via `PrismNetworkLogMessage`, que conforma ``PrismResourceLogMessage``. As mensagens cobrem:

- Início de requisição
- Conclusão de requisição
- Erros de rede
- Redirecionamentos

### Integração

Como ``PrismNetworkEndpoint`` conforma com ``PrismLogger``, cada endpoint pode registrar seu estado:

```swift
let endpoint = UsersEndpoint()
endpoint.log() // Registra informações do endpoint
```

### Logs do Adapter

O ``PrismNetworkAdapter`` registra automaticamente cada requisição que processa, incluindo:
- URL da requisição
- Método HTTP
- Código de status da resposta
- Duração da requisição
- Erros encontrados

### Configuração no Console

Os logs aparecem no Console do macOS e no Xcode com o subsystem do PrismNetwork. Use filtros por subsystem para isolar logs de rede:

```text
subsystem: com.prismlabs.PrismNetwork
```

## Topics

- ``PrismNetworkEndpoint``
- ``PrismLogger``
- ``PrismResourceLogMessage``