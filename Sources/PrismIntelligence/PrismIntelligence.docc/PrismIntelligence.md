# ``PrismIntelligence``

Inteligência multi-backend: treino local, inferência local, Apple Intelligence e modelos remotos.

## Visão Geral

PrismIntelligence organiza a inteligência em três camadas:

1. **Treino local** — CreateML para classificação de texto e regressão tabular
2. **Inferência local** — CoreML para predições on-device
3. **Geração de linguagem** — Apple Intelligence (FoundationModels) ou provedores remotos HTTP

A API recomendada é ``PrismIntelligenceClient``, que abstrai os backends com a mesma interface:

```swift
import PrismIntelligence

// Backend local
let local = try await PrismIntelligenceClient.local(modelID: "support-intent")
let label = try await local.classify(text: "Cobrar assinatura premium")

// Apple Intelligence
let apple = PrismIntelligenceClient.apple()
let summary = try await apple.generate("Resuma os pontos principais da tela.")

// Modelo remoto com token
let remote = PrismIntelligenceClient.remote(
    endpoint: URL(string: "https://api.example.com/v1/generate")!,
    token: "sk-your-api-key",
    model: "gpt-oss-120b"
)
let answer = try await remote.generate("Crie um onboarding financeiro.")
```

## Topics

### Fachada Unificada

- ``Client``

### Treino Local

- ``LocalTraining``

### Treino com Codable

- <doc:CodableTrainingGuide>

### Inferência Local

- ``LocalInference``

### Apple Intelligence

- ``AppleIntelligence``

### Modelos Remotos

- ``RemoteModels``

### Disponibilidade

- ``PlatformAvailability``