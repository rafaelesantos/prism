import SwiftUI

/// Async image loader with placeholder, error state, and themed styling.
public struct PrismAsyncImage<Placeholder: View>: View {
    @Environment(\.prismTheme) private var theme

    private let url: URL?
    private let contentMode: ContentMode
    private let radius: RadiusToken
    private let placeholder: Placeholder

    public init(
        url: URL?,
        contentMode: ContentMode = .fill,
        radius: RadiusToken = .md,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.radius = radius
        self.placeholder = placeholder()
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .clipShape(radius.shape)

            case .failure:
                errorView

            case .empty:
                placeholder

            @unknown default:
                placeholder
            }
        }
    }

    private var errorView: some View {
        ZStack {
            theme.color(.surfaceSecondary)
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(theme.color(.onBackgroundTertiary))
        }
        .clipShape(radius.shape)
    }
}

extension PrismAsyncImage where Placeholder == PrismAsyncImageDefaultPlaceholder {

    public init(
        url: URL?,
        contentMode: ContentMode = .fill,
        radius: RadiusToken = .md
    ) {
        self.url = url
        self.contentMode = contentMode
        self.radius = radius
        self.placeholder = PrismAsyncImageDefaultPlaceholder()
    }
}

public struct PrismAsyncImageDefaultPlaceholder: View {
    @Environment(\.prismTheme) private var theme

    public var body: some View {
        ZStack {
            theme.color(.surfaceSecondary)
            ProgressView()
        }
    }
}
