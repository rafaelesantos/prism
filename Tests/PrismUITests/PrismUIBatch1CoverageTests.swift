import SwiftUI
import Testing

@testable import PrismStorage
@testable import PrismUI

// MARK: - Markdown Parser (parseBlocks)

@Suite("PrismMarkdownView parseBlocks")
@MainActor
struct MarkdownParserBlockTests {

    private func parse(_ md: String) -> [MarkdownBlock] {
        PrismMarkdownView(md).parseBlocks()
    }

    @Test("parses heading levels 1–6")
    func headingLevels() {
        let blocks = parse("# H1\n## H2\n### H3\n#### H4\n##### H5\n###### H6")
        #expect(blocks.count == 6)
        for (i, block) in blocks.enumerated() {
            if case .heading(let level, let text) = block {
                #expect(level == i + 1)
                #expect(text == "H\(i + 1)")
            } else {
                Issue.record("Expected heading at index \(i)")
            }
        }
    }

    @Test("heading level beyond 6 treated as paragraph")
    func headingBeyond6() {
        let blocks = parse("####### Not a heading")
        #expect(blocks.count == 1)
        if case .paragraph = blocks[0] {
        } else {
            Issue.record("Expected paragraph")
        }
    }

    @Test("parses paragraphs")
    func paragraphs() {
        let blocks = parse("Hello world")
        #expect(blocks.count == 1)
        if case .paragraph(let text) = blocks[0] {
            #expect(text == "Hello world")
        } else {
            Issue.record("Expected paragraph")
        }
    }

    @Test("parses code blocks with language")
    func codeBlocks() {
        let md = "```swift\nlet x = 1\nlet y = 2\n```"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .codeBlock(let language, let code) = blocks[0] {
            #expect(language == "swift")
            #expect(code == "let x = 1\nlet y = 2")
        } else {
            Issue.record("Expected code block")
        }
    }

    @Test("parses code blocks without language")
    func codeBlocksNoLang() {
        let md = "```\nplain code\n```"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .codeBlock(let language, let code) = blocks[0] {
            #expect(language == "")
            #expect(code == "plain code")
        } else {
            Issue.record("Expected code block")
        }
    }

    @Test("parses blockquotes across multiple lines")
    func blockquotes() {
        let md = "> first line\n> second line"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .blockquote(let text) = blocks[0] {
            #expect(text == "first line\nsecond line")
        } else {
            Issue.record("Expected blockquote")
        }
    }

    @Test("parses unordered lists with dash marker")
    func unorderedListDash() {
        let md = "- Apple\n- Banana\n- Cherry"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .unorderedList(let items) = blocks[0] {
            #expect(items == ["Apple", "Banana", "Cherry"])
        } else {
            Issue.record("Expected unordered list")
        }
    }

    @Test("parses unordered lists with asterisk marker")
    func unorderedListAsterisk() {
        let md = "* One\n* Two"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .unorderedList(let items) = blocks[0] {
            #expect(items == ["One", "Two"])
        } else {
            Issue.record("Expected unordered list")
        }
    }

    @Test("parses unordered lists with plus marker")
    func unorderedListPlus() {
        let md = "+ Alpha\n+ Beta"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .unorderedList(let items) = blocks[0] {
            #expect(items == ["Alpha", "Beta"])
        } else {
            Issue.record("Expected unordered list")
        }
    }

    @Test("parses ordered lists")
    func orderedLists() {
        let md = "1. First\n2. Second\n3. Third"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .orderedList(let items) = blocks[0] {
            #expect(items == ["First", "Second", "Third"])
        } else {
            Issue.record("Expected ordered list")
        }
    }

    @Test("parses horizontal rules with dashes")
    func horizontalRuleDashes() {
        let blocks = parse("---")
        #expect(blocks.count == 1)
        if case .horizontalRule = blocks[0] {
        } else {
            Issue.record("Expected horizontal rule")
        }
    }

    @Test("parses horizontal rules with asterisks")
    func horizontalRuleAsterisks() {
        let blocks = parse("***")
        #expect(blocks.count == 1)
        if case .horizontalRule = blocks[0] {
        } else {
            Issue.record("Expected horizontal rule")
        }
    }

    @Test("parses horizontal rules with underscores")
    func horizontalRuleUnderscores() {
        let blocks = parse("___")
        #expect(blocks.count == 1)
        if case .horizontalRule = blocks[0] {
        } else {
            Issue.record("Expected horizontal rule")
        }
    }

    @Test("parses images")
    func images() {
        let md = "![Alt text](https://example.com/img.png)"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .image(let alt, let url) = blocks[0] {
            #expect(alt == "Alt text")
            #expect(url == "https://example.com/img.png")
        } else {
            Issue.record("Expected image")
        }
    }

