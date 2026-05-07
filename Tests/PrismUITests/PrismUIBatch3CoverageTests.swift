import CoreGraphics
import Foundation
import SwiftUI
import Testing

@testable import PrismUI

// MARK: - Charts: PrismCandlestick

@Suite("CandlestickCov")
struct PrismCandlestickCoverageTests {
    @Test("init stores all fields")
    func initFields() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let c = PrismCandlestick(date: date, open: 100, high: 110, low: 90, close: 105)
        #expect(c.date == date)
        #expect(c.open == 100)
        #expect(c.high == 110)
        #expect(c.low == 90)
        #expect(c.close == 105)
    }

    @Test("id is date")
    func idIsDate() {
        let date = Date(timeIntervalSince1970: 2_000_000)
        let c = PrismCandlestick(date: date, open: 1, high: 2, low: 0, close: 1.5)
        #expect(c.id == date)
    }

    @Test("bullish when close >= open")
    func bullish() {
        let date = Date(timeIntervalSince1970: 100)
        let bull = PrismCandlestick(date: date, open: 10, high: 15, low: 8, close: 14)
        #expect(bull.isBullish == true)

        let flat = PrismCandlestick(date: date, open: 10, high: 15, low: 8, close: 10)
        #expect(flat.isBullish == true)
    }

    @Test("bearish when close < open")
    func bearish() {
        let date = Date(timeIntervalSince1970: 100)
        let bear = PrismCandlestick(date: date, open: 10, high: 15, low: 8, close: 9)
        #expect(bear.isBullish == false)
    }

    @Test("hashable")
    func hashable() {
        let date = Date(timeIntervalSince1970: 100)
        let a = PrismCandlestick(date: date, open: 1, high: 2, low: 0, close: 1)
        let b = PrismCandlestick(date: date, open: 1, high: 2, low: 0, close: 1)
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }
}

// MARK: - Charts: PrismFunnelStage

@Suite("FunnelStageCov")
struct PrismFunnelStageCoverageTests {
    @Test("init stores fields")
    func initFields() {
        let s = PrismFunnelStage(label: "Awareness", value: 1000)
        #expect(s.label == "Awareness")
        #expect(s.value == 1000)
        #expect(s.color == nil)
    }

    @Test("id is label")
    func idIsLabel() {
        let s = PrismFunnelStage(label: "Conversion", value: 50)
        #expect(s.id == "Conversion")
    }

    @Test("color optional")
    func colorOptional() {
        let s = PrismFunnelStage(label: "X", value: 10, color: .red)
        #expect(s.color == .red)
    }

    @Test("hashable")
    func hashable() {
        let a = PrismFunnelStage(label: "A", value: 100)
        let b = PrismFunnelStage(label: "A", value: 100)
        #expect(a == b)
    }
}

// MARK: - Charts: PrismHeatmapCell

@Suite("HeatmapCellCov")
struct PrismHeatmapCellCoverageTests {
    @Test("init stores fields")
    func initFields() {
        let c = PrismHeatmapCell(row: 2, column: 3, value: 0.75)
        #expect(c.row == 2)
        #expect(c.column == 3)
        #expect(c.value == 0.75)
    }

    @Test("hashable")
    func hashable() {
        let a = PrismHeatmapCell(row: 0, column: 0, value: 1.0)
        let b = PrismHeatmapCell(row: 0, column: 0, value: 1.0)
        #expect(a == b)
    }

    @Test("different values not equal")
    func notEqual() {
        let a = PrismHeatmapCell(row: 0, column: 0, value: 1.0)
        let b = PrismHeatmapCell(row: 0, column: 0, value: 2.0)
        #expect(a != b)
    }
}

// MARK: - Charts: PrismTreemapItem

@Suite("TreemapItemCov")
struct PrismTreemapItemCoverageTests {
    @Test("init stores fields")
    func initFields() {
        let item = PrismTreemapItem(id: "t1", label: "Tech", value: 500)
        #expect(item.id == "t1")
        #expect(item.label == "Tech")
        #expect(item.value == 500)
        #expect(item.color == nil)
        #expect(item.children.isEmpty)
    }

    @Test("with children")
    func withChildren() {
        let child = PrismTreemapItem(id: "c1", label: "Child", value: 100)
        let parent = PrismTreemapItem(id: "p1", label: "Parent", value: 300, children: [child])
        #expect(parent.children.count == 1)
        #expect(parent.children[0].id == "c1")
    }

