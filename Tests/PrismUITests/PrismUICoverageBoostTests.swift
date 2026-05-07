import Foundation
import Testing

@testable import PrismUI

// MARK: - PrismSyntaxHighlighter deep coverage

@Suite("SyntaxHL")
struct PrismSyntaxHighlighterCoverageTests {
    let hl = PrismSyntaxHighlighter()

    @Test("multi-line comment tokenization")
    func multiLineComment() {
        let code = "/* block */\nlet x = 1"
        let result = hl.highlight(code, language: .swift)
        #expect(String(result.characters).contains("block"))
    }

    @Test("Python hash comment")
    func pythonComment() {
        let code = "# comment\nx = 1"
        let result = hl.highlight(code, language: .python)
        #expect(String(result.characters).contains("comment"))
    }

    @Test("HTML comment")
    func htmlComment() {
        let code = "<!-- comment -->\n<p>hi</p>"
        let result = hl.highlight(code, language: .html)
        #expect(String(result.characters).contains("comment"))
    }

    @Test("string with single quotes")
    func singleQuoteString() {
        let code = "let s = 'hello'"
        let result = hl.highlight(code, language: .javascript)
        #expect(String(result.characters).contains("hello"))
    }

    @Test("escaped character in string")
    func escapedString() {
        let code = #"let s = "he\"llo""#
        let result = hl.highlight(code, language: .swift)
        #expect(!result.characters.isEmpty)
    }

    @Test("number literal tokenization")
    func numberLiteral() {
        let code = "let x = 3.14"
        let result = hl.highlight(code, language: .swift)
        #expect(String(result.characters).contains("3.14"))
    }

    @Test("keyword detection for Swift")
    func swiftKeywords() {
        let code = "struct Foo: Sendable { let bar: Int }"
        let result = hl.highlight(code, language: .swift)
        #expect(String(result.characters).contains("struct"))
    }

    @Test("keyword detection for JavaScript")
    func jsKeywords() {
        let code = "function hello() { const x = 42; return x; }"
        let result = hl.highlight(code, language: .javascript)
        #expect(String(result.characters).contains("function"))
    }

    @Test("keyword detection for Python")
    func pyKeywords() {
        let code = "def hello():\n    pass"
        let result = hl.highlight(code, language: .python)
        #expect(String(result.characters).contains("def"))
    }

    @Test("CSS hash comment")
    func cssComment() {
        let code = "/* color */ .red { color: red; }"
        let result = hl.highlight(code, language: .css)
        #expect(!result.characters.isEmpty)
    }

    @Test("CSS keywords")
    func cssKeywords() {
        let code = "body { display: flex; margin: 0; }"
        let result = hl.highlight(code, language: .css)
        #expect(String(result.characters).contains("display"))
    }

    @Test("HTML tags")
    func htmlTags() {
        let code = "<div class=\"test\"><span>Hello</span></div>"
        let result = hl.highlight(code, language: .html)
        #expect(String(result.characters).contains("div"))
    }

    @Test("JSON tokens")
    func jsonHighlight() {
        let code = """
            {"key": "value", "num": 42, "flag": true}
            """
        let result = hl.highlight(code, language: .json)
        #expect(String(result.characters).contains("key"))
    }

    @Test("empty code returns empty")
    func emptyCode() {
        let result = hl.highlight("", language: .swift)
        #expect(result.characters.isEmpty)
    }

    @Test("underscore in number literal")
    func underscoreNumber() {
        let code = "let x = 1_000_000"
        let result = hl.highlight(code, language: .swift)
        #expect(String(result.characters).contains("1_000_000"))
    }

    @Test("decimal starting with dot")
    func dotDecimal() {
        let code = "let x = .5"
        let result = hl.highlight(code, language: .swift)
        #expect(String(result.characters).contains(".5"))
    }

    @Test("type detection uppercase word")
    func typeDetection() {
        let code = "let x: String = \"\""
        let result = hl.highlight(code, language: .swift)
        #expect(String(result.characters).contains("String"))
    }

    @Test("punctuation tokens")
    func punctuation() {
        let code = "x = (1 + 2)"
        let result = hl.highlight(code, language: .swift)
        #expect(String(result.characters).contains("("))
    }

    @Test("multi-line code block")
    func multiLine() {
        let code = """
            // comment
            let x = 42
            /* block
            comment */
            let y = "hello"
            """
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("comment"))
        #expect(text.contains("42"))
        #expect(text.contains("hello"))
    }
}

// MARK: - PrismSyntaxLanguage

@Suite("SyntaxLang")
struct PrismSyntaxLanguageExtraTests {
    @Test("fileExtension for all cases")
    func fileExtensions() {
        #expect(PrismSyntaxLanguage.swift.fileExtension == "swift")
        #expect(PrismSyntaxLanguage.json.fileExtension == "json")
        #expect(PrismSyntaxLanguage.html.fileExtension == "html")
        #expect(PrismSyntaxLanguage.css.fileExtension == "css")
        #expect(PrismSyntaxLanguage.javascript.fileExtension == "js")
        #expect(PrismSyntaxLanguage.python.fileExtension == "py")
        #expect(PrismSyntaxLanguage.plainText.fileExtension == "txt")
    }

    @Test("raw values are correct")
    func rawValues() {
        #expect(PrismSyntaxLanguage.swift.rawValue == "swift")
        #expect(PrismSyntaxLanguage.javascript.rawValue == "javascript")
    }
}

// MARK: - PrismPredicateBuilder

