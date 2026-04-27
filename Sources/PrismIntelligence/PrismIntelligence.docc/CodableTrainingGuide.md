# CodableTrainingGuide

Treine modelos de classificação e regressão diretamente a partir de structs Codable.

## Visão Geral

``PrismCodableTrainingData`` é um adaptador genérico que converte qualquer struct `Codable` em feature rows para treino tabular ou amostras para classificação de texto, eliminando a necessidade de converter manualmente seus dados.

### Definindo seus Dados

Crie uma struct `Codable` com as propriedades que representam seus features e target:

```swift
struct HouseData: Codable {
    var rooms: Int
    var area: Double
    var neighborhood: String
    var price: Double
}
```

### Regressão com Codable

Treine um regressor apontando a propriedade-alvo via key path:

```swift
let data = [
    HouseData(rooms: 3, area: 120, neighborhood: "Centro", price: 450_000),
    HouseData(rooms: 2, area: 80, neighborhood: "Zona Sul", price: 320_000),
    // ... mais dados
]

let training = PrismCodableTrainingData(data: data)
let result = await training.trainRegressor(
    id: "house_price",
    name: "House Price Predictor",
    target: \.price
)
```

### Classificação com Codable

Para classificação tabular, aponte o target para a coluna categórica:

```swift
struct UserData: Codable {
    var sessions: Int
    var spent: Double
    var segment: String
}

let training = PrismCodableTrainingData(data: users)
let result = await training.trainClassifier(
    id: "user_segment",
    name: "User Segment",
    target: \.segment
)
```

### Classificação de Texto com Codable

Para classificação de texto, informe os key paths de texto e label:

```swift
struct ReviewData: Codable {
    var text: String
    var sentiment: String
}

let training = PrismCodableTrainingData(data: reviews)
let result = await training.trainTextClassifier(
    id: "sentiment",
    name: "Sentiment Classifier",
    text: \.text,
    label: \.sentiment,
    locale: .portugueseBR
)
```

### Divisão Treino/Teste

O `testRatio` controla a proporção de dados reservados para teste. O `seed` garante reprodutibilidade:

```swift
let training = PrismCodableTrainingData(
    data: data,
    testRatio: 0.2,   // 20% para teste
    seed: 42           // reprodutível
)

let (train, test) = training.trainTestSplit()
```

### Seleção de Features

Use `featureColumns` na configuração para limitar quais propriedades serão usadas:

```swift
let config = PrismTabularTrainingConfiguration(
    id: "model",
    name: "Model",
    targetColumn: "price",
    featureColumns: ["rooms", "area"]  // ignora "neighborhood"
)

let result = await training.trainRegressor(
    id: "model",
    name: "Model",
    target: \.price,
    configuration: config
)
```

### Inspeção de Features

Extraia feature rows para debug ou pipelines customizados:

```swift
let rows = training.featureRows()
// [["rooms": .int(3), "area": .double(120), ...], ...]
```

## Tipos Suportados

O adaptador converte automaticamente propriedades dos seguintes tipos:

| Tipo Swift | ``PrismIntelligenceFeatureValue`` |
|---|---|
| `String` | `.string(_:)` |
| `Int` | `.int(_:)` |
| `Double` | `.double(_:)` |
| `Float` | `.double(_:)` (convertido) |
| `Bool` | `.bool(_:)` |

Propriedades de outros tipos são ignoradas durante a extração.

## Topics

- ``PrismCodableTrainingData``
- ``PrismTabularTrainingConfiguration``
- ``PrismTextTrainingConfiguration``
