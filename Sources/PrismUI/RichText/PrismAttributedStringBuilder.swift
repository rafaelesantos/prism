import SwiftUI

public struct PrismAttributedStringBuilder: Sendable {
    private var segments: [AttributedString]

    public init() {
        self.segments = []
    }

    public func text(_ string: String) -> PrismAttributedStringBuilder {
        var copy = self
        copy.segments.append(AttributedString(string))
        return copy
    }

    public func bold(_ string: String) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.font = .body.bold()
        copy.segments.append(attr)
        return copy
    }

    public func italic(_ string: String) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.font = .body.italic()
        copy.segments.append(attr)
        return copy
    }

    public func code(_ string: String) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.font = .system(.body, design: .monospaced)
        copy.segments.append(attr)
        return copy
    }

    public func link(_ string: String, url: URL) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.link = url
        attr.underlineStyle = .single
        copy.segments.append(attr)
        return copy
    }

    public func colored(_ string: String, color: Color) -> PrismAttributedStringBuilder {
        var copy = self
        var attr = AttributedString(string)
        attr.foregroundColor = color
        copy.segments.append(attr)
        return copy
    }

    public func newline() -> PrismAttributedStringBuilder {
        var copy = self
        copy.segments.append(AttributedString("\n"))
        return copy
    }

    public func build() -> AttributedString {
        var result = AttributedString()
        for segment in segments {
            result.append(segment)
        }
        return result
    }
}

// MARK: - Result Builder

@resultBuilder
public struct PrismTextBuilder {
    public static func buildBlock(_ components: AttributedString...) -> AttributedString {
        var result = AttributedString()
        for component in components {
            result.append(component)
        }
        return result
    }

    public static func buildOptional(_ component: AttributedString?) -> AttributedString {
        component ?? AttributedString()
    }

    public static func buildEither(first component: AttributedString) -> AttributedString {
        component
    }

    public static func buildEither(second component: AttributedString) -> AttributedString {
        component
    }

    public static func buildArray(_ components: [AttributedString]) -> AttributedString {
        var result = AttributedString()
        for component in components {
            result.append(component)
        }
        return result
    }
}

// MARK: - Convenience Extensions

extension AttributedString {
    public static func prismBold(_ string: String) -> AttributedString {
        var attr = AttributedString(string)
        attr.font = .body.bold()
        return attr
    }

    public static func prismItalic(_ string: String) -> AttributedString {
        var attr = AttributedString(string)
        attr.font = .body.italic()
        return attr
    }

    public static func prismCode(_ string: String) -> AttributedString {
        var attr = AttributedString(string)
        attr.font = .system(.body, design: .monospaced)
        return attr
    }

    public static func prismLink(_ string: String, url: URL) -> AttributedString {
        var attr = AttributedString(string)
        attr.link = url
        attr.underlineStyle = .single
        return attr
    }
}
