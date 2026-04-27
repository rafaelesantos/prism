# RemoteModels

Integração com modelos de linguagem remotos via HTTP.

## Visão Geral

``PrismRemoteIntelligenceProvider`` conecta o Prism a provedores LLM externos via HTTP. O design separa serialização (``PrismRemoteIntelligenceSerializer``) de transporte (``PrismRemoteIntelligenceTransport``), permitindo customização de ambos.

### Uso via PrismIntelligenceClient

A forma mais simples de usar um modelo remoto com autenticação por token:

```swift
import PrismIntelligence

let client = PrismIntelligenceClient.remote(
    endpoint: URL(string: "https://api.example.com/v1/generate")!,
    token: "sk-your-api-key",
    model: "gpt-oss-120b"
)

let answer = try await client.generate("Crie um onboarding financeiro.")
```

Para headers customizados além do Bearer token:

```swift
let client = PrismIntelligenceClient.remote(
    endpoint: URL(string: "https://api.example.com/v1/generate")!,
    model: "gpt-oss-120b",
    providerName: "example-ai",
    headers: [
        "Authorization": "Bearer TOKEN",
        "X-Custom-Header": "value"
    ]
)
```

### Com Serializer Customizado

Para provedores com APIs não-padrão:

```swift
let client = PrismIntelligenceClient.remote(
    serializer: MyCustomSerializer(),
    transport: PrismURLSessionRemoteIntelligenceTransport()
)
```

### Uso Direto do Provider

```swift
let serializer = PrismDefaultRemoteIntelligenceSerializer(
    endpoint: URL(string: "https://api.example.com/v1/generate")!,
    model: "gpt-oss-120b",
    providerName: "example-ai",
    headers: ["Authorization": "Bearer TOKEN"]
)

let service = PrismLanguageIntelligence(
    provider: PrismRemoteIntelligenceProvider(serializer: serializer)
)

let response = try await service.generate(
    .init(
        prompt: "Sugira um onboarding para um app financeiro.",
        systemPrompt: "Responda em português do Brasil."
    )
)
```

### PrismRemoteIntelligenceSerializer

O serializer converte requests/responses entre o formato Prism e o formato do provedor. O serializer padrão segue o padrão OpenAI-compatible.

### PrismRemoteIntelligenceTransport

O transporte executa a requisição HTTP. O transporte padrão usa `URLSession`. Crie um customizado para:

- Retry logic
- Rate limiting
- Proxy
- Logging avançado

### Configuração

```swift
let client = PrismIntelligenceClient.remote(
    endpoint: URL(string: "https://api.example.com/v1/generate")!,
    model: "gpt-oss-120b",
    headers: ["Authorization": "Bearer TOKEN"],
    timeout: 120  // segundos
)
```

## Topics

- ``PrismRemoteIntelligenceProvider``
- ``PrismRemoteIntelligenceSerializer``
- ``PrismRemoteIntelligenceTransport``
- ``PrismLanguageIntelligence``
- ``PrismLanguageIntelligenceRequest``
- ``PrismLanguageIntelligenceResponse``