#if canImport(SwiftData)
    @Suite("PredBuilder")
    struct PrismPredicateBuilderCoverageTests {
        @Test("where adds single filter")
        func singleWhere() {
            let builder = PrismPredicateBuilder()
                .where("name", .equals, "John")
            let filters = builder.build()
            #expect(filters.count == 1)
            #expect(filters[0].name == "name")
            #expect(filters[0].operator == .equals)
        }

        @Test("and chains multiple filters")
        func andChain() {
            let filters = PrismPredicateBuilder()
                .where("age", .greaterThan, 18)
                .and("name", .contains, "J")
                .build()
            #expect(filters.count == 2)
            #expect(filters[0].operator == .greaterThan)
            #expect(filters[1].operator == .contains)
        }

        @Test("or adds filter")
        func orFilter() {
            let filters = PrismPredicateBuilder()
                .where("status", .equals, "active")
                .or("status", .equals, "pending")
                .build()
            #expect(filters.count == 2)
        }

        @Test("empty builder returns empty")
        func emptyBuild() {
            let filters = PrismPredicateBuilder().build()
            #expect(filters.isEmpty)
        }

        @Test("all operators available")
        func allOperators() {
            let ops = PrismFilterOperator.allCases
            #expect(ops.count == 7)
            #expect(ops.contains(.equals))
            #expect(ops.contains(.contains))
            #expect(ops.contains(.greaterThan))
            #expect(ops.contains(.lessThan))
            #expect(ops.contains(.between))
            #expect(ops.contains(.isNil))
            #expect(ops.contains(.isNotNil))
        }

        @Test("PrismFilterField stores properties")
        func filterFieldProps() {
            let field = PrismFilterField(name: "score", operator: .lessThan, value: 100)
            #expect(field.name == "score")
            #expect(field.operator == .lessThan)
        }

        @Test("PrismFilterField nil value")
        func filterFieldNilValue() {
            let field = PrismFilterField(name: "deleted", operator: .isNil)
            #expect(field.name == "deleted")
            #expect(field.operator == .isNil)
        }

        @Test("chain where and or builds 3 filters")
        func tripleChain() {
            let filters = PrismPredicateBuilder()
                .where("a", .equals, 1)
                .and("b", .greaterThan, 2)
                .or("c", .lessThan, 3)
                .build()
            #expect(filters.count == 3)
        }
    }
#endif

// MARK: - PrismFormValidator

@Suite("FormValidator")
struct PrismFormValidatorCoverageTests {
    @Test("required rejects empty string")
    func requiredEmpty() {
        #expect(!PrismValidationRule.required.validate(""))
    }

    @Test("required rejects whitespace only")
    func requiredWhitespace() {
        #expect(!PrismValidationRule.required.validate("   "))
    }

    @Test("required accepts non-empty")
    func requiredValid() {
        #expect(PrismValidationRule.required.validate("hello"))
    }

    @Test("minLength rejects short string")
    func minLengthShort() {
        let rule = PrismValidationRule.minLength(5)
        #expect(!rule.validate("hi"))
    }

    @Test("minLength accepts exact length")
    func minLengthExact() {
        let rule = PrismValidationRule.minLength(3)
        #expect(rule.validate("abc"))
    }

    @Test("minLength accepts longer")
    func minLengthLonger() {
        let rule = PrismValidationRule.minLength(3)
        #expect(rule.validate("abcdef"))
    }

    @Test("maxLength accepts short string")
    func maxLengthShort() {
        let rule = PrismValidationRule.maxLength(10)
        #expect(rule.validate("hi"))
    }

    @Test("maxLength rejects long string")
    func maxLengthLong() {
        let rule = PrismValidationRule.maxLength(3)
        #expect(!rule.validate("abcdef"))
    }

    @Test("maxLength accepts exact length")
    func maxLengthExact() {
        let rule = PrismValidationRule.maxLength(5)
        #expect(rule.validate("hello"))
    }

    @Test("email validates correct address")
    func emailValid() {
        #expect(PrismValidationRule.email.validate("test@example.com"))
    }

    @Test("email rejects invalid")
    func emailInvalid() {
        #expect(!PrismValidationRule.email.validate("not-an-email"))
    }

    @Test("email rejects empty")
    func emailEmpty() {
        #expect(!PrismValidationRule.email.validate(""))
    }

    @Test("email rejects missing domain")
    func emailNoDomain() {
        #expect(!PrismValidationRule.email.validate("user@"))
    }

    @Test("regex validates matching pattern")
    func regexMatch() {
        let rule = PrismValidationRule.regex(#"^\d{3}$"#, message: "Must be 3 digits")
        #expect(rule.validate("123"))
        #expect(!rule.validate("12"))
        #expect(!rule.validate("abc"))
    }

    @Test("regex message is stored")
    func regexMessage() {
        let rule = PrismValidationRule.regex(".*", message: "Custom msg")
        #expect(rule.message == "Custom msg")
    }

    @Test("range validates within bounds")
    func rangeValid() {
        let rule = PrismValidationRule.range(1...100)
        #expect(rule.validate("50"))
    }

    @Test("range rejects below lower bound")
    func rangeBelow() {
        let rule = PrismValidationRule.range(10...20)
        #expect(!rule.validate("5"))
    }

    @Test("range rejects above upper bound")
    func rangeAbove() {
        let rule = PrismValidationRule.range(10...20)
        #expect(!rule.validate("25"))
    }

    @Test("range rejects non-numeric")
    func rangeNonNumeric() {
        let rule = PrismValidationRule.range(1...100)
        #expect(!rule.validate("abc"))
    }

    @Test("range accepts boundary values")
    func rangeBoundary() {
        let rule = PrismValidationRule.range(1...10)
        #expect(rule.validate("1"))
        #expect(rule.validate("10"))
    }

    @Test("required message is correct")
    func requiredMessage() {
        #expect(PrismValidationRule.required.message == "This field is required")
    }

    @Test("minLength message includes count")
    func minLengthMessage() {
        let rule = PrismValidationRule.minLength(8)
        #expect(rule.message.contains("8"))
    }

    @Test("maxLength message includes count")
    func maxLengthMessage() {
        let rule = PrismValidationRule.maxLength(50)
        #expect(rule.message.contains("50"))
    }

    @Test("range message includes bounds")
    func rangeMessage() {
        let rule = PrismValidationRule.range(5...15)
        #expect(rule.message.contains("5"))
        #expect(rule.message.contains("15"))
    }
}

// MARK: - PrismPluralRule

@Suite("PluralRule")
struct PrismPluralRuleCoverageTests {
    let rule = PrismPluralRule.shared