    @Test("equatable uses id only")
    func equatableById() {
        let a = PrismTreemapItem(id: "x", label: "A", value: 10)
        let b = PrismTreemapItem(id: "x", label: "B", value: 20)
        #expect(a == b)
    }

    @Test("hashable uses id")
    func hashableById() {
        let a = PrismTreemapItem(id: "x", label: "A", value: 10)
        let b = PrismTreemapItem(id: "x", label: "B", value: 20)
        #expect(a.hashValue == b.hashValue)
    }

    @Test("different id not equal")
    func differentId() {
        let a = PrismTreemapItem(id: "x", label: "A", value: 10)
        let b = PrismTreemapItem(id: "y", label: "A", value: 10)
        #expect(a != b)
    }
}

// MARK: - Charts: PrismSparklineStyle

@Suite("SparklineStyleCov")
struct PrismSparklineStyleCoverageTests {
    @Test("all cases")
    func allCases() {
        let cases = PrismSparklineStyle.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.line))
        #expect(cases.contains(.area))
        #expect(cases.contains(.bar))
    }

    @Test("raw values")
    func rawValues() {
        #expect(PrismSparklineStyle.line.rawValue == "line")
        #expect(PrismSparklineStyle.area.rawValue == "area")
        #expect(PrismSparklineStyle.bar.rawValue == "bar")
    }
}

// MARK: - Charts: PrismRadarAxis & PrismRadarDataSet

@Suite("RadarChartDataCov")
struct PrismRadarChartDataCoverageTests {
    @Test("radar axis init")
    func axisInit() {
        let axis = PrismRadarAxis(label: "Speed", maxValue: 100)
        #expect(axis.label == "Speed")
        #expect(axis.maxValue == 100)
    }

    @Test("radar axis hashable")
    func axisHashable() {
        let a = PrismRadarAxis(label: "X", maxValue: 50)
        let b = PrismRadarAxis(label: "X", maxValue: 50)
        #expect(a == b)
    }

    @Test("radar dataset init")
    func dataSetInit() {
        let ds = PrismRadarDataSet(values: [10, 20, 30], color: .blue, label: "Team A")
        #expect(ds.values == [10, 20, 30])
        #expect(ds.label == "Team A")
    }

    @Test("radar dataset hashable")
    func dataSetHashable() {
        let a = PrismRadarDataSet(values: [1, 2], color: .red, label: "X")
        let b = PrismRadarDataSet(values: [1, 2], color: .red, label: "X")
        #expect(a == b)
    }
}

// MARK: - Animation: PrismSpringConfig extended

@Suite("SpringConfigExtCov")
struct PrismSpringConfigExtendedTests {
    @Test("all presets exist")
    func allPresets() {
        let presets: [PrismSpringConfig] = [
            .snappy, .gentle, .bouncy, .stiff, .dramatic, .critical, .rubber,
        ]
        #expect(presets.count == 7)
        for p in presets {
            #expect(p.response > 0)
            #expect(p.dampingFraction > 0)
        }
    }

    @Test("snappy values")
    func snappyValues() {
        #expect(PrismSpringConfig.snappy.response == 0.25)
        #expect(PrismSpringConfig.snappy.dampingFraction == 0.8)
        #expect(PrismSpringConfig.snappy.blendDuration == 0)
    }

    @Test("critical is critically damped")
    func criticalDamping() {
        #expect(PrismSpringConfig.critical.dampingFraction == 1.0)
    }

    @Test("custom init")
    func customInit() {
        let c = PrismSpringConfig(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)
        #expect(c.response == 0.3)
        #expect(c.dampingFraction == 0.6)
        #expect(c.blendDuration == 0.1)
    }

    @Test("hashable")
    func hashable() {
        let a = PrismSpringConfig(response: 0.3, dampingFraction: 0.6)
        let b = PrismSpringConfig(response: 0.3, dampingFraction: 0.6)
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }

    @Test("animation property returns Animation")
    func animationProperty() {
        let config = PrismSpringConfig.bouncy
        _ = config.animation
    }
}

// MARK: - Accessibility: PrismContrastLevel

@Suite("ContrastLevelCov")
struct PrismContrastLevelCoverageTests {
    @Test("all cases")
    func allCases() {
        let cases = PrismContrastLevel.allCases
        #expect(cases.count == 4)
    }

