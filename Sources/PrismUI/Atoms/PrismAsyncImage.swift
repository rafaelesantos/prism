//
//  PrismAsyncImage.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/07/25.
//

import SwiftUI

/// Asynchronous image component for the PrismUI Design System.
///
/// `PrismAsyncImage` loads and displays images from remote URLs with:
/// - Automatic image caching (configurable via cacheInterval)
/// - Customizable placeholder during loading
/// - Smooth appearance animation (optional)
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// PrismAsyncImage("https://example.com/image.jpg")
///     .prism(width: .large)
/// ```
///
/// ## With Custom Placeholder
/// ```swift
/// PrismAsyncImage(
///     "https://example.com/avatar.jpg",
///     placeholder: {
///         PrismShape(.circle)
///             .prism(background: .secondary)
///     }
/// )
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismAsyncImage(
///     "https://example.com/product.png",
///     testID: "product_image"
/// )
/// ```
///
/// ## With Custom Content Closure
/// ```swift
/// PrismAsyncImage("https://example.com/banner.jpg") { image in
///     image
///         .resizable()
///         .scaledToFill()
///         .prism(clip: .rounded(radius: .medium))
/// }
/// ```
///
/// ## Image Caching
/// Caching is automatic and configurable:
/// - `cacheInterval: .infinity` - Permanent cache (default)
/// - `cacheInterval: 3600` - Cache for 1 hour
/// - `cacheInterval: nil` - No cache
///
/// - Note: The appearance animation uses `.bouncy` by default and can be disabled with `isAnimated: false`.
public struct PrismAsyncImage: PrismView {
    @Environment(\.theme) var theme

    let url: URL?
    let cacheInterval: TimeInterval?
    let isAnimated: Bool
    let content: ((Image) -> any View)?
    let placeholder: (() -> any View)?
    public var accessibility: PrismAccessibilityProperties?

    @State var image: Image?

    public init(
        _ source: String?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        cacheInterval: TimeInterval? = .infinity,
        isAnimated: Bool = true,
        content: ((Image) -> any View)? = nil,
        placeholder: (() -> any View)? = nil
    ) {
        self.url = URL(string: source ?? "")
        self.accessibility = accessibility
        self.cacheInterval = cacheInterval
        self.isAnimated = isAnimated
        self.content = content
        self.placeholder = placeholder
    }

    public init(
        _ url: URL?,
        _ accessibility: PrismAccessibilityProperties? = nil,
        cacheInterval: TimeInterval? = .infinity,
        isAnimated: Bool = true,
        content: ((Image) -> any View)? = nil,
        placeholder: (() -> any View)? = nil
    ) {
        self.url = url
        self.accessibility = accessibility
        self.cacheInterval = cacheInterval
        self.isAnimated = isAnimated
        self.content = content
        self.placeholder = placeholder
    }

    public init(
        _ source: String?,
        testID: String,
        cacheInterval: TimeInterval? = .infinity,
        isAnimated: Bool = true
    ) {
        self.url = URL(string: source ?? "")
        self.accessibility = PrismAccessibility.image("Image", testID: testID)
        self.cacheInterval = cacheInterval
        self.isAnimated = isAnimated
        self.content = nil
        self.placeholder = nil
    }

    public var body: some View {
        contentView
            .task {
                guard image == nil else { return }
                fetchImage()
            }
            .onChange(of: url) { fetchImage() }
            .prism(accessibility)
    }

    private var contentView: some View {
        Group {
            if let image, let content {
                AnyView(content(image))
            } else if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                Group {
                    if let placeholder {
                        AnyView(placeholder())
                    }
                }
            }
        }
    }

    func fetchImage() {
        Task { @MainActor in
            guard let url else { return }

            if let cachedImage = retrieveImage(for: url) {
                if isAnimated {
                    withAnimation(.bouncy) {
                        image = cachedImage
                    }
                } else {
                    image = cachedImage
                }
            } else if let cachedImage = await storeImage(for: url) {
                if isAnimated {
                    withAnimation(.bouncy) {
                        image = cachedImage
                    }
                } else {
                    image = cachedImage
                }
            }
        }
    }

    func retrieveImage(for url: URL) -> Image? {
        let request = URLRequest(url: url)
        if let cacheResponse = URLCache.shared.cachedResponse(for: request),
            let cacheInterval = cacheResponse.userInfo?[url.absoluteString] as? TimeInterval,
            cacheInterval > Date.now.timeIntervalSince1970
        {
            #if canImport(UIKit)
                if let image = UIImage(data: cacheResponse.data) {
                    return Image(uiImage: image)
                }
            #elseif canImport(AppKit)
                if let image = NSImage(data: cacheResponse.data) {
                    return Image(nsImage: image)
                }
            #endif
        }
        return nil
    }

    func storeImage(for url: URL) async -> Image? {
        let request = URLRequest(url: url)
        guard let (data, response) = try? await URLSession.shared.data(for: request) else { return nil }
        if let cacheInterval {
            let cachedData = CachedURLResponse(
                response: response, data: data,
                userInfo: [url.absoluteString: Date.now.timeIntervalSince1970 + cacheInterval], storagePolicy: .allowed)
            URLCache.shared.storeCachedResponse(cachedData, for: request)
        }
        #if canImport(UIKit)
            if let image = UIImage(data: data) {
                return Image(uiImage: image)
            }
        #elseif canImport(AppKit)
            if let image = NSImage(data: data) {
                return Image(nsImage: image)
            }
        #endif
        return nil
    }
    public static func mocked() -> some View {
        PrismAsyncImage("https://picsum.photos/id/42/600")
    }
}

#Preview {
    PrismAsyncImage.mocked()
}