    @Test("English singular")
    func enSingular() {
        let cat = rule.category(for: 1, locale: Locale(identifier: "en"))
        #expect(cat == .one)
    }

    @Test("English plural")
    func enPlural() {
        let cat = rule.category(for: 5, locale: Locale(identifier: "en"))
        #expect(cat == .other)
    }

    @Test("English zero")
    func enZero() {
        let cat = rule.category(for: 0, locale: Locale(identifier: "en"))
        #expect(cat == .other)
    }

    @Test("Arabic zero")
    func arZero() {
        let cat = rule.category(for: 0, locale: Locale(identifier: "ar"))
        #expect(cat == .zero)
    }

    @Test("Arabic one")
    func arOne() {
        let cat = rule.category(for: 1, locale: Locale(identifier: "ar"))
        #expect(cat == .one)
    }

    @Test("Arabic two")
    func arTwo() {
        let cat = rule.category(for: 2, locale: Locale(identifier: "ar"))
        #expect(cat == .two)
    }

    @Test("Arabic few 3-10")
    func arFew() {
        let cat = rule.category(for: 5, locale: Locale(identifier: "ar"))
        #expect(cat == .few)
    }

    @Test("Arabic many 11-99")
    func arMany() {
        let cat = rule.category(for: 15, locale: Locale(identifier: "ar"))
        #expect(cat == .many)
    }

    @Test("Arabic other 100+")
    func arOther() {
        let cat = rule.category(for: 100, locale: Locale(identifier: "ar"))
        #expect(cat == .other)
    }

    @Test("Russian one mod10=1 not 11")
    func ruOne() {
        let cat = rule.category(for: 1, locale: Locale(identifier: "ru"))
        #expect(cat == .one)
    }

    @Test("Russian one 21")
    func ruOne21() {
        let cat = rule.category(for: 21, locale: Locale(identifier: "ru"))
        #expect(cat == .one)
    }

    @Test("Russian few 2-4")
    func ruFew() {
        let cat = rule.category(for: 3, locale: Locale(identifier: "ru"))
        #expect(cat == .few)
    }

    @Test("Russian few 22")
    func ruFew22() {
        let cat = rule.category(for: 22, locale: Locale(identifier: "ru"))
        #expect(cat == .few)
    }

    @Test("Russian many 5-20")
    func ruMany() {
        let cat = rule.category(for: 5, locale: Locale(identifier: "ru"))
        #expect(cat == .many)
    }

    @Test("Russian many 11")
    func ruMany11() {
        let cat = rule.category(for: 11, locale: Locale(identifier: "ru"))
        #expect(cat == .many)
    }

    @Test("Russian many 0")
    func ruMany0() {
        let cat = rule.category(for: 0, locale: Locale(identifier: "ru"))
        #expect(cat == .many)
    }

    @Test("Japanese always other")
    func jaOther() {
        let cat = rule.category(for: 1, locale: Locale(identifier: "ja"))
        #expect(cat == .other)
    }

    @Test("Chinese always other")
    func zhOther() {
        let cat = rule.category(for: 42, locale: Locale(identifier: "zh"))
        #expect(cat == .other)
    }

    @Test("Korean always other")
    func koOther() {
        let cat = rule.category(for: 7, locale: Locale(identifier: "ko"))
        #expect(cat == .other)
    }

    @Test("Vietnamese always other")
    func viOther() {
        let cat = rule.category(for: 3, locale: Locale(identifier: "vi"))
        #expect(cat == .other)
    }

    @Test("Thai always other")
    func thOther() {
        let cat = rule.category(for: 99, locale: Locale(identifier: "th"))
        #expect(cat == .other)
    }

    @Test("Unknown locale defaults to English")
    func unknownLocale() {
        let cat = rule.category(for: 1, locale: Locale(identifier: "xx"))
        #expect(cat == .one)
    }

    @Test("PrismPluralCategory has 6 cases")
    func categoryCount() {
        #expect(PrismPluralCategory.allCases.count == 6)
    }
}

// MARK: - PrismLocaleFormatters

@Suite("LocaleFormatters")
struct PrismLocaleFormattersCoverageTests {
    let numFmt = PrismNumberFormatter.shared
    let dateFmt = PrismDateFormatter.shared
    let relFmt = PrismRelativeTimeFormatter.shared
    let locale = Locale(identifier: "en_US")

    @Test("decimal formatting")
    func decimal() {
        let result = numFmt.format(1234.5, style: .decimal, locale: locale)
        #expect(result.contains("1") && result.contains("234"))
    }

    @Test("currency formatting")
    func currency() {
        let result = numFmt.format(99.99, style: .currency(code: "USD"), locale: locale)
        #expect(result.contains("99"))
    }

    @Test("percent formatting")
    func percent() {
        let result = numFmt.format(0.75, style: .percent, locale: locale)
        #expect(result.contains("75"))
    }

    @Test("scientific formatting")
    func scientific() {
        let result = numFmt.format(1500.0, style: .scientific, locale: locale)
        #expect(!result.isEmpty)
    }

    @Test("date short style")
    func dateShort() {
        let date = Date(timeIntervalSince1970: 1_000_000_000)
        let result = dateFmt.format(date, style: .short, locale: locale)
        #expect(!result.isEmpty)
    }

    @Test("date medium style")
    func dateMedium() {
        let date = Date(timeIntervalSince1970: 1_000_000_000)
        let result = dateFmt.format(date, style: .medium, locale: locale)
        #expect(!result.isEmpty)
    }

    @Test("date long style")
    func dateLong() {
        let date = Date(timeIntervalSince1970: 1_000_000_000)
        let result = dateFmt.format(date, style: .long, locale: locale)
        #expect(!result.isEmpty)
    }

    @Test("date full style")
    func dateFull() {
        let date = Date(timeIntervalSince1970: 1_000_000_000)
        let result = dateFmt.format(date, style: .full, locale: locale)
        #expect(!result.isEmpty)
    }

    @Test("date relative style")
    func dateRelative() {
        let result = dateFmt.format(Date.now, style: .relative, locale: locale)
        #expect(!result.isEmpty)
    }