    @Test("minimum ratios")
    func minimumRatios() {
        #expect(PrismContrastLevel.aa.minimumRatio == 4.5)
        #expect(PrismContrastLevel.aaa.minimumRatio == 7.0)
        #expect(PrismContrastLevel.aaLargeText.minimumRatio == 3.0)
        #expect(PrismContrastLevel.aaaLargeText.minimumRatio == 4.5)
    }

    @Test("raw values")
    func rawValues() {
        #expect(PrismContrastLevel.aa.rawValue == "aa")
        #expect(PrismContrastLevel.aaa.rawValue == "aaa")
        #expect(PrismContrastLevel.aaLargeText.rawValue == "aaLargeText")
        #expect(PrismContrastLevel.aaaLargeText.rawValue == "aaaLargeText")
    }
}

// MARK: - Accessibility: PrismContrastChecker

@Suite("ContrastCheckerCov")
struct PrismContrastCheckerCoverageTests {
    @Test("white on black has high ratio")
    func whiteOnBlack() {
        let ratio = PrismContrastChecker.contrastRatio(between: .white, and: .black)
        #expect(ratio >= 20.0)
    }

    @Test("same color has ratio ~1")
    func sameColor() {
        let ratio = PrismContrastChecker.contrastRatio(between: .red, and: .red)
        #expect(ratio >= 0.99)
        #expect(ratio <= 1.01)
    }

    @Test("meets AA for white on black")
    func meetsAA() {
        #expect(PrismContrastChecker.meetsLevel(.aa, foreground: .white, background: .black))
    }

    @Test("luminance of black is ~0")
    func blackLuminance() {
        let l = PrismContrastChecker.relativeLuminance(of: .black)
        #expect(l < 0.01)
    }

    @Test("luminance of white is ~1")
    func whiteLuminance() {
        let l = PrismContrastChecker.relativeLuminance(of: .white)
        #expect(l > 0.99)
    }
}

// MARK: - Accessibility: PrismAnnouncementPriority

@Suite("AnnouncePriorityCov")
struct PrismAnnouncementPriorityCoverageTests {
    @Test("all cases")
    func allCases() {
        let cases = PrismAnnouncementPriority.allCases
        #expect(cases.count == 2)
        #expect(cases.contains(.polite))
        #expect(cases.contains(.assertive))
    }

    @Test("raw values")
    func rawValues() {
        #expect(PrismAnnouncementPriority.polite.rawValue == "polite")
        #expect(PrismAnnouncementPriority.assertive.rawValue == "assertive")
    }
}

// MARK: - Accessibility: PrismColorBlindnessType

@Suite("ColorBlindCov")
struct PrismColorBlindnessTypeCoverageTests {
    @Test("all cases count")
    func allCases() {
        #expect(PrismColorBlindnessType.allCases.count == 7)
    }

    @Test("matrix is 3x3 for all types")
    func matrixShape() {
        for type in PrismColorBlindnessType.allCases {
            let m = type.matrix
            #expect(m.count == 3)
            for row in m {
                #expect(row.count == 3)
            }
        }
    }

    @Test("matrix rows sum to ~1")
    func matrixRowSums() {
        for type in PrismColorBlindnessType.allCases {
            for row in type.matrix {
                let sum = row.reduce(0, +)
                #expect(sum > 0.99 && sum < 1.01, "Row sum \(sum) for \(type)")
            }
        }
    }

    @Test("raw values")
    func rawValues() {
        #expect(PrismColorBlindnessType.protanopia.rawValue == "protanopia")
        #expect(PrismColorBlindnessType.deuteranopia.rawValue == "deuteranopia")
        #expect(PrismColorBlindnessType.achromatopsia.rawValue == "achromatopsia")
    }
}

// MARK: - Haptics: PrismHapticType

@Suite("HapticTypeCov")
struct PrismHapticTypeCoverageTests {
    @Test("impact cases")
    func impactCases() {
        let weights: [PrismImpactWeight] = [.light, .medium, .heavy, .soft, .rigid]
        for w in weights {
            let t = PrismHapticType.impact(w)
            if case .impact(let inner) = t {
                #expect(inner == w)
            } else {
                #expect(Bool(false))
            }
        }
    }

    @Test("notification cases")
    func notificationCases() {
        let styles: [PrismNotificationStyle] = [.success, .warning, .error]
        for s in styles {
            let t = PrismHapticType.notification(s)
            if case .notification(let inner) = t {
                #expect(inner == s)
            } else {
                #expect(Bool(false))
            }
        }
    }

