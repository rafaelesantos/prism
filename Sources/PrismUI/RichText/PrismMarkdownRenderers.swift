import SwiftUI

// MARK: - Markdown Renderers

extension PrismMarkdownView {

    // MARK: - Block Renderer

    @ViewBuilder
    package func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block {
        case .heading(let level, let text):
            renderHeading(level: level, text: text)
        case .paragraph(let text):
            renderInlineText(text)
                .font(TypographyToken.body.font)
                .foregroundStyle(theme.color(.onBackground))
                .lineSpacing(4)
        case .codeBlock(let language, let code):
            renderCodeBlock(code, language: language)
        case .blockquote(let text):
            renderBlockquote(text)
        case .unorderedList(let items):
            renderUnorderedList(items)
        case .orderedList(let items):
            renderOrderedList(items)
        case .taskList(let items):
            renderTaskList(items)
        case .table(let header, let alignments, let rows):
            renderTable(header: header, alignments: alignments, rows: rows)
        case .horizontalRule:
            Rectangle()
                .fill(theme.color(.separator))
                .frame(height: 2)
                .padding(.vertical, SpacingToken.xl.rawValue)
        case .image(let alt, let url):
            renderImage(alt: alt, url: url)
        }
    }

    // MARK: - Heading

    @ViewBuilder
    package func renderHeading(level: Int, text: String) -> some View {
        let token: TypographyToken =
            switch level {
            case 1: .largeTitle
            case 2: .title
            case 3: .title2
            case 4: .title3
            case 5: .headline
            default: .subheadline
            }

        VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
            renderInlineText(text)
                .font(token.font)
                .foregroundStyle(theme.color(.onBackground))
                .accessibilityAddTraits(.isHeader)

            if level <= 2 {
                Rectangle()
                    .fill(theme.color(.separator))
                    .frame(height: 1)
            }
        }
        .padding(.top, level <= 2 ? SpacingToken.xl.rawValue : SpacingToken.lg.rawValue)
    }

    // MARK: - Inline Text

    package func renderInlineText(_ text: String) -> Text {
        parseInlineElements(text)
    }

    package func parseInlineElements(_ text: String) -> Text {
        var result = AttributedString()
        var remaining = text[text.startIndex..<text.endIndex]

        while !remaining.isEmpty {
            // Bold + italic (***text***)
            if let range = remaining.range(of: #"\*\*\*(.+?)\*\*\*"#, options: .regularExpression) {
                appendPlain(to: &result, from: remaining, upTo: range.lowerBound)
                let inner = String(remaining[range]).dropFirst(3).dropLast(3)
                var attr = AttributedString(String(inner))
                attr.font = .body.bold().italic()
                result.append(attr)
                remaining = remaining[range.upperBound...]
                continue
            }

            // Strikethrough (~~text~~)
            if let range = remaining.range(of: #"~~(.+?)~~"#, options: .regularExpression) {
                appendPlain(to: &result, from: remaining, upTo: range.lowerBound)
                let inner = String(remaining[range]).dropFirst(2).dropLast(2)
                var attr = AttributedString(String(inner))
                attr.strikethroughStyle = .single
                result.append(attr)
                remaining = remaining[range.upperBound...]
                continue
            }

            // Bold (**text**)
            if let range = remaining.range(of: #"\*\*(.+?)\*\*"#, options: .regularExpression) {
                appendPlain(to: &result, from: remaining, upTo: range.lowerBound)
                let inner = String(remaining[range]).dropFirst(2).dropLast(2)
                var attr = AttributedString(String(inner))
                attr.font = .body.bold()
                result.append(attr)
                remaining = remaining[range.upperBound...]
                continue
            }

            // Italic (*text*)
            if let range = remaining.range(of: #"\*(.+?)\*"#, options: .regularExpression) {
                appendPlain(to: &result, from: remaining, upTo: range.lowerBound)
                let inner = String(remaining[range]).dropFirst(1).dropLast(1)
                var attr = AttributedString(String(inner))
                attr.font = .body.italic()
                result.append(attr)
                remaining = remaining[range.upperBound...]
                continue
            }

            // Inline code (`code`) with background pill
            if let range = remaining.range(of: #"`([^`]+)`"#, options: .regularExpression) {
                appendPlain(to: &result, from: remaining, upTo: range.lowerBound)
                let inner = String(remaining[range]).dropFirst(1).dropLast(1)
                var attr = AttributedString("\u{00A0}\(inner)\u{00A0}")
                attr.font = .system(.callout, design: .monospaced)
                #if canImport(UIKit)
                    attr.backgroundColor = UIColor.secondarySystemBackground
                    attr.foregroundColor = UIColor.label
                #elseif os(macOS)
                    attr.backgroundColor = NSColor.controlBackgroundColor
                    attr.foregroundColor = NSColor.labelColor
                #endif
                result.append(attr)
                remaining = remaining[range.upperBound...]
                continue
            }

            // Link [text](url)
            if let range = remaining.range(of: #"\[([^\]]+)\]\(([^)]+)\)"#, options: .regularExpression) {
                appendPlain(to: &result, from: remaining, upTo: range.lowerBound)
                let matched = String(remaining[range])
                let linkText = extractBracketContent(matched, open: "[", close: "]")
                let linkURL = extractBracketContent(matched, open: "(", close: ")")
                var attr = AttributedString(linkText)
                if let url = URL(string: linkURL) {
                    attr.link = url
                    attr.underlineStyle = .single
                }
                result.append(attr)
                remaining = remaining[range.upperBound...]
                continue
            }

            // No match — consume rest
            result.append(AttributedString(String(remaining)))
            break
        }

        return Text(result)
    }

    private func appendPlain(
        to result: inout AttributedString,
        from remaining: Substring,
        upTo bound: String.Index
    ) {
        let before = remaining[remaining.startIndex..<bound]
        if !before.isEmpty {
            result.append(AttributedString(String(before)))
        }
    }

    // MARK: - Code Block

    @ViewBuilder
    package func renderCodeBlock(_ code: String, language: String) -> some View {
        PrismCodeBlock(
            code,
            language: PrismSyntaxLanguage(markdownIdentifier: language),
            showLineNumbers: code.contains("\n")
        )
    }

    // MARK: - Blockquote

    @ViewBuilder
    package func renderBlockquote(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(theme.color(.borderSubtle))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: SpacingToken.sm.rawValue) {
                ForEach(
                    Array(
                        text.components(separatedBy: "\n")
                            .filter { !$0.isEmpty }
                            .enumerated()
                    ), id: \.offset
                ) { _, line in
                    renderInlineText(line)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                }
            }
            .padding(.leading, SpacingToken.md.rawValue)
        }
        .padding(.vertical, SpacingToken.sm.rawValue)
        .accessibilityLabel("Blockquote: \(text)")
    }

    // MARK: - Lists

    @ViewBuilder
    package func renderUnorderedList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm.rawValue) {
                    Text("\u{2022}")
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                    renderInlineText(item)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackground))
                }
            }
        }
        .padding(.leading, SpacingToken.md.rawValue)
    }

    @ViewBuilder
    package func renderOrderedList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm.rawValue) {
                    Text("\(index + 1).")
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                        .frame(minWidth: 20, alignment: .trailing)
                    renderInlineText(item)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(theme.color(.onBackground))
                }
            }
        }
        .padding(.leading, SpacingToken.md.rawValue)
    }

    // MARK: - Task List

    @ViewBuilder
    package func renderTaskList(_ items: [PrismTaskItem]) -> some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.rawValue) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: SpacingToken.sm.rawValue) {
                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                        .font(TypographyToken.body.font)
                        .foregroundStyle(
                            item.isChecked
                                ? theme.color(.interactive)
                                : theme.color(.onBackgroundTertiary)
                        )
                        .accessibilityLabel(item.isChecked ? "Completed" : "Not completed")

                    renderInlineText(item.text)
                        .font(TypographyToken.body.font)
                        .foregroundStyle(
                            item.isChecked
                                ? theme.color(.onBackgroundSecondary)
                                : theme.color(.onBackground)
                        )
                        .strikethrough(item.isChecked, color: theme.color(.onBackgroundTertiary))
                }
            }
        }
        .padding(.leading, SpacingToken.md.rawValue)
    }

    // MARK: - Table

    @ViewBuilder
    package func renderTable(
        header: [String],
        alignments: [PrismTableAlignment],
        rows: [[String]]
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            tableRow(cells: header, alignments: alignments, isHeader: true)

            Rectangle()
                .fill(theme.color(.border))
                .frame(height: 1)

            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                tableRow(cells: row, alignments: alignments, isHeader: false)

                if index < rows.count - 1 {
                    Rectangle()
                        .fill(theme.color(.borderSubtle))
                        .frame(height: 0.5)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.sm.rawValue))
        .overlay(
            RoundedRectangle(cornerRadius: RadiusToken.sm.rawValue)
                .stroke(theme.color(.borderSubtle), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Table with \(header.count) columns and \(rows.count) rows")
    }

    @ViewBuilder
    private func tableRow(
        cells: [String],
        alignments: [PrismTableAlignment],
        isHeader: Bool
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(cells.enumerated()), id: \.offset) { index, cell in
                let alignment: Alignment = {
                    guard index < alignments.count else { return .leading }
                    switch alignments[index] {
                    case .left, .none: return .leading
                    case .center: return .center
                    case .right: return .trailing
                    }
                }()

                renderInlineText(cell)
                    .font(isHeader ? TypographyToken.headline.font : TypographyToken.body.font)
                    .foregroundStyle(theme.color(.onBackground))
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .padding(.horizontal, SpacingToken.sm.rawValue)
                    .padding(.vertical, SpacingToken.xs.rawValue)

                if index < cells.count - 1 {
                    Rectangle()
                        .fill(theme.color(.borderSubtle))
                        .frame(width: 0.5)
                }
            }
        }
        .background(isHeader ? theme.color(.surfaceSecondary) : theme.color(.surface))
    }

    // MARK: - Image

    @ViewBuilder
    package func renderImage(alt: String, url: String) -> some View {
        if let imageURL = URL(string: url) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: RadiusToken.md.rawValue))
                        .accessibilityLabel(alt)
                case .failure:
                    Label(alt.isEmpty ? "Image" : alt, systemImage: "photo")
                        .foregroundStyle(theme.color(.onBackgroundSecondary))
                default:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 100)
                }
            }
        }
    }
}
