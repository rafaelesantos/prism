# VideoDownloader

Download de vídeo com streaming de progresso em tempo real.

## Visão Geral

``PrismVideoDownloader`` é um `actor` thread-safe que baixa vídeos via `AVAssetExportSession` e transmite o progresso via `AsyncStream<PrismVideoDownloaderStatus>`.

### Uso Básico

```swift
import PrismVideo

let downloader = PrismVideoDownloader(
    video: url,
    with: "apresentacao",
    for: .mp4
)

for await status in await downloader.download() {
    switch status {
    case .downloading(let progress, let session):
        print("Progresso: \(Int(progress * 100))%")
    case .completed(let path):
        print("Vídeo salvo em: \(path)")
    case .error:
        print("Erro durante o download")
    }
}
```

### PrismVideoDownloaderStatus

| Estado | Descrição |
|--------|-----------|
| `downloading(progress:session:)` | Download em andamento com progresso 0.0–1.0 |
| `completed(path:)` | Download concluído, caminho do arquivo |
| `error` | Erro durante o download |

### Entidades

Use ``PrismVideoEntity`` para representar metadados do vídeo:

```swift
let entity = PrismVideoEntity(
    url: videoURL,
    title: "Apresentação Q4",
    duration: 180.0,
    resolution: .hd1080p,
    type: .mp4,
    thumb: thumbnailURL
)
```

``PrismVideoResolution`` define resoluções comuns:

| Resolução | Valor |
|-----------|-------|
| `.sd480p` | 480p |
| `.hd720p` | 720p |
| `.hd1080p` | 1080p |
| `.uhd4K` | 4K |

### Erros

``PrismVideoError`` conforma ``PrismError`` e fornece descrições, motivos e sugestões de recuperação:

```swift
do {
    for await status in try await downloader.download() {
        // processar status
    }
} catch let error as PrismVideoError {
    print(error.errorDescription ?? "Erro desconhecido")
    print(error.recoverySuggestion ?? "")
}
```

## Topics

- ``PrismVideoDownloader``
- ``PrismVideoDownloaderStatus``
- ``PrismVideoEntity``
- ``PrismVideoResolution``
- ``PrismVideoError``