    @Test("skips empty lines")
    func emptyLines() {
        let md = "Hello\n\nWorld"
        let blocks = parse(md)
        #expect(blocks.count == 2)
        if case .paragraph(let t1) = blocks[0] { #expect(t1 == "Hello") }
        if case .paragraph(let t2) = blocks[1] { #expect(t2 == "World") }
    }

    @Test("parses mixed content")
    func mixedContent() {
        let md = "# Title\n\nSome text\n\n- Item 1\n- Item 2\n\n> A quote\n\n---\n\n1. Ordered"
        let blocks = parse(md)
        #expect(blocks.count == 6)
        if case .heading(let l, _) = blocks[0] { #expect(l == 1) }
        if case .paragraph = blocks[1] {}
        if case .unorderedList(let items) = blocks[2] { #expect(items.count == 2) }
        if case .blockquote = blocks[3] {}
        if case .horizontalRule = blocks[4] {}
        if case .orderedList(let items) = blocks[5] { #expect(items.count == 1) }
    }
}

// MARK: - Inline Parsing (parseInlineElements)

@Suite("PrismMarkdownView parseInlineElements")
@MainActor
struct MarkdownInlineParseTests {

    private func view() -> PrismMarkdownView {
        PrismMarkdownView("")
    }

    @Test("renders plain text without crash")
    func plainText() {
        let _: Text = view().parseInlineElements("Hello world")
    }

    @Test("renders bold text without crash")
    func boldText() {
        let _: Text = view().parseInlineElements("Hello **world**")
    }

    @Test("renders italic text without crash")
    func italicText() {
        let _: Text = view().parseInlineElements("Hello *world*")
    }

    @Test("renders bold+italic text without crash")
    func boldItalicText() {
        let _: Text = view().parseInlineElements("Hello ***world***")
    }

    @Test("renders inline code without crash")
    func inlineCode() {
        let _: Text = view().parseInlineElements("Use `print()` here")
    }

    @Test("renders link without crash")
    func linkText() {
        let _: Text = view().parseInlineElements("Visit [Apple](https://apple.com) now")
    }

    @Test("link with invalid URL still produces Text")
    func linkInvalidURL() {
        let _: Text = view().parseInlineElements("See [label]( )")
    }

    @Test("multiple inline elements without crash")
    func multipleInline() {
        let _: Text = view().parseInlineElements("**bold** and *italic*")
    }

    @Test("only bold text")
    func onlyBold() {
        let _: Text = view().parseInlineElements("**all bold**")
    }

    @Test("empty string")
    func emptyString() {
        let _: Text = view().parseInlineElements("")
    }

    @Test("nested formatting")
    func nestedFormatting() {
        let _: Text = view().parseInlineElements("***bold italic*** and `code`")
    }
}

// MARK: - extractBracketContent

@Suite("PrismMarkdownView extractBracketContent")
@MainActor
struct ExtractBracketContentTests {

    private func view() -> PrismMarkdownView {
        PrismMarkdownView("")
    }

    @Test("extracts content between brackets")
    func basicExtract() {
        let result = view().extractBracketContent("[hello](world)", open: "[", close: "]")
        #expect(result == "hello")
    }

    @Test("extracts content between parens")
    func parenExtract() {
        let result = view().extractBracketContent("[hello](world)", open: "(", close: ")")
        #expect(result == "world")
    }

    @Test("returns empty for missing brackets")
    func missingBrackets() {
        let result = view().extractBracketContent("no brackets here", open: "[", close: "]")
        #expect(result == "")
    }

    @Test("returns empty for missing close")
    func missingClose() {
        let result = view().extractBracketContent("[open only", open: "[", close: "]")
        #expect(result == "")
    }
}

// MARK: - PrismSyntaxToken & PrismSyntaxTokenType

@Suite("PrismSyntaxToken")
struct SyntaxTokenTests {

    @Test("token stores text and type")
    func tokenProperties() {
        let token = PrismSyntaxToken(text: "func", type: .keyword)
        #expect(token.text == "func")
        #expect(token.type == .keyword)
    }

    @Test("all token types exist")
    func tokenTypes() {
        let types: [PrismSyntaxTokenType] = [
            .keyword, .string, .comment, .number, .punctuation, .type, .plain,
        ]
        #expect(types.count == 7)
    }

    @Test("token is Sendable")
    func sendable() {
        let token = PrismSyntaxToken(text: "let", type: .keyword)
        let sendable: any Sendable = token
        #expect((sendable as? PrismSyntaxToken)?.text == "let")
    }
}

// MARK: - prismSyntaxKeywords

@Suite("prismSyntaxKeywords")
struct SyntaxKeywordsTests {

    @Test("Swift keywords include core words")
    func swiftKeywords() {
        let kw = prismSyntaxKeywords(for: .swift)
        #expect(kw.contains("func"))
        #expect(kw.contains("let"))
        #expect(kw.contains("var"))
        #expect(kw.contains("struct"))
        #expect(kw.contains("class"))
        #expect(kw.contains("import"))
        #expect(kw.contains("return"))
        #expect(kw.contains("async"))
        #expect(kw.contains("await"))
        #expect(kw.contains("@MainActor"))
        #expect(kw.contains("@State"))
        #expect(kw.contains("@Observable"))
    }

    @Test("JavaScript keywords include core words")
    func jsKeywords() {
        let kw = prismSyntaxKeywords(for: .javascript)
        #expect(kw.contains("const"))
        #expect(kw.contains("function"))
        #expect(kw.contains("class"))
        #expect(kw.contains("async"))
        #expect(kw.contains("await"))
        #expect(kw.contains("null"))
        #expect(kw.contains("undefined"))
    }

    @Test("Python keywords include core words")
    func pythonKeywords() {
        let kw = prismSyntaxKeywords(for: .python)
        #expect(kw.contains("def"))
        #expect(kw.contains("class"))
        #expect(kw.contains("lambda"))
        #expect(kw.contains("None"))
        #expect(kw.contains("True"))
        #expect(kw.contains("False"))
        #expect(kw.contains("yield"))
    }

    @Test("HTML keywords include tag names")
    func htmlKeywords() {
        let kw = prismSyntaxKeywords(for: .html)
        #expect(kw.contains("html"))
        #expect(kw.contains("body"))
        #expect(kw.contains("div"))
        #expect(kw.contains("span"))
        #expect(kw.contains("script"))
    }

    @Test("CSS keywords include properties")
    func cssKeywords() {
        let kw = prismSyntaxKeywords(for: .css)
        #expect(kw.contains("color"))
        #expect(kw.contains("display"))
        #expect(kw.contains("flex"))
        #expect(kw.contains("@media"))
        #expect(kw.contains("@keyframes"))
    }

    @Test("JSON and plainText return empty sets")
    func emptyKeywords() {
        #expect(prismSyntaxKeywords(for: .json).isEmpty)
        #expect(prismSyntaxKeywords(for: .plainText).isEmpty)
    }
}

// MARK: - prismSyntaxColorize

@Suite("prismSyntaxColorize")
struct SyntaxColorizeTests {

    @Test("colorizes keyword tokens")
    func colorizeKeyword() {
        let tokens = [PrismSyntaxToken(text: "func", type: .keyword)]
        let result = prismSyntaxColorize(tokens)
        #expect(String(result.characters) == "func")
    }

    @Test("colorizes string tokens")
    func colorizeString() {
        let tokens = [PrismSyntaxToken(text: "\"hello\"", type: .string)]
        let result = prismSyntaxColorize(tokens)
        #expect(String(result.characters) == "\"hello\"")
    }

    @Test("colorizes comment tokens")
    func colorizeComment() {
        let tokens = [PrismSyntaxToken(text: "// note", type: .comment)]
        let result = prismSyntaxColorize(tokens)
        #expect(String(result.characters) == "// note")
    }

    @Test("colorizes number tokens")
    func colorizeNumber() {
        let tokens = [PrismSyntaxToken(text: "42", type: .number)]
        let result = prismSyntaxColorize(tokens)
        #expect(String(result.characters) == "42")
    }

    @Test("colorizes type tokens")
    func colorizeType() {
        let tokens = [PrismSyntaxToken(text: "String", type: .type)]
        let result = prismSyntaxColorize(tokens)
        #expect(String(result.characters) == "String")
    }

    @Test("colorizes punctuation tokens")
    func colorizePunctuation() {
        let tokens = [PrismSyntaxToken(text: "{", type: .punctuation)]
        let result = prismSyntaxColorize(tokens)
        #expect(String(result.characters) == "{")
    }

    @Test("colorizes plain tokens")
    func colorizePlain() {
        let tokens = [PrismSyntaxToken(text: "x", type: .plain)]
        let result = prismSyntaxColorize(tokens)
        #expect(String(result.characters) == "x")
    }

    @Test("concatenates multiple tokens")
    func multipleTokens() {
        let tokens = [
            PrismSyntaxToken(text: "let", type: .keyword),
            PrismSyntaxToken(text: " ", type: .plain),
            PrismSyntaxToken(text: "x", type: .plain),
            PrismSyntaxToken(text: " = ", type: .plain),
            PrismSyntaxToken(text: "42", type: .number),
        ]
        let result = prismSyntaxColorize(tokens)
        #expect(String(result.characters) == "let x = 42")
    }

    @Test("empty tokens produce empty result")
    func emptyTokens() {
        let result = prismSyntaxColorize([])
        #expect(String(result.characters) == "")
    }
}

// MARK: - Tokenizer Deep Paths (via highlight)

@Suite("PrismSyntaxHighlighter tokenizer deep paths")
struct SyntaxHighlighterDeepTests {

    private let hl = PrismSyntaxHighlighter()

    @Test("plainText language returns raw text")
    func plainTextPassthrough() {
        let result = hl.highlight("hello world", language: .plainText)
        #expect(String(result.characters) == "hello world")
    }

    @Test("multi-line comment tokenized")
    func multiLineComment() {
        let code = "/* multi\nline\ncomment */ let x = 1"
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("multi"))
        #expect(text.contains("comment"))
        #expect(text.contains("let"))
    }

    @Test("HTML comment tokenized")
    func htmlComment() {
        let code = "<!-- comment --> <div>"
        let result = hl.highlight(code, language: .html)
        let text = String(result.characters)
        #expect(text.contains("comment"))
        #expect(text.contains("div"))
    }

    @Test("hash comment in Python")
    func pythonHashComment() {
        let code = "# comment\ndef hello():"
        let result = hl.highlight(code, language: .python)
        let text = String(result.characters)
        #expect(text.contains("comment"))
        #expect(text.contains("def"))
    }

    @Test("hash comment in CSS")
    func cssHashComment() {
        let code = "# comment\ncolor: red"
        let result = hl.highlight(code, language: .css)
        let text = String(result.characters)
        #expect(text.contains("comment"))
        #expect(text.contains("color"))
    }

    @Test("string with escape sequences")
    func stringEscapes() {
        let code = #"let s = "hello \"world\"""#
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("hello"))
        #expect(text.contains("world"))
    }

    @Test("single-quoted strings")
    func singleQuotedString() {
        let code = "const x = 'hello'"
        let result = hl.highlight(code, language: .javascript)
        let text = String(result.characters)
        #expect(text.contains("hello"))
    }

    @Test("numbers with decimal point")
    func decimalNumbers() {
        let code = "let x = 3.14"
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("3.14"))
    }

    @Test("numbers with underscore separator")
    func underscoreNumbers() {
        let code = "let x = 1_000_000"
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("1_000_000"))
    }

    @Test("leading dot number")
    func leadingDotNumber() {
        let code = "let x = .5"
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains(".5"))
    }

