//
//  ButtonDemoView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismIntelligence
import PrismUI
import PrismArchitecture
import SwiftUI

struct ButtonDemoView: View {
    @Environment(\.theme) private var theme
    @State private var isToggleOn = false
    @State private var showSheet = false
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.extraLarge) {
                // Basic Usage Section
                demoSection(title: "Uso Básico") {
                    PrismVStack(spacing: .medium) {
                        PrismButton("Clique aqui", testID: "toggle_button") {
                            isToggleOn.toggle()
                        }

                        PrismFootnoteText("Estado: \(isToggleOn ? "Ativado" : "Desativado")")
                            .prism(color: .textSecondary)
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // PrismButton Styles Section
                demoSection(title: "PrismButton") {
                    PrismVStack(spacing: .medium) {
                        PrismHStack(spacing: .medium) {
                            PrismButton("Default", testID: "default_button") {}
                            PrismButton("Disabled", testID: "disabled_button") {}
                                .disabled(true)
                        }
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // PrismPrimaryButton Section
                demoSection(title: "PrismPrimaryButton") {
                    PrismVStack(spacing: .medium) {
                        PrismPrimaryButton("Ação Principal", testID: "primary_button") {
                            isLoading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isLoading = false
                            }
                        }
                        .disabled(isLoading)

                        PrismPrimaryButton("Destrutivo", testID: "destructive_button", role: .destructive) {
                            showSheet = true
                        }

                        PrismPrimaryButton("Cancelar", testID: "cancel_button", role: .cancel) {}
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // PrismSecondaryButton Section
                demoSection(title: "PrismSecondaryButton") {
                    PrismVStack(spacing: .medium) {
                        PrismSecondaryButton("Ação Secundária", testID: "secondary_button") {}

                        PrismSecondaryButton("Destrutivo", testID: "secondary_destructive_button", role: .destructive) {}

                        PrismSecondaryButton("Cancelar", testID: "secondary_cancel_button", role: .cancel) {}
                    }
                    .prismPadding()
                    .prismBackgroundSecondary()
                    .prism(clip: .rounded(radius: 12))
                }

                // Intelligence Section
                intelligenceSection
            }
            .padding(.horizontal, theme.spacing.medium)
            .padding(.vertical, theme.spacing.medium)
        }
        .background(theme.color.background)
        .navigationTitle("Buttons")
        .sheet(isPresented: $showSheet) {
            PrismVStack(spacing: .medium) {
                PrismSymbol("exclamationmark.triangle.fill")
                    .prism(font: .largeTitle)
                    .prism(color: .error)

                PrismText("Ação destrutiva confirmada!")
                    .prism(font: .headline)

                PrismPrimaryButton("OK") {
                    showSheet = false
                }
            }
            .prismPadding()
        }
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
                "Botões no PrismUI seguem princípios de acessibilidade e oferecem feedback tátil (haptic) no iOS. Use PrismPrimaryButton para a ação principal (CTA) e PrismSecondaryButton para ações secundárias."
            )

            PrismHStack(spacing: .small) {
                PrismTag("Acessibilidade", style: .info, size: .small)
                PrismTag("Haptic", style: .success, size: .small)
                PrismTag("testID", style: .warning, size: .small)
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
        ButtonDemoView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
