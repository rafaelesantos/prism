//
//  TextDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import SwiftUI
import PrismArchitecture

struct TextDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.extraLarge) {
                // PrismText Variants
                demoSection(title: "PrismText Variants") {
                    PrismVStack(alignment: .leading, spacing: .small) {
                        PrismText("Title Large")
                            .prism(font: .system(size: 34, weight: .regular))

                        PrismText("Title")
                            .prism(font: .title)

                        PrismText("Headline")
                            .prism(font: .headline)

                        PrismText("Body")
                            .prism(font: .body)

                        PrismText("Callout")
                            .prism(font: .callout)

                        PrismText("Footnote")
                            .prism(font: .footnote)

                        PrismText("Caption")
                            .prism(font: .caption)

                        PrismText("Caption 2")
                            .prism(font: .caption2)
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // PrismBodyText
                demoSection(title: "PrismBodyText") {
                    PrismVStack(alignment: .leading, spacing: .small) {
                        PrismBodyText(
                            "Este é um componente de texto de corpo pré-estilizado. Ele usa automaticamente a fonte body e a cor de texto primária do tema."
                        )
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // PrismFootnoteText
                demoSection(title: "PrismFootnoteText") {
                    PrismVStack(alignment: .leading, spacing: .small) {
                        PrismFootnoteText(
                            "Texto secundário ideal para legendas, descrições auxiliares e metadados. Usa automaticamente footnote font e textSecondary color."
                        )
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // Loading State
                demoSection(title: "Loading State") {
                    PrismVStack(alignment: .leading, spacing: .medium) {
                        PrismHStack {
                            PrismText("Carregando...")
                                .prism(loading: isLoading)

                            PrismSpacer()

                            PrismButton(isLoading ? "Ocultar" : "Mostrar", testID: "toggle_loading_button") {
                                isLoading.toggle()
                            }
                        }

                        PrismBodyText("Skeleton automático quando isLoading = true")
                            .prism(loading: isLoading)

                        PrismFootnoteText("Funciona com qualquer texto")
                            .prism(loading: isLoading)
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // Font Weights
                demoSection(title: "Font Weights") {
                    PrismVStack(alignment: .leading, spacing: .small) {
                        PrismText("Ultra Light")
                            .prism(font: .body, weight: .ultraLight)
                        PrismText("Thin")
                            .prism(font: .body, weight: .thin)
                        PrismText("Light")
                            .prism(font: .body, weight: .light)
                        PrismText("Regular")
                            .prism(font: .body, weight: .regular)
                        PrismText("Medium")
                            .prism(font: .body, weight: .medium)
                        PrismText("Semibold")
                            .prism(font: .body, weight: .semibold)
                        PrismText("Bold")
                            .prism(font: .body, weight: .bold)
                        PrismText("Heavy")
                            .prism(font: .body, weight: .heavy)
                        PrismText("Black")
                            .prism(font: .body, weight: .black)
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // Intelligence
                intelligenceSection
            }
            .padding(.horizontal, theme.spacing.medium)
            .padding(.vertical, theme.spacing.medium)
        }
        .background(theme.color.background)
        .navigationTitle("Text")
    }

    // MARK: - Demo Section

    @ViewBuilder
    private func demoSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        PrismVStack(alignment: .leading, spacing: .small) {
            PrismText(title)
                .prism(font: .footnote)
                .prism(color: .textSecondary)
                .padding(.horizontal, theme.spacing.small)

            content()
        }
    }

    // MARK: - Intelligence Section

    private var intelligenceSection: some View {
        PrismVStack(alignment: .leading, spacing: .medium) {
            PrismHStack(spacing: .small) {
                PrismSymbol("brain.headset", mode: .hierarchical)
                    .prism(color: .primary)

                PrismText("Intelligence")
                    .prism(font: .headline)
            }

            PrismBodyText(
                "O sistema de tipografia do PrismUI é baseado em tokens semânticos. Use PrismBodyText e PrismFootnoteText para consistência. O estado de loading exibe skeleton automaticamente."
            )

            PrismHStack(spacing: .small) {
                PrismTag("Tokens", style: .info, size: .small)
                PrismTag("Skeleton", style: .success, size: .small)
                PrismTag("Semântico", style: .warning, size: .small)
            }
        }
        .prismPadding()
        .prismBackgroundSecondary()
        .prism(clip: .rounded(radius: 16))
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        TextDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