    @Test("relative time formatter")
    func relativeTime() {
        let past = Date.now.addingTimeInterval(-3600)
        let result = relFmt.format(past, relativeTo: Date.now, locale: locale)
        #expect(!result.isEmpty)
    }

    @Test("number style has currency code")
    func currencyCode() {
        let style = PrismNumberStyle.currency(code: "EUR")
        if case .currency(let code) = style {
            #expect(code == "EUR")
        }
    }

    @Test("date style cases exist")
    func dateStyles() {
        let styles: [PrismDateStyle] = [.short, .medium, .long, .full, .relative]
        #expect(styles.count == 5)
    }
}

// MARK: - PrismComponentGenerator

@Suite("CompGen")
struct PrismComponentGeneratorCoverageTests {
    @Test("generate button contains Button")
    func genButton() {
        let code = PrismComponentGenerator.generate(template: .button, name: "MyBtn")
        #expect(code.contains("Button"))
        #expect(code.contains("MyBtn"))
        #expect(code.contains("accessibilityLabel"))
    }

    @Test("generate card contains VStack")
    func genCard() {
        let code = PrismComponentGenerator.generate(template: .card, name: "MyCard")
        #expect(code.contains("VStack"))
        #expect(code.contains("MyCard"))
        #expect(code.contains("shadow"))
    }

    @Test("generate form contains TextField")
    func genForm() {
        let code = PrismComponentGenerator.generate(template: .form, name: "MyForm")
        #expect(code.contains("TextField"))
        #expect(code.contains("Form"))
        #expect(code.contains("Section"))
    }

    @Test("generate list contains List")
    func genList() {
        let code = PrismComponentGenerator.generate(template: .list, name: "MyList")
        #expect(code.contains("List"))
        #expect(code.contains("MyList"))
    }

    @Test("generate detail contains ScrollView")
    func genDetail() {
        let code = PrismComponentGenerator.generate(template: .detail, name: "MyDetail")
        #expect(code.contains("ScrollView"))
        #expect(code.contains("MyDetail"))
    }

    @Test("generate settings contains Toggle")
    func genSettings() {
        let code = PrismComponentGenerator.generate(template: .settings, name: "MySettings")
        #expect(code.contains("Toggle"))
        #expect(code.contains("MySettings"))
    }

    @Test("all templates produce unique code")
    func uniqueTemplates() {
        let templates = PrismComponentGenerator.availableTemplates()
        let codes = templates.map { PrismComponentGenerator.generate(template: $0, name: "X") }
        #expect(Set(codes).count == templates.count)
    }

    @Test("generated code imports PrismUI")
    func importsModule() {
        for template in PrismComponentTemplate.allCases {
            let code = PrismComponentGenerator.generate(template: template, name: "Test")
            #expect(code.contains("import PrismUI"))
        }
    }
}

// MARK: - PrismComponentDebugger

@Suite("CompDebug")
struct PrismComponentDebuggerCoverageTests {
    @Test("register multiple components")
    @MainActor func registerMultiple() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "A", size: CGSize(width: 100, height: 50))
        debugger.register(component: "B", size: CGSize(width: 200, height: 100), label: "B label")
        #expect(debugger.components.count == 2)
    }

    @Test("register same component increments count")
    @MainActor func incrementCount() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "A", size: CGSize(width: 100, height: 50))
        debugger.register(component: "A", size: CGSize(width: 120, height: 60), label: "updated")
        #expect(debugger.components.count == 1)
        #expect(debugger.components[0].renderCount == 2)
        #expect(debugger.components[0].frameSize == CGSize(width: 120, height: 60))
        #expect(debugger.components[0].accessibilityLabel == "updated")
    }

    @Test("reset clears all")
    @MainActor func reset() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "A", size: .zero)
        debugger.register(component: "B", size: .zero)
        debugger.reset()
        #expect(debugger.components.isEmpty)
    }
}

// MARK: - PrismDebugInfo

@Suite("DebugInfo")
struct PrismDebugInfoCoverageTests {
    @Test("default values")
    func defaults() {
        let info = PrismDebugInfo(componentName: "Test")
        #expect(info.componentName == "Test")
        #expect(info.renderCount == 1)
        #expect(info.frameSize == .zero)
        #expect(info.accessibilityLabel == nil)
    }

    @Test("custom values")
    func custom() {
        let info = PrismDebugInfo(
            componentName: "Button",
            renderCount: 5,
            frameSize: CGSize(width: 200, height: 44),
            accessibilityLabel: "Submit"
        )
        #expect(info.renderCount == 5)
        #expect(info.frameSize.width == 200)
        #expect(info.accessibilityLabel == "Submit")
    }
}

// MARK: - PrismEnvironmentSnapshot

@Suite("EnvSnap")
struct PrismEnvironmentSnapshotCoverageTests {
    @Test("stores all properties")
    func storesAll() {
        let snap = PrismEnvironmentSnapshot(
            colorScheme: .dark,
            dynamicTypeSize: .large,
            layoutDirection: .rightToLeft,
            accessibilityEnabled: true,
            reduceMotion: true,
            reduceTransparency: false
        )
        #expect(snap.colorScheme == .dark)
        #expect(snap.dynamicTypeSize == .large)
        #expect(snap.layoutDirection == .rightToLeft)
        #expect(snap.accessibilityEnabled == true)
        #expect(snap.reduceMotion == true)
        #expect(snap.reduceTransparency == false)
    }
}

// MARK: - Chart data types

@Suite("ChartData")
struct PrismChartDataTypesCoverageTests {

    @Test("PrismTreemapItem properties")
    func treemapItem() {
        let item = PrismTreemapItem(id: "a", label: "Root", value: 100)
        #expect(item.id == "a")
        #expect(item.label == "Root")
        #expect(item.value == 100)
        #expect(item.color == nil)
        #expect(item.children.isEmpty)
    }

    @Test("PrismTreemapItem with children")
    func treemapChildren() {
        let child = PrismTreemapItem(id: "c1", label: "Child", value: 30)
        let parent = PrismTreemapItem(id: "p", label: "Parent", value: 100, children: [child])
        #expect(parent.children.count == 1)
        #expect(parent.children[0].label == "Child")
    }

