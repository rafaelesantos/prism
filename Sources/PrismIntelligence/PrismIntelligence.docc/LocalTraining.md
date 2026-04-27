# LocalTraining

Treino local de modelos com CreateML para classificação de texto e regressão tabular.

## Visão Geral

``PrismIntelligenceLocalTrainer`` treina modelos on-device usando `CreateML`. Suporta classificação de texto e classificação/regressão tabular.

### Classificação de Texto

Use ``PrismTextIntelligence`` para treinar classificadores de texto:

```swift
import PrismIntelligence

let intelligence = PrismTextIntelligence(
    samples: [
        .init(text: "Cobrar assinatura mensal", label: "finance"),
        .init(text: "Gerar relatório de uso", label: "analytics"),
        .init(text: "Resetar senha", label: "support"),
    ]
)

let model = try await intelligence.trainingTextClassifier(
    id: "support-intent",
    name: "Support Intent"
)
```

### Configuração de Texto

```swift
let config = PrismTextTrainingConfiguration(
    id: "support-intent",
    name: "Support Intent",
    localeIdentifier: "pt_BR",
    maxIterations: 50
)
```

### Classificação Tabular

Para dados estruturados:

```swift
let intelligence = PrismTabularIntelligence(
    rows: [
        [
            "sessions": .int(12),
            "spent": .double(89.9),
            "segment": .string("pro"),
            "target": .string("upgrade")
        ]
    ]
)

let model = try await intelligence.trainingClassifier(
    id: "upgrade-model",
    name: "Upgrade Model",
    targetColumn: "target"
)
```

### Regressão Tabular

Para prever valores contínuos:

```swift
let model = try await intelligence.trainingRegressor(
    id: "revenue-model",
    name: "Revenue Predictor",
    targetColumn: "revenue"
)
```

### Configuração Tabular

```swift
let config = PrismTabularTrainingConfiguration(
    id: "upgrade-model",
    name: "Upgrade Model",
    targetColumn: "target",
    maxDepth: 20,
    maxIterations: 10_000,
    minLossReduction: 0.0,
    minChildWeight: 0.01,
    randomSeed: 42,
    stepSize: 0.01
)
```

### PrismIntelligenceModel

O resultado do treino é um ``PrismIntelligenceModel``:

```swift
model.id          // Identificador único
model.name       // Nome legível
model.kind       // .textClassifier, .tabularClassifier, .tabularRegressor
model.engine     // .createML
model.path       // Caminho do arquivo .mlmodel
model.metrics    // Métricas de performance (accuracy, RMSE)
model.createdAt  // Data de criação
```

### Catálogo

Modelos treinados são automaticamente salvos no ``PrismIntelligenceCatalog``:

```swift
let catalog = PrismIntelligenceCatalog()

let allModels = catalog.allModels()
let model = catalog.model(id: "support-intent")
catalog.remove(id: "old-model")
catalog.clean() // Remove modelos órfãos
```

## Topics

- ``PrismIntelligenceLocalTrainer``
- ``PrismTextTrainingSample``
- ``PrismTextTrainingConfiguration``
- ``PrismTabularTrainingConfiguration``
- ``PrismIntelligenceModel``
- ``PrismIntelligenceCatalog``
- ``PrismIntelligenceFeatureValue``
- ``PrismIntelligenceFeatureRow``