    @Test("selection case")
    func selectionCase() {
        let t = PrismHapticType.selection
        if case .selection = t {
            #expect(Bool(true))
        } else {
            #expect(Bool(false))
        }
    }
}

// MARK: - Forms: PrismValidationRule

@Suite("ValidationRuleExtCov")
struct PrismValidationRuleExtendedTests {
    @Test("required rejects empty")
    func requiredEmpty() {
        #expect(PrismValidationRule.required.validate("") == false)
        #expect(PrismValidationRule.required.validate("   ") == false)
        #expect(PrismValidationRule.required.validate("\n") == false)
    }

    @Test("required accepts non-empty")
    func requiredNonEmpty() {
        #expect(PrismValidationRule.required.validate("hello") == true)
    }

    @Test("minLength")
    func minLength() {
        let rule = PrismValidationRule.minLength(3)
        #expect(rule.validate("ab") == false)
        #expect(rule.validate("abc") == true)
        #expect(rule.validate("abcd") == true)
        #expect(!rule.message.isEmpty)
    }

    @Test("maxLength")
    func maxLength() {
        let rule = PrismValidationRule.maxLength(5)
        #expect(rule.validate("abc") == true)
        #expect(rule.validate("abcde") == true)
        #expect(rule.validate("abcdef") == false)
    }

    @Test("email validation")
    func email() {
        #expect(PrismValidationRule.email.validate("test@example.com") == true)
        #expect(PrismValidationRule.email.validate("user.name+tag@domain.co") == true)
        #expect(PrismValidationRule.email.validate("invalid") == false)
        #expect(PrismValidationRule.email.validate("@no.user") == false)
        #expect(PrismValidationRule.email.validate("no@") == false)
    }

    @Test("regex custom")
    func regexCustom() {
        let rule = PrismValidationRule.regex(#"^\d{3}$"#, message: "Must be 3 digits")
        #expect(rule.validate("123") == true)
        #expect(rule.validate("12") == false)
        #expect(rule.validate("abc") == false)
        #expect(rule.message == "Must be 3 digits")
    }

    @Test("range validation")
    func rangeRule() {
        let rule = PrismValidationRule.range(1...100)
        #expect(rule.validate("50") == true)
        #expect(rule.validate("1") == true)
        #expect(rule.validate("100") == true)
        #expect(rule.validate("0") == false)
        #expect(rule.validate("101") == false)
        #expect(rule.validate("abc") == false)
    }

    @Test("custom rule")
    func customRule() {
        let rule = PrismValidationRule(
            validate: { $0.hasPrefix("X") },
            message: "Must start with X"
        )
        #expect(rule.validate("XYZ") == true)
        #expect(rule.validate("ABC") == false)
    }
}

// MARK: - Internationalization: PrismPluralRule extended

@Suite("PluralRuleExtCov")
struct PrismPluralRuleExtendedTests {
    @Test("arabic zero")
    func arabicZero() {
        let rule = PrismPluralRule.shared
        let ar = Locale(identifier: "ar")
        #expect(rule.category(for: 0, locale: ar) == .zero)
    }

    @Test("arabic one")
    func arabicOne() {
        let rule = PrismPluralRule.shared
        let ar = Locale(identifier: "ar")
        #expect(rule.category(for: 1, locale: ar) == .one)
    }

    @Test("arabic two")
    func arabicTwo() {
        let rule = PrismPluralRule.shared
        let ar = Locale(identifier: "ar")
        #expect(rule.category(for: 2, locale: ar) == .two)
    }

    @Test("arabic few (3-10 mod100)")
    func arabicFew() {
        let rule = PrismPluralRule.shared
        let ar = Locale(identifier: "ar")
        #expect(rule.category(for: 3, locale: ar) == .few)
        #expect(rule.category(for: 10, locale: ar) == .few)
        #expect(rule.category(for: 103, locale: ar) == .few)
    }

    @Test("arabic many (11-99 mod100)")
    func arabicMany() {
        let rule = PrismPluralRule.shared
        let ar = Locale(identifier: "ar")
        #expect(rule.category(for: 11, locale: ar) == .many)
        #expect(rule.category(for: 99, locale: ar) == .many)
    }

    @Test("arabic other")
    func arabicOther() {
        let rule = PrismPluralRule.shared
        let ar = Locale(identifier: "ar")
        #expect(rule.category(for: 100, locale: ar) == .other)
    }