    @Test("uppercase identifier classified as type")
    func uppercaseType() {
        let code = "let x: MyType = 1"
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("MyType"))
    }

    @Test("punctuation tokenized")
    func punctuationTokenized() {
        let code = "x = {}"
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("{"))
        #expect(text.contains("}"))
    }

    @Test("Swift attributes tokenized as keywords")
    func swiftAttributes() {
        let code = "@MainActor struct Foo {}"
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("@"))
        #expect(text.contains("struct"))
    }

    @Test("single-line comment")
    func singleLineComment() {
        let code = "let x = 1 // comment"
        let result = hl.highlight(code, language: .swift)
        let text = String(result.characters)
        #expect(text.contains("comment"))
    }

    @Test("CSS code tokenizes keywords and properties")
    func cssTokenization() {
        let code = "display: flex;\nposition: absolute;"
        let result = hl.highlight(code, language: .css)
        let text = String(result.characters)
        #expect(text.contains("display"))
        #expect(text.contains("flex"))
        #expect(text.contains("position"))
    }

    @Test("JSON tokenizes strings and numbers")
    func jsonTokenization() {
        let code = #"{"key": "value", "num": 42}"#
        let result = hl.highlight(code, language: .json)
        let text = String(result.characters)
        #expect(text.contains("key"))
        #expect(text.contains("42"))
    }
}

