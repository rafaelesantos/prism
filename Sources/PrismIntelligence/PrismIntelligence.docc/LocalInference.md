# LocalInference

Inferência local com CoreML usando modelos treinados ou importados.

## Visão Geral

``PrismIntelligencePrediction`` executa predições on-device usando modelos CoreML. Funciona com modelos treinados via ``PrismIntelligenceLocalTrainer`` ou importados.

### Classificação de Texto

```swift
import PrismIntelligence

let prediction = await PrismIntelligencePrediction(model: storedModel)
let label = try await prediction.predictText(from: "Cobrar assinatura premium")
// label: "finance"
```

### Classificação Tabular

```swift
let features: PrismIntelligenceFeatureRow = [
    "sessions": .int(12),
    "spent": .double(89.9),
    "segment": .string("pro")
]

let probabilities = try await client.classify(features: features)
// ["upgrade": 0.85, "churn": 0.10, "downgrade": 0.05]
```

### Regressão Tabular

```swift
let value = try await client.regress(features: features)
// value: 142.50 (valor previsto)
```

### PrismIntelligenceFeatureValue

``PrismIntelligenceFeatureValue`` representa valores de features para dados tabulares:

```swift
enum PrismIntelligenceFeatureValue {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
}
```

Crie a partir de valores `Any`:

```swift
let value = PrismIntelligenceFeatureValue(42)        // .int(42)
let value = PrismIntelligenceFeatureValue(3.14)      // .double(3.14)
let value = PrismIntelligenceFeatureValue("hello")   // .string("hello")
```

### Carregamento de Modelos

Use ``PrismIntelligenceCatalog`` para gerenciar modelos persistidos:

```swift
let catalog = PrismIntelligenceCatalog()
let model = catalog.model(id: "support-intent")
let allModels = catalog.allModels()
```

## Topics

- ``PrismIntelligencePrediction``
- ``PrismIntelligenceModel``
- ``PrismIntelligenceFeatureValue``
- ``PrismIntelligenceCatalog``