    @Test("PrismTreemapItem equality by id")
    func treemapEquality() {
        let a = PrismTreemapItem(id: "x", label: "A", value: 10)
        let b = PrismTreemapItem(id: "x", label: "B", value: 20)
        #expect(a == b)
    }

    @Test("PrismTreemapItem hashable")
    func treemapHash() {
        let a = PrismTreemapItem(id: "x", label: "A", value: 10)
        let b = PrismTreemapItem(id: "y", label: "B", value: 20)
        #expect(a.hashValue != b.hashValue)
    }

    @Test("PrismFunnelStage properties")
    func funnelStage() {
        let stage = PrismFunnelStage(label: "Awareness", value: 1000)
        #expect(stage.id == "Awareness")
        #expect(stage.label == "Awareness")
        #expect(stage.value == 1000)
        #expect(stage.color == nil)
    }

    @Test("PrismCandlestick properties")
    func candlestick() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let candle = PrismCandlestick(date: date, open: 100, high: 110, low: 95, close: 105)
        #expect(candle.id == date)
        #expect(candle.open == 100)
        #expect(candle.high == 110)
        #expect(candle.low == 95)
        #expect(candle.close == 105)
    }

    @Test("PrismCandlestick isBullish when close >= open")
    func candleBullish() {
        let date = Date()
        let bull = PrismCandlestick(date: date, open: 100, high: 110, low: 95, close: 105)
        #expect(bull.isBullish == true)
    }

    @Test("PrismCandlestick bearish when close < open")
    func candleBearish() {
        let date = Date()
        let bear = PrismCandlestick(date: date, open: 100, high: 110, low: 95, close: 90)
        #expect(bear.isBullish == false)
    }

    @Test("PrismCandlestick flat is bullish")
    func candleFlat() {
        let date = Date()
        let flat = PrismCandlestick(date: date, open: 100, high: 100, low: 100, close: 100)
        #expect(flat.isBullish == true)
    }

    @Test("PrismRadarAxis properties")
    func radarAxis() {
        let axis = PrismRadarAxis(label: "Speed", maxValue: 100)
        #expect(axis.label == "Speed")
        #expect(axis.maxValue == 100)
    }

    @Test("PrismRadarDataSet properties")
    func radarDataSet() {
        let ds = PrismRadarDataSet(values: [80, 60, 90], color: .blue, label: "Player 1")
        #expect(ds.values.count == 3)
        #expect(ds.label == "Player 1")
    }

    @Test("PrismHeatmapCell properties")
    func heatmapCell() {
        let cell = PrismHeatmapCell(row: 2, column: 3, value: 0.75)
        #expect(cell.row == 2)
        #expect(cell.column == 3)
        #expect(cell.value == 0.75)
    }

    @Test("PrismSparklineStyle has 3 cases")
    func sparklineStyles() {
        #expect(PrismSparklineStyle.allCases.count == 3)
        #expect(PrismSparklineStyle.line.rawValue == "line")
        #expect(PrismSparklineStyle.area.rawValue == "area")
        #expect(PrismSparklineStyle.bar.rawValue == "bar")
    }
}

// MARK: - PrismSpringConfig

@Suite("SpringCfg")
struct PrismSpringConfigCoverageTests {
    @Test("snappy preset values")
    func snappy() {
        let c = PrismSpringConfig.snappy
        #expect(c.response == 0.25)
        #expect(c.dampingFraction == 0.8)
        #expect(c.blendDuration == 0)
    }

    @Test("gentle preset values")
    func gentle() {
        let c = PrismSpringConfig.gentle
        #expect(c.response == 0.5)
        #expect(c.dampingFraction == 0.75)
    }

    @Test("bouncy preset values")
    func bouncy() {
        let c = PrismSpringConfig.bouncy
        #expect(c.response == 0.4)
        #expect(c.dampingFraction == 0.5)
    }

    @Test("stiff preset values")
    func stiff() {
        let c = PrismSpringConfig.stiff
        #expect(c.response == 0.2)
        #expect(c.dampingFraction == 0.9)
    }

    @Test("dramatic preset values")
    func dramatic() {
        let c = PrismSpringConfig.dramatic
        #expect(c.response == 0.7)
        #expect(c.dampingFraction == 0.65)
    }

    @Test("critical preset values")
    func critical() {
        let c = PrismSpringConfig.critical
        #expect(c.response == 0.15)
        #expect(c.dampingFraction == 1.0)
    }

    @Test("rubber preset values")
    func rubber() {
        let c = PrismSpringConfig.rubber
        #expect(c.response == 0.35)
        #expect(c.dampingFraction == 0.4)
    }

    @Test("custom config with blend duration")
    func customBlend() {
        let c = PrismSpringConfig(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)
        #expect(c.blendDuration == 0.1)
    }

    @Test("hashable conformance")
    func hashable() {
        let a = PrismSpringConfig.snappy
        let b = PrismSpringConfig.gentle
        #expect(a.hashValue != b.hashValue)
    }

    @Test("equatable conformance")
    func equatable() {
        let a = PrismSpringConfig.snappy
        let b = PrismSpringConfig(response: 0.25, dampingFraction: 0.8)
        #expect(a == b)
    }
}

// MARK: - Dashboard data types

@Suite("DashData")
struct PrismDashboardDataCoverageTests {

    @Test("PrismTrend colorToken mapping")
    func trendColors() {
        #expect(PrismTrend.up.colorToken == .success)
        #expect(PrismTrend.down.colorToken == .error)
        #expect(PrismTrend.flat.colorToken == .onBackgroundSecondary)
    }

    @Test("PrismTrend systemImage mapping")
    func trendImages() {
        #expect(PrismTrend.up.systemImage == "arrow.up.right")
        #expect(PrismTrend.down.systemImage == "arrow.down.right")
        #expect(PrismTrend.flat.systemImage == "arrow.right")
    }

    @Test("PrismEventStatus colorToken all distinct")
    func eventColors() {
        let colors = PrismEventStatus.allCases.map(\.colorToken)
        #expect(Set(colors).count == 4)
    }