// MARK: - PrismKeyframeView.Values

@Suite("PrismKeyframeView.Values")
@MainActor
struct KeyframeValuesTests {

    @Test("default values")
    func defaults() {
        let values = PrismKeyframeView<Text>.Values()
        #expect(values.scale == 1)
        #expect(values.opacity == 1)
        #expect(values.offsetX == 0)
        #expect(values.offsetY == 0)
        #expect(values.rotation == 0)
    }

    @Test("custom init")
    func customInit() {
        let values = PrismKeyframeView<Text>.Values(
            scale: 0.5,
            opacity: 0.8,
            offsetX: 10,
            offsetY: -20,
            rotation: 45
        )
        #expect(values.scale == 0.5)
        #expect(values.opacity == 0.8)
        #expect(values.offsetX == 10)
        #expect(values.offsetY == -20)
        #expect(values.rotation == 45)
    }

    @Test("Values is Sendable")
    func sendable() {
        let values = PrismKeyframeView<Text>.Values()
        let s: any Sendable = values
        #expect((s as? PrismKeyframeView<Text>.Values)?.scale == 1)
    }
}

// MARK: - KeyframeFrame Preset Details

@Suite("PrismKeyframeView preset frame values")
@MainActor
struct KeyframeFramePresetDetailTests {

    @Test("popIn starts at scale 0.3 opacity 0")
    func popInStartValues() {
        let frames = PrismKeyframeView<Text>.popIn()
        #expect(frames[0].scale == 0.3)
        #expect(frames[0].opacity == 0)
        #expect(frames[0].duration == 0)
    }

    @Test("popIn ends at scale 1 opacity 1")
    func popInEndValues() {
        let frames = PrismKeyframeView<Text>.popIn()
        let last = frames.last!
        #expect(last.scale == 1)
        #expect(last.opacity == 1)
    }

    @Test("dropIn starts with negative offsetY")
    func dropInStart() {
        let frames = PrismKeyframeView<Text>.dropIn()
        #expect(frames[0].offsetY == -40)
        #expect(frames[0].opacity == 0)
    }

    @Test("dropIn ends at offset 0")
    func dropInEnd() {
        let frames = PrismKeyframeView<Text>.dropIn()
        let last = frames.last!
        #expect(last.offsetY == 0)
        #expect(last.opacity == 1)
        #expect(last.scale == 1)
    }

    @Test("flipIn starts with negative rotation")
    func flipInStart() {
        let frames = PrismKeyframeView<Text>.flipIn()
        #expect(frames[0].rotation == -15)
        #expect(frames[0].scale == 0.5)
    }

    @Test("flipIn ends at rotation 0")
    func flipInEnd() {
        let frames = PrismKeyframeView<Text>.flipIn()
        let last = frames.last!
        #expect(last.rotation == 0)
        #expect(last.scale == 1)
    }

    @Test("heartbeat starts and ends at scale 1")
    func heartbeatScales() {
        let frames = PrismKeyframeView<Text>.heartbeat()
        #expect(frames[0].scale == 1)
        #expect(frames.last!.scale == 1)
        #expect(frames[1].scale == 1.2)
    }

