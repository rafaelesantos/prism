//
//  RyzeTextField.swift
//  Ryze
//
//  Created by Rafael Escaleira on 07/06/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzeTextField: RyzeView {
    @Environment(\.theme) var theme
    @FocusState var isFocused: Bool
    @Binding var text: String
    @State var error: RyzeError?

    let configuration: RyzeTextFieldConfiguration
    public var accessibility: RyzeAccessibility?

    public init(
        text: Binding<String>,
        _ accessibility: RyzeAccessibility? = nil,
        configuration: RyzeTextFieldConfiguration
    ) {
        self._text = text
        self.accessibility = accessibility
        self.configuration = configuration
    }

    var needFocus: Bool {
        isFocused || !text.isEmpty
    }

    var stateColor: RyzeColor {
        error == nil && !text.isEmpty ? .success : error == nil ? .secondary : .error
    }

    public var body: some View {
        Button {
            isFocused = true
        } label: {
            RyzeVStack(alignment: .leading) {
                contentTextField
                    .overlay(alignment: .topLeading) { placeholderView }

                errorView
            }
            .animation(theme.animation, value: isFocused)
            .animation(theme.animation, value: text.isEmpty)
            .animation(theme.animation, value: error?.localizedDescription)
            .onChange(of: text) { validate() }
        }
        .ryze(accessibility: accessibility)
    }

    var contentTextField: some View {
        TextField(
            "",
            text: $text,
            axis: .vertical
        )
        .focused($isFocused)
        .autocorrectionDisabled()
        #if os(iOS)
            .keyboardType(configuration.contentType.rawValue)
            .textInputAutocapitalization(configuration.autocapitalizationType.rawValue)
        #endif
        .submitLabel(configuration.submitLabel)
        .ryze(alignment: .leading)
        .ryzePadding(.horizontal, .extraLarge)
        .ryzePadding(.horizontal, .small)
        .overlay(alignment: .leading) { iconView }
        .overlay(alignment: .trailing) { clearButton }
        .ryzePadding()
        .ryzeBackgroundSecondary()
        .ryze(clip: .rounded(radius: theme.radius.large))
    }

    func validate() {
        do {
            try configuration.validate(text: text)
            self.error = nil
        } catch let error as RyzeError {
            self.error = error
        } catch {

        }
    }

    var clearButton: some View {
        Button {
            text = ""
            isFocused = true
        } label: {
            RyzeSymbol(
                "xmark.circle.fill",
                mode: .hierarchical
            )
            .ryze(font: .body)
            .ryze(color: .textSecondary)
            .offset(x: needFocus && !text.isEmpty ? .zero : 50)
            .opacity(0.5)
            .scaleEffect(0.8)
        }
    }

    @ViewBuilder
    var iconView: some View {
        if let icon = configuration.icon {
            RyzeSymbol(icon)
                .ryze(font: .footnote)
                .ryze(color: stateColor)
                .ryzeGlow(for: error == nil ? nil : theme.color.error)
                .offset(x: needFocus ? .zero : -50)
        }
    }

    @ViewBuilder
    var placeholderView: some View {
        RyzeText(configuration.placeholder)
            .ryze(font: needFocus ? .footnote : .body)
            .ryze(color: .disabled)
            .lineLimit(1)
            .ryzePadding()
            .offset(y: needFocus ? -40 : .zero)
    }

    @ViewBuilder
    var errorView: some View {
        if error != nil {
            RyzeVStack(alignment: .leading) {
                failureReasonView
                recoverySuggestionView
            }
            .ryze(width: .max)
            .transition(.blurReplace)
        }
    }

    @ViewBuilder
    var failureReasonView: some View {
        if let failureReason = error?.failureReason {
            RyzeHStack(spacing: .small) {
                RyzeSymbol(
                    "xmark.circle.fill",
                    mode: .hierarchical
                )
                .ryze(font: .footnote)
                .ryze(color: .error)

                RyzeText(failureReason)
                    .ryze(font: needFocus ? .footnote : .body)
                    .ryze(color: .disabled)
                    .ryze(alignment: .leading)
            }
        }
    }

    @ViewBuilder
    var recoverySuggestionView: some View {
        if let recoverySuggestion = error?.recoverySuggestion {
            RyzeHStack(spacing: .small) {
                RyzeSymbol(
                    "lightbulb.max.fill",
                    mode: .hierarchical
                )
                .ryze(font: .footnote)
                .ryze(color: .success)

                RyzeText(recoverySuggestion)
                    .ryze(font: needFocus ? .footnote : .body)
                    .ryze(color: .disabled)
                    .ryze(alignment: .leading)
            }
        }
    }

    public static func mocked() -> some View {
        RyzeTextField(
            text: .constant(""),
            configuration: RyzeDefaultTextFieldConfiguration.email
        )
    }
}

#Preview {
    @Previewable @State var text: String = ""
    RyzeTextField(
        text: $text,
        configuration: RyzeDefaultTextFieldConfiguration.email
    )
    .ryzePadding()
}