    @Test("russian one")
    func russianOne() {
        let rule = PrismPluralRule.shared
        let ru = Locale(identifier: "ru")
        #expect(rule.category(for: 1, locale: ru) == .one)
        #expect(rule.category(for: 21, locale: ru) == .one)
        #expect(rule.category(for: 101, locale: ru) == .one)
    }

    @Test("russian few")
    func russianFew() {
        let rule = PrismPluralRule.shared
        let ru = Locale(identifier: "ru")
        #expect(rule.category(for: 2, locale: ru) == .few)
        #expect(rule.category(for: 3, locale: ru) == .few)
        #expect(rule.category(for: 4, locale: ru) == .few)
        #expect(rule.category(for: 22, locale: ru) == .few)
    }

    @Test("russian many")
    func russianMany() {
        let rule = PrismPluralRule.shared
        let ru = Locale(identifier: "ru")
        #expect(rule.category(for: 0, locale: ru) == .many)
        #expect(rule.category(for: 5, locale: ru) == .many)
        #expect(rule.category(for: 11, locale: ru) == .many)
        #expect(rule.category(for: 14, locale: ru) == .many)
    }

    @Test("japanese always other")
    func japaneseOther() {
        let rule = PrismPluralRule.shared
        let ja = Locale(identifier: "ja")
        #expect(rule.category(for: 0, locale: ja) == .other)
        #expect(rule.category(for: 1, locale: ja) == .other)
        #expect(rule.category(for: 100, locale: ja) == .other)
    }

    @Test("english defaults")
    func englishDefaults() {
        let rule = PrismPluralRule.shared
        let en = Locale(identifier: "en")
        #expect(rule.category(for: 1, locale: en) == .one)
        #expect(rule.category(for: 0, locale: en) == .other)
        #expect(rule.category(for: 2, locale: en) == .other)
    }

    @Test("unknown language defaults to english")
    func unknownFallback() {
        let rule = PrismPluralRule.shared
        let xx = Locale(identifier: "xx")
        #expect(rule.category(for: 1, locale: xx) == .one)
        #expect(rule.category(for: 5, locale: xx) == .other)
    }
}

// MARK: - Internationalization: PrismPluralCategory

@Suite("PluralCatCov")
struct PrismPluralCategoryCoverageTests {
    @Test("all cases count")
    func allCases() {
        #expect(PrismPluralCategory.allCases.count == 6)
    }

    @Test("raw values")
    func rawValues() {
        #expect(PrismPluralCategory.zero.rawValue == "zero")
        #expect(PrismPluralCategory.one.rawValue == "one")
        #expect(PrismPluralCategory.two.rawValue == "two")
        #expect(PrismPluralCategory.few.rawValue == "few")
        #expect(PrismPluralCategory.many.rawValue == "many")
        #expect(PrismPluralCategory.other.rawValue == "other")
    }
}

// MARK: - Internationalization: PrismNumberFormatter

@Suite("NumberFmtCov")
struct PrismNumberFormatterCoverageTests {
    @Test("decimal format")
    func decimal() {
        let fmt = PrismNumberFormatter.shared
        let result = fmt.format(1234.567, style: .decimal, locale: Locale(identifier: "en_US"))
        #expect(result.contains("1") && result.contains("234"))
    }

    @Test("currency format")
    func currency() {
        let fmt = PrismNumberFormatter.shared
        let result = fmt.format(99.99, style: .currency(code: "USD"), locale: Locale(identifier: "en_US"))
        #expect(result.contains("99"))
    }

    @Test("percent format")
    func percent() {
        let fmt = PrismNumberFormatter.shared
        let result = fmt.format(0.42, style: .percent, locale: Locale(identifier: "en_US"))
        #expect(result.contains("42"))
    }