    @Test("KeyframeFrame custom init")
    func customFrame() {
        let frame = PrismKeyframeView<Text>.KeyframeFrame(
            duration: 0.5,
            scale: 2,
            opacity: 0.5,
            offsetX: 10,
            offsetY: 20,
            rotation: 90
        )
        #expect(frame.duration == 0.5)
        #expect(frame.scale == 2)
        #expect(frame.opacity == 0.5)
        #expect(frame.offsetX == 10)
        #expect(frame.offsetY == 20)
        #expect(frame.rotation == 90)
    }
}

// MARK: - PrismComponentDebugger Deep Paths

@Suite("PrismComponentDebugger deep paths")
@MainActor
struct ComponentDebuggerDeepTests {

    @Test("register updates size on re-register")
    func reRegisterUpdatesSize() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "Button", size: CGSize(width: 100, height: 40))
        debugger.register(component: "Button", size: CGSize(width: 200, height: 50))
        #expect(debugger.components.count == 1)
        #expect(debugger.components[0].frameSize == CGSize(width: 200, height: 50))
        #expect(debugger.components[0].renderCount == 2)
    }

    @Test("register updates accessibility label")
    func registerUpdatesLabel() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "Card", size: .zero, label: "Old")
        debugger.register(component: "Card", size: .zero, label: "New")
        #expect(debugger.components[0].accessibilityLabel == "New")
    }

    @Test("register multiple components independently")
    func multipleComponents() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "A", size: CGSize(width: 10, height: 10))
        debugger.register(component: "B", size: CGSize(width: 20, height: 20))
        debugger.register(component: "C", size: CGSize(width: 30, height: 30))
        #expect(debugger.components.count == 3)
    }

    @Test("reset after registering clears all")
    func resetAfterRegister() {
        let debugger = PrismComponentDebugger()
        debugger.register(component: "X", size: .zero)
        debugger.register(component: "Y", size: .zero)
        debugger.reset()
        #expect(debugger.components.isEmpty)
    }
}

// MARK: - PrismDebugInfo

@Suite("PrismDebugInfo deep paths")
struct DebugInfoDeepTests {

    @Test("defaults for renderCount and frameSize")
    func defaults() {
        let info = PrismDebugInfo(componentName: "Test")
        #expect(info.renderCount == 1)
        #expect(info.frameSize == .zero)
        #expect(info.accessibilityLabel == nil)
    }

    @Test("custom init sets all fields")
    func customInit() {
        let info = PrismDebugInfo(
            componentName: "Widget",
            renderCount: 5,
            frameSize: CGSize(width: 300, height: 200),
            accessibilityLabel: "My widget"
        )
        #expect(info.componentName == "Widget")
        #expect(info.renderCount == 5)
        #expect(info.frameSize.width == 300)
        #expect(info.accessibilityLabel == "My widget")
    }
}

// MARK: - PrismEnvironmentSnapshot

@Suite("PrismEnvironmentSnapshot")
struct EnvironmentSnapshotTests {

    @Test("snapshot stores all values")
    func storeValues() {
        let snapshot = PrismEnvironmentSnapshot(
            colorScheme: .dark,
            dynamicTypeSize: .large,
            layoutDirection: .rightToLeft,
            accessibilityEnabled: true,
            reduceMotion: true,
            reduceTransparency: false
        )
        #expect(snapshot.colorScheme == .dark)
        #expect(snapshot.dynamicTypeSize == .large)
        #expect(snapshot.layoutDirection == .rightToLeft)
        #expect(snapshot.accessibilityEnabled == true)
        #expect(snapshot.reduceMotion == true)
        #expect(snapshot.reduceTransparency == false)
    }

    @Test("snapshot with light scheme defaults")
    func lightDefaults() {
        let snapshot = PrismEnvironmentSnapshot(
            colorScheme: .light,
            dynamicTypeSize: .medium,
            layoutDirection: .leftToRight,
            accessibilityEnabled: false,
            reduceMotion: false,
            reduceTransparency: false
        )
        #expect(snapshot.colorScheme == .light)
        #expect(snapshot.dynamicTypeSize == .medium)
        #expect(snapshot.layoutDirection == .leftToRight)
    }

    @Test("snapshot is Sendable")
    func sendable() {
        let s: any Sendable = PrismEnvironmentSnapshot(
            colorScheme: .dark,
            dynamicTypeSize: .large,
            layoutDirection: .leftToRight,
            accessibilityEnabled: false,
            reduceMotion: false,
            reduceTransparency: false
        )
        #expect(s is PrismEnvironmentSnapshot)
    }
}

// MARK: - PrismPredicateBuilder chaining

