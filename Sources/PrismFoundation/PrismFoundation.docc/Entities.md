# Entities

Protocolos base para entidades e erros tipados com logging integrado.

## Visão Geral

``PrismEntity`` e ``PrismError`` são os protocolos fundamentais do Prism. Eles combinam conformância com protocolos padrão (`Codable`, `Equatable`, `Hashable`, `Error`) com logging automático, eliminando boilerplate em cada módulo.

### PrismEntity

``PrismEntity`` é o protocolo base para modelos de dados:

```swift
struct User: PrismEntity {
    let id: UUID
    let name: String
    let email: String
}

let user = User(id: UUID(), name: "Maria", email: "maria@email.com")
user.log() // Registra a representação JSON no console
print(user.description) // JSON formatado
```

Conformância automática com:
- `Codable` — serialização JSON
- `Equatable` — comparação por valor
- `Hashable` — uso em Sets e Dictionary keys
- `CustomStringConvertible` — representação JSON
- ``PrismLogger`` — logging estruturado

### PrismError

``PrismError`` é o protocolo base para erros tipados:

```swift
enum AuthError: PrismError {
    case invalidCredentials
    case sessionExpired
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "Credenciais inválidas"
        case .sessionExpired: "Sessão expirada"
        case .networkUnavailable: "Rede indisponível"
        }
    }

    var failureReason: String? {
        switch self {
        case .invalidCredentials: "Email ou senha incorretos"
        case .sessionExpired: "Token de autenticação expirado"
        case .networkUnavailable: "Sem conexão com a internet"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials: "Verifique suas credenciais e tente novamente"
        case .sessionExpired: "Faça login novamente"
        case .networkUnavailable: "Verifique sua conexão com a internet"
        }
    }
}

let error = AuthError.invalidCredentials
error.log() // Registra erro com description, reason e suggestion
```

### PrismMock

``PrismMock`` facilita a criação de dados de teste:

```swift
struct User: PrismEntity, PrismMock {
    let id: UUID
    let name: String

    static var mock: User {
        User(id: UUID(), name: "Mock User")
    }
}

let testUser = User.mock
let testUsers = User.mocks // Array com múltiplos mocks
```

## Topics

- ``PrismEntity``
- ``PrismError``
- ``PrismMock``