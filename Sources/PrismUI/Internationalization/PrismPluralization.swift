import SwiftUI

public enum PrismPluralCategory: String, Sendable, CaseIterable {
    case zero
    case one
    case two
    case few
    case many
    case other
}

public struct PrismPluralRule: Sendable {

    public static let shared = PrismPluralRule()

    public init() {}

    public func category(for count: Int, locale: Locale) -> PrismPluralCategory {
        let language = locale.language.languageCode?.identifier ?? "en"

        switch language {
        case "en":
            return englishCategory(for: count)
        case "ar":
            return arabicCategory(for: count)
        case "ru":
            return russianCategory(for: count)
        case "ja", "zh", "ko", "vi", "th":
            return .other
        default:
            return englishCategory(for: count)
        }
    }

    // MARK: - English (CLDR: one/other)

    private func englishCategory(for count: Int) -> PrismPluralCategory {
        count == 1 ? .one : .other
    }

    // MARK: - Arabic (CLDR: zero/one/two/few/many/other)

    private func arabicCategory(for count: Int) -> PrismPluralCategory {
        if count == 0 { return .zero }
        if count == 1 { return .one }
        if count == 2 { return .two }
        let mod100 = count % 100
        if (3...10).contains(mod100) { return .few }
        if (11...99).contains(mod100) { return .many }
        return .other
    }

    // MARK: - Russian (CLDR: one/few/many/other)

    private func russianCategory(for count: Int) -> PrismPluralCategory {
        let mod10 = count % 10
        let mod100 = count % 100

        if mod10 == 1 && mod100 != 11 {
            return .one
        }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) {
            return .few
        }
        if mod10 == 0 || (5...9).contains(mod10) || (11...14).contains(mod100) {
            return .many
        }
        return .other
    }
}

public struct PrismPluralizedText: View {
    @Environment(\.locale) private var locale
    private let count: Int
    private let forms: [PrismPluralCategory: String]
    private let rule: PrismPluralRule

    public init(
        count: Int,
        forms: [PrismPluralCategory: String],
        rule: PrismPluralRule = .shared
    ) {
        self.count = count
        self.forms = forms
        self.rule = rule
    }

    public var body: some View {
        Text(resolvedText)
    }

    private var resolvedText: String {
        let category = rule.category(for: count, locale: locale)
        return forms[category] ?? forms[.other] ?? ""
    }
}