#if canImport(SwiftData)
    @Suite("PrismPredicateBuilder chaining deep")
    struct PredicateBuilderChainingTests {

        @Test("chaining where → and → or produces correct count")
        func chainThreeOperations() {
            let result = PrismPredicateBuilder()
                .where("name", .equals, "John")
                .and("age", .greaterThan, 18)
                .or("status", .equals, "active")
                .build()
            #expect(result.count == 3)
            #expect(result[0].name == "name")
            #expect(result[0].operator == .equals)
            #expect(result[1].name == "age")
            #expect(result[1].operator == .greaterThan)
            #expect(result[2].name == "status")
            #expect(result[2].operator == .equals)
        }

        @Test("multiple where calls accumulate")
        func multipleWhere() {
            let result = PrismPredicateBuilder()
                .where("a", .equals, 1)
                .where("b", .contains, "test")
                .where("c", .lessThan, 10)
                .build()
            #expect(result.count == 3)
        }

        @Test("builder is value type — copies don't affect original")
        func valueTypeSemantics() {
            let base = PrismPredicateBuilder().where("x", .equals, 1)
            let branch1 = base.and("y", .equals, 2)
            let branch2 = base.and("z", .equals, 3)
            #expect(branch1.build().count == 2)
            #expect(branch2.build().count == 2)
            #expect(base.build().count == 1)
        }

        @Test("filter field value types")
        func filterFieldValues() {
            let stringField = PrismFilterField(name: "name", operator: .contains, value: "test")
            #expect(stringField.name == "name")

            let intField = PrismFilterField(name: "age", operator: .greaterThan, value: 25)
            #expect(intField.operator == .greaterThan)

            let nilField = PrismFilterField(name: "deleted", operator: .isNil)
            #expect(nilField.value == nil)

            let betweenField = PrismFilterField(name: "price", operator: .between, value: [10.0, 100.0])
            #expect(betweenField.operator == .between)
        }

        @Test("PrismFilterOperator raw values")
        func operatorRawValues() {
            #expect(PrismFilterOperator.equals.rawValue == "equals")
            #expect(PrismFilterOperator.contains.rawValue == "contains")
            #expect(PrismFilterOperator.greaterThan.rawValue == "greaterThan")
            #expect(PrismFilterOperator.lessThan.rawValue == "lessThan")
            #expect(PrismFilterOperator.between.rawValue == "between")
            #expect(PrismFilterOperator.isNil.rawValue == "isNil")
            #expect(PrismFilterOperator.isNotNil.rawValue == "isNotNil")
        }
    }

    // MARK: - FieldType & PrismFormField deep

    @Suite("FieldType and PrismFormField deep")
    struct FieldTypeDeepTests {

        @Test("picker equality with same options")
        func pickerEquality() {
            #expect(FieldType.picker(["A", "B"]) == .picker(["A", "B"]))
        }

        @Test("picker inequality with different options")
        func pickerInequality() {
            #expect(FieldType.picker(["A"]) != .picker(["B"]))
        }

        @Test("all field types are distinct")
        func allDistinct() {
            let types: [FieldType] = [.text, .number, .toggle, .date, .picker([])]
            for i in 0..<types.count {
                for j in (i + 1)..<types.count {
                    #expect(types[i] != types[j])
                }
            }
        }

        @Test("PrismFormField stores all properties")
        func formFieldProperties() {
            let field = PrismFormField(label: "Email", keyPath: "email", fieldType: .text)
            #expect(field.label == "Email")
            #expect(field.keyPath == "email")
            #expect(field.fieldType == .text)
        }

        @Test("PrismFormField with picker type")
        func formFieldPicker() {
            let field = PrismFormField(label: "Status", keyPath: "status", fieldType: .picker(["Active", "Inactive"]))
            #expect(field.fieldType == .picker(["Active", "Inactive"]))
        }

        @Test("PrismFormField with all types")
        func allFieldTypes() {
            let fields = [
                PrismFormField(label: "Name", keyPath: "name", fieldType: .text),
                PrismFormField(label: "Age", keyPath: "age", fieldType: .number),
                PrismFormField(label: "Active", keyPath: "active", fieldType: .toggle),
                PrismFormField(label: "DOB", keyPath: "dob", fieldType: .date),
                PrismFormField(label: "Role", keyPath: "role", fieldType: .picker(["Admin", "User"])),
            ]
            #expect(fields.count == 5)
            #expect(fields[0].fieldType == .text)
            #expect(fields[1].fieldType == .number)
            #expect(fields[2].fieldType == .toggle)
            #expect(fields[3].fieldType == .date)
            #expect(fields[4].fieldType == .picker(["Admin", "User"]))
        }
    }
#endif

// MARK: - PrismTextFormatting deep paths

@Suite("PrismTextFormatting deep")
struct TextFormattingDeepTests {

    @Test("heading associates level")
    func headingLevels() {
        for level in 1...6 {
            if case .heading(let l) = PrismTextFormatting.heading(level) {
                #expect(l == level)
            }
        }
    }

    @Test("link associates URL")
    func linkURL() {
        let url = URL(string: "https://example.com")!
        if case .link(let u) = PrismTextFormatting.link(url) {
            #expect(u == url)
        }
    }

    @Test("all formatting cases are Hashable")
    func hashable() {
        let url = URL(string: "https://a.com")!
        let cases: [PrismTextFormatting] = [
            .bold, .italic, .underline, .strikethrough, .code,
            .heading(1), .link(url), .bulletList, .numberedList,
        ]
        var set = Set<PrismTextFormatting>()
        for c in cases { set.insert(c) }
        #expect(set.count == cases.count)
    }

    @Test("same heading level hashes equal")
    func headingHash() {
        #expect(PrismTextFormatting.heading(2) == .heading(2))
    }

    @Test("different heading levels differ")
    func headingDiffer() {
        #expect(PrismTextFormatting.heading(1) != .heading(3))
    }
}

// MARK: - PrismMarkdownStyle deep

@Suite("PrismMarkdownStyle deep")
struct MarkdownStyleDeepTests {

    @Test("is CaseIterable and Sendable")
    func caseIterable() {
        #expect(PrismMarkdownStyle.allCases.count == 3)
    }

