import Foundation
import NaturalLanguage
import Testing

@testable import RyzeFoundation

struct RyzeLocaleTests {
    @Test(arguments: RyzeLocale.allCases)
    func localeMetadataIsConsistent(locale: RyzeLocale) {
        #expect(locale.rawValue.identifier == locale.identifier)
        #expect(locale.emoji.isEmpty == false)
        #expect(locale.description.contains(locale.emoji))
        #expect(locale.languageCode == locale.rawValue.language.languageCode?.identifier)
        #expect(locale.currencyCode.isEmpty == false)
        #expect(locale.dateFormatStyle.locale == locale.rawValue)
    }

    @Test
    func localeSpecificMappingsMatchExpectedValues() {
        #expect(RyzeLocale.englishUS.naturalLanguage == NLLanguage.english)
        #expect(RyzeLocale.portugueseBR.naturalLanguage == NLLanguage.portuguese)
        #expect(RyzeLocale.spanishES.naturalLanguage == NLLanguage.spanish)
        #expect(RyzeLocale.frenchFR.naturalLanguage == NLLanguage.french)
        #expect(RyzeLocale.germanDE.naturalLanguage == NLLanguage.german)
        #expect(RyzeLocale.arabicSA.naturalLanguage == NLLanguage.arabic)
        #expect(RyzeLocale.japaneseJP.naturalLanguage == NLLanguage.japanese)
        #expect(RyzeLocale.chineseCN.naturalLanguage == NLLanguage.simplifiedChinese)
        #expect(RyzeLocale.englishUS.currencyCode == "USD")
        #expect(RyzeLocale.portugueseBR.currencyCode == "BRL")
        #expect(RyzeLocale.arabicSA.isRTL)
        #expect(RyzeLocale.englishUS.isRTL == false)
    }

    @Test
    func localeCalendarsAdaptToSpecificRegions() {
        #expect(RyzeLocale.englishUS.calendar.identifier == .gregorian)
        #expect(RyzeLocale.japaneseJP.calendar.identifier == .japanese)
        #expect(RyzeLocale.arabicSA.calendar.identifier == .islamicUmmAlQura)
    }

    @Test
    func currentLocaleUsesSameSelectionRuleAsImplementation() {
        let currentLanguageCode = Locale.current.language.languageCode?.identifier
        let expected = RyzeLocale.match(languageCode: currentLanguageCode)

        #expect(RyzeLocale.current == expected)
    }

    @Test
    func unsupportedLanguageCodesFallBackToEnglishUS() {
        #expect(RyzeLocale.match(languageCode: "xx") == .englishUS)
        #expect(RyzeLocale.match(languageCode: nil) == .englishUS)
    }

    @Test
    func codableRoundTripsAllLocales() throws {
        let encoded = try JSONEncoder().encode(RyzeLocale.allCases)
        let decoded = try JSONDecoder().decode([RyzeLocale].self, from: encoded)

        #expect(decoded == RyzeLocale.allCases)
    }
}
