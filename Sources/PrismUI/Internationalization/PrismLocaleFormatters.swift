import Foundation

public enum PrismNumberStyle: Sendable {
    case decimal
    case currency(code: String)
    case percent
    case scientific
}

public enum PrismDateStyle: Sendable {
    case short
    case medium
    case long
    case full
    case relative
}

public struct PrismNumberFormatter: Sendable {

    public static let shared = PrismNumberFormatter()

    public init() {}

    public func format(_ value: Double, style: PrismNumberStyle, locale: Locale) -> String {
        switch style {
        case .decimal:
            return value.formatted(
                .number
                    .locale(locale)
                    .precision(.fractionLength(0...2))
            )
        case .currency(let code):
            return value.formatted(
                .currency(code: code)
                    .locale(locale)
            )
        case .percent:
            return value.formatted(
                .percent
                    .locale(locale)
            )
        case .scientific:
            let formatter = NumberFormatter()
            formatter.numberStyle = .scientific
            formatter.locale = locale
            formatter.maximumFractionDigits = 4
            return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }
}

public struct PrismDateFormatter: Sendable {

    public static let shared = PrismDateFormatter()

    public init() {}

    public func format(_ date: Date, style: PrismDateStyle, locale: Locale) -> String {
        switch style {
        case .short:
            return date.formatted(
                .dateTime
                    .year().month(.twoDigits).day()
                    .locale(locale)
            )
        case .medium:
            return date.formatted(
                .dateTime
                    .year().month(.abbreviated).day()
                    .locale(locale)
            )
        case .long:
            return date.formatted(
                .dateTime
                    .year().month(.wide).day()
                    .locale(locale)
            )
        case .full:
            return date.formatted(
                .dateTime
                    .year().month(.wide).day().weekday(.wide)
                    .locale(locale)
            )
        case .relative:
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = locale
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: Date.now)
        }
    }
}

public struct PrismRelativeTimeFormatter: Sendable {

    public static let shared = PrismRelativeTimeFormatter()

    public init() {}

    public func format(_ date: Date, relativeTo reference: Date, locale: Locale) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: reference)
    }
}