    @Test("raw values")
    func rawValues() {
        #expect(PrismMarkdownStyle.default.rawValue == "default")
        #expect(PrismMarkdownStyle.compact.rawValue == "compact")
        #expect(PrismMarkdownStyle.documentation.rawValue == "documentation")
    }

    @Test("init from raw value")
    func initFromRaw() {
        #expect(PrismMarkdownStyle(rawValue: "compact") == .compact)
        #expect(PrismMarkdownStyle(rawValue: "invalid") == nil)
    }
}

// MARK: - MarkdownBlock edge cases

@Suite("MarkdownBlock edge cases")
@MainActor
struct MarkdownBlockEdgeCaseTests {

    private func parse(_ md: String) -> [MarkdownBlock] {
        PrismMarkdownView(md).parseBlocks()
    }

    @Test("empty input returns no blocks")
    func emptyInput() {
        #expect(parse("").isEmpty)
    }

    @Test("only whitespace lines produce no blocks")
    func whitespaceOnly() {
        #expect(parse("   \n   \n   ").isEmpty)
    }

    @Test("code block without closing fence")
    func unclosedCodeBlock() {
        let blocks = parse("```\ncode without end")
        #expect(blocks.count == 1)
        if case .codeBlock(_, let code) = blocks[0] {
            #expect(code == "code without end")
        }
    }

    @Test("nested list markers not consumed cross-type")
    func listThenParagraph() {
        let md = "- Item\nNot a list item"
        let blocks = parse(md)
        #expect(blocks.count == 2)
    }

    @Test("image with empty alt text")
    func imageEmptyAlt() {
        let blocks = parse("![](https://example.com/img.png)")
        #expect(blocks.count == 1)
        if case .image(let alt, _) = blocks[0] {
            #expect(alt == "")
        }
    }

    @Test("two dashes not a horizontal rule")
    func shortDashes() {
        let blocks = parse("--")
        #expect(blocks.count == 1)
        if case .paragraph = blocks[0] {
        } else {
            Issue.record("Expected paragraph for short dashes")
        }
    }

    @Test("ordered list with non-sequential numbers")
    func nonSequentialOrdered() {
        let md = "1. First\n5. Second\n99. Third"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .orderedList(let items) = blocks[0] {
            #expect(items == ["First", "Second", "Third"])
        }
    }

    @Test("heading with extra spaces")
    func headingExtraSpaces() {
        let blocks = parse("#  Spaced")
        if case .heading(let level, let text) = blocks[0] {
            #expect(level == 1)
            #expect(text == "Spaced")
        }
    }
}

// MARK: - Task List Parsing

@Suite("PrismMarkdownView task list parsing")
@MainActor
struct TaskListParsingTests {

    private func parse(_ md: String) -> [MarkdownBlock] {
        PrismMarkdownView(md).parseBlocks()
    }

    @Test("parses unchecked task items")
    func uncheckedItems() {
        let blocks = parse("- [ ] Buy milk\n- [ ] Clean house")
        #expect(blocks.count == 1)
        if case .taskList(let items) = blocks[0] {
            #expect(items.count == 2)
            #expect(items[0].text == "Buy milk")
            #expect(items[0].isChecked == false)
            #expect(items[1].text == "Clean house")
            #expect(items[1].isChecked == false)
        } else {
            Issue.record("Expected taskList")
        }
    }

    @Test("parses checked task items")
    func checkedItems() {
        let blocks = parse("- [x] Done task\n- [X] Also done")
        #expect(blocks.count == 1)
        if case .taskList(let items) = blocks[0] {
            #expect(items.count == 2)
            #expect(items[0].isChecked == true)
            #expect(items[1].isChecked == true)
        } else {
            Issue.record("Expected taskList")
        }
    }

    @Test("parses mixed checked and unchecked")
    func mixedItems() {
        let md = "- [x] Done\n- [ ] Pending\n- [x] Also done"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .taskList(let items) = blocks[0] {
            #expect(items.count == 3)
            #expect(items[0].isChecked == true)
            #expect(items[1].isChecked == false)
            #expect(items[2].isChecked == true)
        } else {
            Issue.record("Expected taskList")
        }
    }

    @Test("task list stops at non-task line")
    func taskListStopsAtRegularLine() {
        let md = "- [x] Task\nRegular paragraph"
        let blocks = parse(md)
        #expect(blocks.count == 2)
        if case .taskList(let items) = blocks[0] {
            #expect(items.count == 1)
        } else {
            Issue.record("Expected taskList first")
        }
        if case .paragraph = blocks[1] {
        } else {
            Issue.record("Expected paragraph second")
        }
    }

    @Test("task list before regular list stays separate")
    func taskListThenRegularList() {
        let md = "- [x] Task item\n- Regular list item"
        let blocks = parse(md)
        #expect(blocks.count == 2)
        if case .taskList = blocks[0] {
        } else {
            Issue.record("Expected taskList")
        }
        if case .unorderedList = blocks[1] {
        } else {
            Issue.record("Expected unorderedList")
        }
    }
}

// MARK: - Table Parsing

@Suite("PrismMarkdownView table parsing")
@MainActor
struct TableParsingTests {

    private func parse(_ md: String) -> [MarkdownBlock] {
        PrismMarkdownView(md).parseBlocks()
    }

