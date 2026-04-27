# ``PrismVideo``

Download de vídeo com streaming de progresso e entidades de mídia.

## Visão Geral

PrismVideo fornece infraestrutura para download de vídeo via `AVAssetExportSession`, com streaming de progresso em tempo real usando `AsyncStream`.

### Uso Básico

```swift
import PrismVideo

let downloader = PrismVideoDownloader(
    video: url,
    with: "meu-video",
    for: .mp4
)

for await status in await downloader.download() {
    switch status {
    case .downloading(let progress, _):
        print("Progresso: \(Int(progress * 100))%")
    case .completed(let path):
        print("Salvo em: \(path)")
    case .error:
        print("Erro no download")
    }
}
```

## Topics

### Download

- ``VideoDownloader``

### Entidades

- ``PrismVideoEntity``
- ``PrismVideoResolution``
- ``PrismVideoError``