    @Test("PrismEventStatus systemImage all distinct")
    func eventImages() {
        let images = PrismEventStatus.allCases.map(\.systemImage)
        #expect(Set(images).count == 4)
    }

    @Test("PrismTimelineEvent stores all properties")
    func timelineEvent() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let event = PrismTimelineEvent(
            title: "Deploy",
            description: "v2.0",
            date: date,
            status: .completed,
            icon: "rocket"
        )
        #expect(event.title == "Deploy")
        #expect(event.description == "v2.0")
        #expect(event.date == date)
        #expect(event.status == .completed)
        #expect(event.icon == "rocket")
    }

    @Test("PrismTimelineEvent nil defaults")
    func timelineDefaults() {
        let event = PrismTimelineEvent(title: "X", date: Date(), status: .upcoming)
        #expect(event.description == nil)
        #expect(event.icon == nil)
    }

    @Test("PrismStatItem stores properties")
    func statItem() {
        let item = PrismStatItem(label: "Users", value: "1.2M", icon: "person.3", trend: .up)
        #expect(item.label == "Users")
        #expect(item.value == "1.2M")
        #expect(item.icon == "person.3")
        #expect(item.trend == .up)
    }

    @Test("PrismStatItem nil defaults")
    func statDefaults() {
        let item = PrismStatItem(label: "X", value: "0")
        #expect(item.icon == nil)
        #expect(item.trend == nil)
    }

    @Test("PrismActivity stores all properties")
    func activity() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let act = PrismActivity(user: "Alice", action: "pushed", target: "main", timestamp: date, icon: "arrow.up")
        #expect(act.user == "Alice")
        #expect(act.action == "pushed")
        #expect(act.target == "main")
        #expect(act.timestamp == date)
        #expect(act.icon == "arrow.up")
    }

    @Test("PrismActivityGroup groups by date correctly")
    func activityGrouping() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let activities = [
            PrismActivity(user: "A", action: "x", target: "y", timestamp: today),
            PrismActivity(user: "B", action: "x", target: "y", timestamp: yesterday),
            PrismActivity(user: "C", action: "x", target: "y", timestamp: today),
        ]
        let groups = PrismActivityGroup.group(activities)
        #expect(groups.count == 2)
        #expect(groups[0].title == "Today")
        #expect(groups[0].activities.count == 2)
        #expect(groups[1].title == "Yesterday")
    }

    @Test("PrismActivityGroup older date formatting")
    func activityGroupOlder() {
        let old = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let activities = [
            PrismActivity(user: "A", action: "x", target: "y", timestamp: old)
        ]
        let groups = PrismActivityGroup.group(activities)
        #expect(groups.count == 1)
        #expect(groups[0].title != "Today")
        #expect(groups[0].title != "Yesterday")
    }

    @Test("PrismFeatureValue cases")
    func featureValues() {
        let check = PrismFeatureValue.check
        let cross = PrismFeatureValue.cross
        let text = PrismFeatureValue.text("Pro")
        let num = PrismFeatureValue.number(99.9)

        if case .check = check {} else { Issue.record("Expected check") }
        if case .cross = cross {} else { Issue.record("Expected cross") }
        if case .text(let v) = text { #expect(v == "Pro") }
        if case .number(let v) = num { #expect(v == 99.9) }
    }

    @Test("PrismComparisonColumn properties")
    func comparisonColumn() {
        let col = PrismComparisonColumn(header: "Basic", values: ["10GB", "$9.99"])
        #expect(col.header == "Basic")
        #expect(col.values.count == 2)
    }

    @Test("PrismComparisonFeature properties")
    func comparisonFeature() {
        let feat = PrismComparisonFeature(name: "Storage", values: [.text("10GB"), .text("100GB")])
        #expect(feat.name == "Storage")
        #expect(feat.values.count == 2)
    }
}

// MARK: - Communication data types

@Suite("CommData")
struct PrismCommunicationDataCoverageTests {

    @Test("PrismMessageStatus has 5 cases")
    func statusCount() {
        #expect(PrismMessageStatus.allCases.count == 5)
    }

    @Test("PrismMessageStatus raw values")
    func statusRaw() {
        #expect(PrismMessageStatus.sending.rawValue == "sending")
        #expect(PrismMessageStatus.sent.rawValue == "sent")
        #expect(PrismMessageStatus.delivered.rawValue == "delivered")
        #expect(PrismMessageStatus.read.rawValue == "read")
        #expect(PrismMessageStatus.failed.rawValue == "failed")
    }

    @Test("PrismMessage stores all properties")
    func message() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let msg = PrismMessage(
            text: "Hello",
            sender: "Alice",
            timestamp: date,
            isOutgoing: true,
            status: .delivered
        )
        #expect(msg.text == "Hello")
        #expect(msg.sender == "Alice")
        #expect(msg.timestamp == date)
        #expect(msg.isOutgoing == true)
        #expect(msg.status == .delivered)
    }

    @Test("PrismMessage defaults")
    func messageDefaults() {
        let msg = PrismMessage(text: "Hi", sender: "Bob")
        #expect(msg.isOutgoing == false)
        #expect(msg.status == .sent)
    }

    @Test("PrismMessage equatable")
    func messageEquatable() {
        let id = UUID()
        let ts = Date(timeIntervalSince1970: 1_000_000)
        let a = PrismMessage(id: id, text: "X", sender: "A", timestamp: ts)
        let b = PrismMessage(id: id, text: "X", sender: "A", timestamp: ts)
        #expect(a == b)
    }

    @Test("PrismMessageGroup properties")
    func messageGroup() {
        let msgs = [
            PrismMessage(text: "Hi", sender: "A", isOutgoing: true),
            PrismMessage(text: "Hey", sender: "A", isOutgoing: true),
        ]
        let group = PrismMessageGroup(sender: "A", isOutgoing: true, messages: msgs)
        #expect(group.sender == "A")
        #expect(group.isOutgoing == true)
        #expect(group.messages.count == 2)
    }

    @Test("PrismReaction properties")
    func reaction() {
        let r = PrismReaction(emoji: "👍", count: 5, isSelected: true)
        #expect(r.id == "👍")
        #expect(r.emoji == "👍")
        #expect(r.count == 5)
        #expect(r.isSelected == true)
    }

    @Test("PrismReaction defaults")
    func reactionDefaults() {
        let r = PrismReaction(emoji: "❤️")
        #expect(r.count == 0)
        #expect(r.isSelected == false)
    }

    @Test("PrismReaction equatable")
    func reactionEquatable() {
        let a = PrismReaction(emoji: "😂", count: 3, isSelected: false)
        let b = PrismReaction(emoji: "😂", count: 3, isSelected: false)
        #expect(a == b)
    }

    @Test("PrismReadReceipt properties")
    func readReceipt() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let receipt = PrismReadReceipt(userId: "u1", name: "Alice", readAt: date)
        #expect(receipt.id == "u1")
        #expect(receipt.userId == "u1")
        #expect(receipt.name == "Alice")
        #expect(receipt.readAt == date)
    }

    @Test("PrismBubbleStyle has 3 cases")
    func bubbleStyles() {
        #expect(PrismBubbleStyle.allCases.count == 3)
        #expect(PrismBubbleStyle.filled.rawValue == "filled")
        #expect(PrismBubbleStyle.outlined.rawValue == "outlined")
        #expect(PrismBubbleStyle.glass.rawValue == "glass")
    }
}