    @Test("parses basic table")
    func basicTable() {
        let md = "| Name | Age |\n| --- | --- |\n| Alice | 30 |\n| Bob | 25 |"
        let blocks = parse(md)
        #expect(blocks.count == 1)
        if case .table(let header, let alignments, let rows) = blocks[0] {
            #expect(header == ["Name", "Age"])
            #expect(alignments.count == 2)
            #expect(rows.count == 2)
            #expect(rows[0] == ["Alice", "30"])
            #expect(rows[1] == ["Bob", "25"])
        } else {
            Issue.record("Expected table")
        }
    }

    @Test("parses table alignment markers")
    func tableAlignments() {
        let md = "| L | C | R | N |\n| :--- | :---: | ---: | --- |\n| a | b | c | d |"
        let blocks = parse(md)
        if case .table(_, let alignments, _) = blocks[0] {
            #expect(alignments[0] == .left)
            #expect(alignments[1] == .center)
            #expect(alignments[2] == .right)
            #expect(alignments[3] == .none)
        } else {
            Issue.record("Expected table")
        }
    }

    @Test("table with no body rows")
    func headerOnlyTable() {
        let md = "| H1 | H2 |\n| --- | --- |"
        let blocks = parse(md)
        if case .table(let header, _, let rows) = blocks[0] {
            #expect(header == ["H1", "H2"])
            #expect(rows.isEmpty)
        } else {
            Issue.record("Expected table")
        }
    }

    @Test("table stops at non-pipe line")
    func tableStopsAtParagraph() {
        let md = "| A | B |\n| --- | --- |\n| 1 | 2 |\nNot a table"
        let blocks = parse(md)
        #expect(blocks.count == 2)
        if case .table = blocks[0] {
        } else {
            Issue.record("Expected table first")
        }
        if case .paragraph = blocks[1] {
        } else {
            Issue.record("Expected paragraph second")
        }
    }
}

// MARK: - Strikethrough Inline Parsing

@Suite("PrismMarkdownView strikethrough")
@MainActor
struct StrikethroughParsingTests {

    private func view() -> PrismMarkdownView {
        PrismMarkdownView("")
    }

    @Test("parses strikethrough text")
    func strikethrough() {
        let _: Text = view().parseInlineElements("Hello ~~world~~")
    }

    @Test("parses strikethrough with other formatting")
    func strikethroughMixed() {
        let _: Text = view().parseInlineElements("**bold** and ~~struck~~ and *italic*")
    }

    @Test("parses only strikethrough")
    func onlyStrikethrough() {
        let _: Text = view().parseInlineElements("~~all struck~~")
    }
}

// MARK: - Language Mapping

@Suite("PrismSyntaxLanguage markdownIdentifier")
struct LanguageMappingTests {

    @Test("maps swift")
    func swift() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "swift") == .swift)
    }

    @Test("maps js to javascript")
    func js() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "js") == .javascript)
    }

    @Test("maps jsx to javascript")
    func jsx() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "jsx") == .javascript)
    }

    @Test("maps typescript to javascript")
    func typescript() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "typescript") == .javascript)
    }

    @Test("maps ts to javascript")
    func ts() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "ts") == .javascript)
    }

    @Test("maps py to python")
    func py() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "py") == .python)
    }

    @Test("maps python3 to python")
    func python3() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "python3") == .python)
    }

    @Test("maps xml to html")
    func xml() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "xml") == .html)
    }

    @Test("maps scss to css")
    func scss() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "scss") == .css)
    }

    @Test("maps jsonc to json")
    func jsonc() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "jsonc") == .json)
    }

    @Test("maps unknown to plainText")
    func unknown() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "brainfuck") == .plainText)
    }

    @Test("maps empty to plainText")
    func empty() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "") == .plainText)
    }

    @Test("case insensitive mapping")
    func caseInsensitive() {
        #expect(PrismSyntaxLanguage(markdownIdentifier: "SWIFT") == .swift)
        #expect(PrismSyntaxLanguage(markdownIdentifier: "Python") == .python)
        #expect(PrismSyntaxLanguage(markdownIdentifier: "JavaScript") == .javascript)
    }
}

// MARK: - PrismTaskItem

@Suite("PrismTaskItem")
struct PrismTaskItemTests {

    @Test("stores text and checked state")
    func properties() {
        let item = PrismTaskItem(text: "Buy milk", isChecked: true)
        #expect(item.text == "Buy milk")
        #expect(item.isChecked == true)
    }

    @Test("unchecked by default via init")
    func unchecked() {
        let item = PrismTaskItem(text: "Task", isChecked: false)
        #expect(item.isChecked == false)
    }

    @Test("conforms to Sendable")
    func sendable() {
        let item: any Sendable = PrismTaskItem(text: "T", isChecked: false)
        #expect(type(of: item) is PrismTaskItem.Type)
    }
}

// MARK: - PrismTableAlignment

@Suite("PrismTableAlignment")
struct PrismTableAlignmentTests {

    @Test("has four cases")
    func cases() {
        let left = PrismTableAlignment.left
        let center = PrismTableAlignment.center
        let right = PrismTableAlignment.right
        let none = PrismTableAlignment.none
        #expect(left != center)
        #expect(right != none)
    }

    @Test("conforms to Sendable")
    func sendable() {
        let alignment: any Sendable = PrismTableAlignment.center
        #expect(type(of: alignment) is PrismTableAlignment.Type)
    }
}
