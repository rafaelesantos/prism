# PlatformAvailability

Disponibilidade dos backends de inteligência por plataforma Apple.

## Visão Geral

Nem todos os backends de inteligência estão disponíveis em todas as plataformas. Esta página resume a disponibilidade e fornece estratégias de fallback.

### Disponibilidade por Backend

| Backend | iOS | macOS | tvOS | watchOS | visionOS |
|---------|-----|-------|------|---------|----------|
| Treino local (CreateML) | Sim | Sim | Não | Não | Não |
| Inferência local (CoreML) | Sim | Sim | Sim | Sim | Sim |
| Apple Intelligence (FoundationModels) | Sim* | Sim* | Não | Não | Não |
| Modelo remoto (HTTP) | Sim | Sim | Sim | Sim | Sim |

*Requer dispositivo compatível e configuração do sistema.

### CreateML

CreateML (usado para treino local) requer:
- `import CreateML` disponível apenas no iOS e macOS
- `import TabularData` para dados tabulares
- Não disponível em tvOS, watchOS ou visionOS

### CoreML

CoreML (usado para inferência local) está disponível em todas as plataformas, mas com limitações:
- watchOS: modelos menores devido a restrições de memória
- tvOS: inferência síncrona pode ser mais lenta

### FoundationModels

Apple Intelligence via FoundationModels requer:
- Dispositivo compatível (iPhone 15 Pro+, Mac com Apple Silicon)
- Sistema configurado com Apple Intelligence ativo
- Não disponível em Simulador

### Estratégia de Fallback

Para máxima compatibilidade, combine backends:

```swift
// Estratégia recomendada: local → Apple → remoto
let client: PrismIntelligenceClient

if let localModel = try? await PrismIntelligenceClient.local(modelID: "intent") {
    client = localModel
} else if await PrismIntelligenceClient.apple().status().isAvailable {
    client = PrismIntelligenceClient.apple()
} else {
    client = PrismIntelligenceClient.remote(
        endpoint: URL(string: "https://api.example.com/v1/generate")!,
        model: "fallback-model"
    )
}
```

Para tvOS e watchOS, use o provider remoto como fallback:

```swift
#if os(tvOS) || os(watchOS)
let client = PrismIntelligenceClient.remote(
    endpoint: remoteEndpoint,
    model: "lightweight-model"
)
#endif
```

### Verificação de Status

Sempre verifique a disponibilidade antes de usar:

```swift
let status = await client.status()

if !status.isAvailable {
    print("Backend indisponível: \(status.reason ?? "motivo desconhecido")")
    // Usar fallback
}
```

## Topics

- ``PrismIntelligenceClient``
- ``PrismIntelligenceStatus``
- ``PrismAppleIntelligenceProvider``
- ``PrismRemoteIntelligenceProvider``