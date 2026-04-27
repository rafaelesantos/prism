# Resources

Abstrações para recursos localizados: strings, imagens e mensagens de log.

## Visão Geral

O Prism usa três protocolos para desacoplar recursos do código-fonte:

- ``PrismResourceString`` — Strings localizáveis
- ``PrismResourceImage`` — Imagens do asset catalog
- ``PrismResourceLogMessage`` — Mensagens de log

### PrismResourceString

Para strings que precisam de localização, conformo ``PrismResourceString``:

```swift
enum AppString: String, PrismResourceString {
    case welcomeTitle
    case loginButton

    var localized: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }

    var value: String {
        String(localized: LocalizedStringKey(rawValue))
    }
}
```

Use no SwiftUI:

```swift
PrismText(AppString.welcomeTitle.localized)
```

### PrismResourceImage

Para imagens do asset catalog:

```swift
enum AppImage: String, PrismResourceImage {
    case logo
    case placeholder

    var image: Image {
        Image(rawValue)
    }
}
```

### PrismResourceLogMessage

Para mensagens de log tipadas. Veja ``Logging`` para detalhes completos.

### Catálogos .xcstrings

O PrismNetwork e PrismUI incluem catálogos `.xcstrings` para strings localizadas. Esses arquivos são compilados pelo SPM e acessíveis via os protocolos de recurso.

## Topics

- ``PrismResourceString``
- ``PrismResourceImage``
- ``PrismResourceLogMessage``