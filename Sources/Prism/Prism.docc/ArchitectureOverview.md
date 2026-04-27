# ArchitectureOverview

Arquitetura do Prism: módulos, dependências e padrões.

## Visão Geral

O Prism é organizado em módulos com dependências explícitas e limites claros de responsabilidade. Cada módulo é um target Swift independente que pode ser consumido isoladamente.

### Grafo de Dependências

```text
PrismFoundation  (camada base, sem dependências)
    ├── PrismNetwork       (HTTP, WebSocket, caching)
    ├── PrismArchitecture  (Store, Reducer, Middleware, Router)
    ├── PrismVideo          (download de vídeo)
    └── PrismIntelligence   (ML/AI local e remoto)

PrismFoundation
    └── PrismArchitecture
            └── PrismUI     (design system adaptativo)

PrismFoundation + PrismNetwork + PrismArchitecture
    + PrismUI + PrismVideo + PrismIntelligence
            └── Prism       (umbrella, re-exporta todos)
```

### Padrão de Nomenclatura: The Celestial Standard

O ecossistema segue uma nomenclatura inspirada em conceitos celestiais:

| Setor | Codinome | Conceito |
|-------|----------|----------|
| Foundation (Core) | **AXIS** | A linha central conectando todos os pontos |
| Investimentos | **ZENITH** | O ponto mais alto; performance financeira |
| Saúde | **VITAL** | Essencial para a vida; biometria central |
| Comércio | **ORBIT** | Fluxo contínuo de bens e transações |
| Consultoria | **BEACON** | Uma luz guia; direção estratégica |

Use o codinome para módulos específicos do app (ex: `ZenithEngine`, `VitalAuth`).

### Responsabilidades por Módulo

#### PrismFoundation

Camada base sem dependências. Fornece:
- Entidades leves (``PrismEntity``)
- Erros tipados (``PrismError``)
- Logging estruturado (``PrismLogger``, ``PrismSystemLogger``)
- Recursos localizados (``PrismResourceString``, ``PrismResourceImage``)
- Defaults persistidos (``PrismDefaults``)
- Formatação de datas (``PrismDateFormatter``)
- Gerenciador de arquivos (``PrismFileManager``)
- Locale (``PrismLocale``)
- Extensões Foundation

#### PrismNetwork

Infraestrutura de rede HTTP e WebSocket:
- Endpoints tipados (``PrismNetworkEndpoint``)
- Client HTTP (``PrismNetworkAdapter``, ``PrismNetworkClient``)
- WebSocket (``PrismNetworkSocketClient``, ``PrismNetworkSocketAdapter``)
- Caching por endpoint
- Logging integrado

#### PrismArchitecture

Blocos de arquitetura unidirecional:
- Store observável (``PrismStore``)
- Reducer protocol (``PrismReducer``, ``PrismReduce``)
- Effects assíncronos (``PrismEffect``)
- Middleware (``PrismMiddleware``)
- Router tipado (``PrismRouter``)
- Test Store (``PrismTestStore``)

#### PrismUI

Design system adaptativo SwiftUI:
- Átomos (``PrismText``, ``PrismButton``, ``PrismSymbol``, etc.)
- Moléculas (``PrismScaffold``, ``PrismNavigationView``, etc.)
- Modificadores (prismSkeleton, prismGlow, prismConfetti, etc.)
- Tokens de design (``PrismDesignTokens``)
- Sistema de temas (``PrismThemeProtocol``)
- Acessibilidade (``PrismAccessibilityProperties``)

#### PrismVideo

Helpers de mídia:
- Download de vídeo com streaming de progresso (``PrismVideoDownloader``)
- Entidades de vídeo (``PrismVideoEntity``, ``PrismVideoResolution``)

#### PrismIntelligence

ML/AI multi-backend:
- Treino local com CreateML (``PrismIntelligenceLocalTrainer``)
- Inferência local com CoreML (``PrismIntelligencePrediction``)
- Apple Intelligence via FoundationModels (``PrismAppleIntelligenceProvider``)
- Modelos remotos via HTTP (``PrismRemoteIntelligenceProvider``)
- Fachada unificada (``PrismIntelligenceClient``)

### Padrão Arquitetural: Composable

O ``PrismArchitecture`` segue o padrão unidirecional de dados:

```text
View → Action → Reducer → State → View
                  ↓
              Middleware
                  ↓
              Effect → Action
```

- A **View** envia ações para o **Store**
- O **Reducer** processa ações e produz novo estado
- O **Middleware** intercepta ações para efeitos colaterais
- Os **Effects** produzem novas ações de forma assíncrona
- O **State** atualizado re-renderiza a View

Diferente do TCA, o Prism não tem um sistema de dependencies — a injeção é feita via protocolos e inicializadores, mantendo a simplicidade.