// MARK: - PrismLayoutDirection

@Suite("LayoutDir")
struct PrismLayoutDirectionCoverageTests {
    @Test("PrismLayoutDirection has 3 cases")
    func caseCount() {
        #expect(PrismLayoutDirection.allCases.count == 3)
    }

    @Test("PrismDirectionalEdge leading resolves for LTR")
    func leadingLTR() {
        let edge = PrismDirectionalEdge.leading.resolved(for: .leftToRight)
        #expect(edge == .leading)
    }

    @Test("PrismDirectionalEdge trailing resolves for LTR")
    func trailingLTR() {
        let edge = PrismDirectionalEdge.trailing.resolved(for: .leftToRight)
        #expect(edge == .trailing)
    }

    @Test("PrismDirectionalEdge leading resolves for RTL")
    func leadingRTL() {
        let edge = PrismDirectionalEdge.leading.resolved(for: .rightToLeft)
        #expect(edge == .trailing)
    }

    @Test("PrismDirectionalEdge trailing resolves for RTL")
    func trailingRTL() {
        let edge = PrismDirectionalEdge.trailing.resolved(for: .rightToLeft)
        #expect(edge == .leading)
    }

    @Test("PrismDirectionalEdge has 2 cases")
    func edgeCaseCount() {
        #expect(PrismDirectionalEdge.allCases.count == 2)
    }
}

// MARK: - PrismAttributedStringBuilder extra

@Suite("AttrStrExtra")
struct PrismAttributedStringBuilderExtraCoverageTests {
    @Test("chained text+bold+italic+code+newline+link+colored builds correctly")
    func fullChain() {
        let url = URL(string: "https://example.com")!
        let result = PrismAttributedStringBuilder()
            .text("Hello ")
            .bold("World")
            .italic(" is ")
            .code("great")
            .newline()
            .link("Click", url: url)
            .colored(" Color", color: .red)
            .build()
        let text = String(result.characters)
        #expect(text.contains("Hello "))
        #expect(text.contains("World"))
        #expect(text.contains("great"))
        #expect(text.contains("Click"))
        #expect(text.contains("Color"))
    }
}

// MARK: - PrismTextFormatting

@Suite("TextFmt")
struct PrismTextFormattingCoverageTests {
    @Test("heading levels 1-6")
    func headingLevels() {
        for level in 1...6 {
            let fmt = PrismTextFormatting.heading(level)
            if case .heading(let l) = fmt {
                #expect(l == level)
            }
        }
    }

    @Test("link stores URL")
    func linkURL() {
        let url = URL(string: "https://example.com")!
        let fmt = PrismTextFormatting.link(url)
        if case .link(let u) = fmt {
            #expect(u == url)
        }
    }

    @Test("all cases are hashable")
    func hashable() {
        let url = URL(string: "https://example.com")!
        let cases: [PrismTextFormatting] = [
            .bold, .italic, .underline, .strikethrough, .code,
            .heading(1), .link(url), .bulletList, .numberedList,
        ]
        let set = Set(cases)
        #expect(set.count == cases.count)
    }
}

// MARK: - SwiftData types

