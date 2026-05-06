import SwiftUI

public struct PrismMultiLocalePreview<Content: View>: View {
    private let locales: [Locale]
    private let content: Content

    public static var defaultLocales: [Locale] {
        [
            Locale(identifier: "en"),
            Locale(identifier: "ar"),
            Locale(identifier: "ja"),
            Locale(identifier: "de"),
            Locale(identifier: "es"),
            Locale(identifier: "zh-Hans"),
        ]
    }

    public init(
        locales: [Locale]? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.locales = locales ?? Self.defaultLocales
        self.content = content()
    }

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(Array(locales.enumerated()), id: \.offset) { _, locale in
                    VStack(spacing: 8) {
                        Text(locale.identifier)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        content
                            .environment(\.locale, locale)
                            .environment(
                                \.layoutDirection,
                                localeLayoutDirection(locale)
                            )
                    }
                    .frame(minWidth: 200)
                    .padding()
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
    }

    private func localeLayoutDirection(_ locale: Locale) -> LayoutDirection {
        let language = locale.language.languageCode?.identifier ?? "en"
        let rtlLanguages: Set<String> = ["ar", "he", "fa", "ur"]
        return rtlLanguages.contains(language) ? .rightToLeft : .leftToRight
    }
}

// MARK: - View Modifier

extension View {

    public func prismPreviewLocales(_ locales: [Locale] = PrismMultiLocalePreview<EmptyView>.defaultLocales)
        -> some View
    {
        PrismMultiLocalePreview(locales: locales) {
            self
        }
    }
}