    @Test("scientific format")
    func scientific() {
        let fmt = PrismNumberFormatter.shared
        let result = fmt.format(12345.0, style: .scientific, locale: Locale(identifier: "en_US"))
        #expect(result.contains("E") || result.contains("e"))
    }
}

// MARK: - Internationalization: PrismDateFormatter

@Suite("DateFmtCov")
struct PrismDateFormatterCoverageTests {
    @Test("short format")
    func short() {
        let fmt = PrismDateFormatter.shared
        let date = Date(timeIntervalSince1970: 1_000_000_000)
        let result = fmt.format(date, style: .short, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }

    @Test("medium format")
    func medium() {
        let fmt = PrismDateFormatter.shared
        let date = Date(timeIntervalSince1970: 1_000_000_000)
        let result = fmt.format(date, style: .medium, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }

    @Test("long format")
    func long() {
        let fmt = PrismDateFormatter.shared
        let date = Date(timeIntervalSince1970: 1_000_000_000)
        let result = fmt.format(date, style: .long, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }

    @Test("full format")
    func full() {
        let fmt = PrismDateFormatter.shared
        let date = Date(timeIntervalSince1970: 1_000_000_000)
        let result = fmt.format(date, style: .full, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }

    @Test("relative format")
    func relative() {
        let fmt = PrismDateFormatter.shared
        let date = Date(timeIntervalSince1970: 0)
        let result = fmt.format(date, style: .relative, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }
}

// MARK: - Internationalization: PrismRelativeTimeFormatter

@Suite("RelTimeFmtCov")
struct PrismRelativeTimeFormatterCoverageTests {
    @Test("format relative")
    func formatRelative() {
        let fmt = PrismRelativeTimeFormatter.shared
        let past = Date(timeIntervalSince1970: 1_000_000)
        let now = Date(timeIntervalSince1970: 1_100_000)
        let result = fmt.format(past, relativeTo: now, locale: Locale(identifier: "en_US"))
        #expect(!result.isEmpty)
    }
}

// MARK: - Internationalization: PrismLayoutDirection & PrismDirectionalEdge

@Suite("DirectionalEdgeCov")
struct PrismDirectionalEdgeCoverageTests {
    @Test("all cases")
    func allCases() {
        #expect(PrismDirectionalEdge.allCases.count == 2)
    }

    @Test("leading resolved LTR")
    func leadingLTR() {
        let edge = PrismDirectionalEdge.leading.resolved(for: .leftToRight)
        #expect(edge == .leading)
    }

    @Test("trailing resolved LTR")
    func trailingLTR() {
        let edge = PrismDirectionalEdge.trailing.resolved(for: .leftToRight)
        #expect(edge == .trailing)
    }

    @Test("leading resolved RTL")
    func leadingRTL() {
        let edge = PrismDirectionalEdge.leading.resolved(for: .rightToLeft)
        #expect(edge == .trailing)
    }

    @Test("trailing resolved RTL")
    func trailingRTL() {
        let edge = PrismDirectionalEdge.trailing.resolved(for: .rightToLeft)
        #expect(edge == .leading)
    }
}

@Suite("LayoutDirCov")
struct PrismLayoutDirectionBatch3Tests {
    @Test("all cases")
    func allCases() {
        #expect(PrismLayoutDirection.allCases.count == 3)
        #expect(PrismLayoutDirection.allCases.contains(.leftToRight))
        #expect(PrismLayoutDirection.allCases.contains(.rightToLeft))
        #expect(PrismLayoutDirection.allCases.contains(.auto))
    }
}

// MARK: - Internationalization: PrismLocalizedKey

@Suite("LocalizedKeyCov")
@MainActor
struct PrismLocalizedKeyCoverageTests {
    @Test("init stores fields")
    func initFields() {
        let key = PrismLocalizedKey(key: "greeting", comment: "Hello message")
        #expect(key.key == "greeting")
        #expect(key.comment == "Hello message")
        #expect(key.table == nil)
        #expect(key.id == "greeting")
    }

    @Test("with table")
    func withTable() {
        let key = PrismLocalizedKey(key: "title", comment: "Screen title", table: "Main")
        #expect(key.table == "Main")
    }

    @Test("localizedStringKey")
    func localizedStringKey() {
        let key = PrismLocalizedKey(key: "test.key", comment: "Test")
        _ = key.localizedStringKey
    }
}

// MARK: - Internationalization: PrismStringExporter

@Suite("StringExporterCov")
@MainActor
struct PrismStringExporterCoverageTests {
    @Test("register and export")
    func registerExport() {
        let exporter = PrismStringExporter()
        let key = PrismLocalizedKey(key: "module.title", comment: "Title")
        exporter.register(key)
        let exported = exporter.exportKeys(from: "module")
        #expect(exported.count == 1)
        #expect(exported[0].key == "module.title")
    }

    @Test("register deduplicates")
    func dedup() {
        let exporter = PrismStringExporter()
        let key = PrismLocalizedKey(key: "dup.key", comment: "A")
        exporter.register(key)
        exporter.register(key)
        #expect(exporter.keys.count == 1)
    }

    @Test("export with empty module returns all")
    func exportAll() {
        let exporter = PrismStringExporter()
        exporter.register(PrismLocalizedKey(key: "a.one", comment: ""))
        exporter.register(PrismLocalizedKey(key: "b.two", comment: ""))
        let all = exporter.exportKeys(from: "")
        #expect(all.count == 2)
    }

    @Test("reset clears keys")
    func reset() {
        let exporter = PrismStringExporter()
        exporter.register(PrismLocalizedKey(key: "test", comment: ""))
        exporter.reset()
        #expect(exporter.keys.isEmpty)
    }
}

// MARK: - Performance: PrismMemorySnapshot

@Suite("MemSnapshotCov")
struct PrismMemorySnapshotCoverageTests {
    @Test("init stores fields")
    func initFields() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let s = PrismMemorySnapshot(timestamp: date, usedBytes: 1024, peakBytes: 2048)
        #expect(s.timestamp == date)
        #expect(s.usedBytes == 1024)
        #expect(s.peakBytes == 2048)
    }
}

// MARK: - Performance: PrismMemoryTrackerV2

@Suite("MemTrackerCov")
@MainActor
struct PrismMemoryTrackerV2CoverageTests {
    @Test("initial state")
    func initialState() {
        let tracker = PrismMemoryTrackerV2()
        #expect(tracker.snapshots.isEmpty)
        #expect(tracker.currentUsage == 0)
    }

    @Test("take snapshot adds entry")
    func takeSnapshot() {
        let tracker = PrismMemoryTrackerV2()
        let snap = tracker.takeSnapshot()
        #expect(tracker.snapshots.count == 1)
        #expect(snap.usedBytes > 0 || snap.usedBytes == 0)
    }

    @Test("reset clears snapshots")
    func reset() {
        let tracker = PrismMemoryTrackerV2()
        tracker.takeSnapshot()
        tracker.reset()
        #expect(tracker.snapshots.isEmpty)
    }

    @Test("multiple snapshots accumulate")
    func multipleSnapshots() {
        let tracker = PrismMemoryTrackerV2()
        tracker.takeSnapshot()
        tracker.takeSnapshot()
        tracker.takeSnapshot()
        #expect(tracker.snapshots.count == 3)
    }
}

// MARK: - Performance: PrismRenderMetrics

@Suite("RenderMetricsCov")
struct PrismRenderMetricsCoverageTests {
    @Test("default init")
    func defaultInit() {
        let m = PrismRenderMetrics()
        #expect(m.renderCount == 0)
        #expect(m.lastRenderTime == nil)
        #expect(m.averageRenderTime == nil)
    }

    @Test("custom init")
    func customInit() {
        let d = Duration.seconds(1)
        let m = PrismRenderMetrics(renderCount: 5, lastRenderTime: d, averageRenderTime: d)
        #expect(m.renderCount == 5)
        #expect(m.lastRenderTime == d)
        #expect(m.averageRenderTime == d)
    }
}

// MARK: - Performance: PrismRenderProfiler

@Suite("RenderProfilerCov")
@MainActor
struct PrismRenderProfilerCoverageTests {
    @Test("initial state empty")
    func initialState() {
        let profiler = PrismRenderProfiler()
        #expect(profiler.metrics.isEmpty)
    }

    @Test("record render creates entry")
    func recordRender() {
        let profiler = PrismRenderProfiler()
        profiler.recordRender(name: "TestView", duration: .milliseconds(10))
        #expect(profiler.metrics["TestView"] != nil)
        #expect(profiler.metrics["TestView"]?.renderCount == 1)
    }

    @Test("multiple records accumulate")
    func multipleRecords() {
        let profiler = PrismRenderProfiler()
        profiler.recordRender(name: "V", duration: .milliseconds(10))
        profiler.recordRender(name: "V", duration: .milliseconds(20))
        #expect(profiler.metrics["V"]?.renderCount == 2)
    }

    @Test("reset clears all")
    func reset() {
        let profiler = PrismRenderProfiler()
        profiler.recordRender(name: "X", duration: .milliseconds(5))
        profiler.reset()
        #expect(profiler.metrics.isEmpty)
    }
}

// MARK: - Performance: PrismPrefetchCoordinator

@Suite("PrefetchCoordCov")
@MainActor
struct PrismPrefetchCoordinatorCoverageTests {
    @Test("initial state")
    func initialState() {
        let coord = PrismPrefetchCoordinator()
        #expect(coord.prefetchables.isEmpty)
        #expect(coord.activeIDs.isEmpty)
    }

    @Test("prefetch creates active tasks")
    func prefetch() {
        let coord = PrismPrefetchCoordinator()
        coord.prefetch(ids: ["a", "b"])
        #expect(coord.activeIDs.contains("a"))
        #expect(coord.activeIDs.contains("b"))
    }

    @Test("cancel removes active tasks")
    func cancelPrefetch() {
        let coord = PrismPrefetchCoordinator()
        coord.prefetch(ids: ["a", "b"])
        coord.cancelPrefetch(ids: ["a"])
        #expect(!coord.activeIDs.contains("a"))
        #expect(coord.activeIDs.contains("b"))
    }

    @Test("reset clears everything")
    func reset() {
        let coord = PrismPrefetchCoordinator()
        coord.prefetch(ids: ["x"])
        coord.reset()
        #expect(coord.activeIDs.isEmpty)
        #expect(coord.prefetchables.isEmpty)
    }

    @Test("duplicate prefetch is idempotent")
    func duplicatePrefetch() {
        let coord = PrismPrefetchCoordinator()
        coord.prefetch(ids: ["a"])
        coord.prefetch(ids: ["a"])
        #expect(coord.activeIDs.count == 1)
    }
}

// MARK: - SwiftData: PrismSyncState

#if canImport(SwiftData)
    @Suite("SyncStateCov")
    struct PrismSyncStateCoverageTests {
        @Test("equatable idle")
        func equatableIdle() {
            #expect(PrismSyncState.idle == PrismSyncState.idle)
        }

        @Test("equatable syncing")
        func equatableSyncing() {
            #expect(PrismSyncState.syncing == PrismSyncState.syncing)
        }

        @Test("equatable synced")
        func equatableSynced() {
            #expect(PrismSyncState.synced == PrismSyncState.synced)
        }

        @Test("equatable error")
        func equatableError() {
            #expect(PrismSyncState.error("oops") == PrismSyncState.error("oops"))
            #expect(PrismSyncState.error("a") != PrismSyncState.error("b"))
        }

        @Test("not equal different cases")
        func notEqualDifferent() {
            #expect(PrismSyncState.idle != PrismSyncState.syncing)
            #expect(PrismSyncState.synced != PrismSyncState.error("x"))
        }
    }

    @Suite("CloudSyncMonCov")
    @MainActor
    struct PrismCloudSyncMonitorCoverageTests {
        @Test("initial state is idle")
        func initialState() {
            let monitor = PrismCloudSyncMonitor()
            #expect(monitor.state == .idle)
            #expect(monitor.lastSyncDate == nil)
        }

        @Test("start monitoring sets syncing")
        func startMonitoring() {
            let monitor = PrismCloudSyncMonitor()
            monitor.startMonitoring()
            #expect(monitor.state == .syncing)
        }

        @Test("update state to synced sets date")
        func updateToSynced() {
            let monitor = PrismCloudSyncMonitor()
            monitor.updateState(.synced)
            #expect(monitor.state == .synced)
            #expect(monitor.lastSyncDate != nil)
        }

        @Test("update state to error does not set date")
        func updateToError() {
            let monitor = PrismCloudSyncMonitor()
            monitor.updateState(.error("fail"))
            #expect(monitor.state == .error("fail"))
            #expect(monitor.lastSyncDate == nil)
        }
    }
#endif

// MARK: - Composites: PrismToast.Style

@Suite("ToastStyleCov")
struct PrismToastStyleCoverageTests {
    @Test("all styles exist")
    func allStyles() {
        let _: PrismToast.Style = .neutral
        let _: PrismToast.Style = .success
        let _: PrismToast.Style = .error
        let _: PrismToast.Style = .info
    }
}

// MARK: - Internationalization: PrismNumberStyle & PrismDateStyle

@Suite("NumberStyleCov")
struct PrismNumberStyleCoverageTests {
    @Test("all styles construct")
    func allStyles() {
        let _: PrismNumberStyle = .decimal
        let _: PrismNumberStyle = .currency(code: "USD")
        let _: PrismNumberStyle = .percent
        let _: PrismNumberStyle = .scientific
    }
}

@Suite("DateStyleCov")
struct PrismDateStyleCoverageTests {
    @Test("all styles construct")
    func allStyles() {
        let _: PrismDateStyle = .short
        let _: PrismDateStyle = .medium
        let _: PrismDateStyle = .long
        let _: PrismDateStyle = .full
        let _: PrismDateStyle = .relative
    }
}