#if canImport(SwiftData)
    @Suite("SwiftDataTypes")
    struct PrismSwiftDataTypesCoverageTests {

        @Test("PrismMigrationStage stores properties")
        func migrationStage() {
            let stage = PrismMigrationStage(version: "1.0", description: "Initial")
            #expect(stage.version == "1.0")
            #expect(stage.description == "Initial")
            #expect(stage.migrationPlan == nil)
        }

        @Test("PrismMigrationHelper currentVersion returns last")
        func currentVersion() {
            let helper = PrismMigrationHelper(stages: [
                PrismMigrationStage(version: "1.0", description: "Init"),
                PrismMigrationStage(version: "2.0", description: "Update"),
            ])
            #expect(helper.currentVersion() == "2.0")
        }

        @Test("PrismMigrationHelper currentVersion empty returns default")
        func currentVersionEmpty() {
            let helper = PrismMigrationHelper(stages: [])
            #expect(helper.currentVersion() == "0.0.0")
        }

        @Test("PrismMigrationHelper needsMigration true")
        func needsMigrationTrue() {
            let helper = PrismMigrationHelper(stages: [
                PrismMigrationStage(version: "1.0", description: ""),
                PrismMigrationStage(version: "2.0", description: ""),
                PrismMigrationStage(version: "3.0", description: ""),
            ])
            #expect(helper.needsMigration(from: "1.0", to: "3.0"))
        }

        @Test("PrismMigrationHelper needsMigration false same version")
        func needsMigrationSame() {
            let helper = PrismMigrationHelper(stages: [
                PrismMigrationStage(version: "1.0", description: "")
            ])
            #expect(!helper.needsMigration(from: "1.0", to: "1.0"))
        }

        @Test("PrismMigrationHelper needsMigration false unknown version")
        func needsMigrationUnknown() {
            let helper = PrismMigrationHelper(stages: [
                PrismMigrationStage(version: "1.0", description: "")
            ])
            #expect(!helper.needsMigration(from: "1.0", to: "9.0"))
        }

        @Test("PrismMigrationHelper migrationStages returns range")
        func migrationStages() {
            let helper = PrismMigrationHelper(stages: [
                PrismMigrationStage(version: "1.0", description: "Init"),
                PrismMigrationStage(version: "2.0", description: "Add users"),
                PrismMigrationStage(version: "3.0", description: "Add orders"),
                PrismMigrationStage(version: "4.0", description: "Add payments"),
            ])
            let stages = helper.migrationStages(from: "1.0", to: "3.0")
            #expect(stages.count == 2)
            #expect(stages[0].version == "2.0")
            #expect(stages[1].version == "3.0")
        }

        @Test("PrismMigrationHelper migrationStages empty for reverse")
        func migrationStagesReverse() {
            let helper = PrismMigrationHelper(stages: [
                PrismMigrationStage(version: "1.0", description: ""),
                PrismMigrationStage(version: "2.0", description: ""),
            ])
            let stages = helper.migrationStages(from: "2.0", to: "1.0")
            #expect(stages.isEmpty)
        }

        @Test("PrismFilterOperator rawValues")
        func filterOperatorRaw() {
            #expect(PrismFilterOperator.equals.rawValue == "equals")
            #expect(PrismFilterOperator.contains.rawValue == "contains")
            #expect(PrismFilterOperator.greaterThan.rawValue == "greaterThan")
            #expect(PrismFilterOperator.lessThan.rawValue == "lessThan")
            #expect(PrismFilterOperator.between.rawValue == "between")
            #expect(PrismFilterOperator.isNil.rawValue == "isNil")
            #expect(PrismFilterOperator.isNotNil.rawValue == "isNotNil")
        }

        @Test("FieldType equatable")
        func fieldTypeEq() {
            #expect(FieldType.text == .text)
            #expect(FieldType.number == .number)
            #expect(FieldType.toggle == .toggle)
            #expect(FieldType.date == .date)
            #expect(FieldType.picker(["A", "B"]) == .picker(["A", "B"]))
            #expect(FieldType.text != .number)
        }

        @Test("PrismFormField properties")
        func formField() {
            let field = PrismFormField(label: "Name", keyPath: "name", fieldType: .text)
            #expect(field.label == "Name")
            #expect(field.keyPath == "name")
            #expect(field.fieldType == .text)
        }

        @Test("PrismSyncState equatable")
        func syncState() {
            #expect(PrismSyncState.idle == .idle)
            #expect(PrismSyncState.syncing == .syncing)
            #expect(PrismSyncState.synced == .synced)
            #expect(PrismSyncState.error("x") == .error("x"))
            #expect(PrismSyncState.error("x") != .error("y"))
            #expect(PrismSyncState.idle != .syncing)
        }

        @Test("PrismCloudSyncMonitor initial state")
        @MainActor func syncMonitorInit() {
            let monitor = PrismCloudSyncMonitor()
            #expect(monitor.state == .idle)
            #expect(monitor.lastSyncDate == nil)
        }

        @Test("PrismCloudSyncMonitor startMonitoring changes state")
        @MainActor func syncMonitorStart() {
            let monitor = PrismCloudSyncMonitor()
            monitor.startMonitoring()
            #expect(monitor.state == .syncing)
        }

        @Test("PrismCloudSyncMonitor updateState to synced sets date")
        @MainActor func syncMonitorUpdate() {
            let monitor = PrismCloudSyncMonitor()
            monitor.updateState(.synced)
            #expect(monitor.state == .synced)
            #expect(monitor.lastSyncDate != nil)
        }

        @Test("PrismCloudSyncMonitor updateState to error")
        @MainActor func syncMonitorError() {
            let monitor = PrismCloudSyncMonitor()
            monitor.updateState(.error("Network failed"))
            #expect(monitor.state == .error("Network failed"))
        }
    }
#endif

// MARK: - PrismButton / Haptic enums

@Suite("ButtonEnums")
struct PrismButtonEnumsCoverageTests {
    @Test("PrismButtonVariant cases exist")
    func buttonVariants() {
        let _ = PrismButtonVariant.filled
        let _ = PrismButtonVariant.tinted
        let _ = PrismButtonVariant.bordered
        let _ = PrismButtonVariant.plain
    }

    @Test("PrismButtonHaptic cases exist")
    func buttonHaptics() {
        let _ = PrismButtonHaptic.light
        let _ = PrismButtonHaptic.medium
        let _ = PrismButtonHaptic.heavy
        let _ = PrismButtonHaptic.none
    }

    @Test("PrismHapticType cases exist")
    func hapticTypes() {
        let _ = PrismHapticType.impact
        let _ = PrismHapticType.selection
        let _ = PrismHapticType.notification
    }

    @Test("PrismImpactWeight cases exist")
    func impactWeights() {
        let _ = PrismImpactWeight.light
        let _ = PrismImpactWeight.medium
        let _ = PrismImpactWeight.heavy
    }
}

// MARK: - PrismSheetBackground

@Suite("SheetBg")
struct PrismSheetBackgroundCoverageTests {
    @Test("PrismSheetBackground cases exist")
    func cases() {
        let _ = PrismSheetBackground.automatic
        let _ = PrismSheetBackground.material
        let _ = PrismSheetBackground.clear
    }
}

// MARK: - PrismMaterial

@Suite("Material")
struct PrismMaterialCoverageTests {
    @Test("PrismMaterial cases exist")
    func cases() {
        let _ = PrismMaterial.ultraThin
        let _ = PrismMaterial.thin
        let _ = PrismMaterial.regular
        let _ = PrismMaterial.thick
        let _ = PrismMaterial.ultraThick
    }
}
