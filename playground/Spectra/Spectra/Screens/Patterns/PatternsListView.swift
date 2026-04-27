//
//  PatternsListView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import PrismArchitecture
import SwiftUI

struct PatternsListView: View {
    @Environment(\.theme) private var theme
    @Bindable private var router = PrismRouter<PlaygroundRoute>()

    private let patterns: [PlaygroundPattern] = [
        .formPattern,
        .cardPattern,
        .listDetailPattern,
        .dashboardPattern,
        .onboardingPattern,
        .settingsPattern,
        .feedPattern,
        .profilePattern,
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.extraLarge) {
                patternsGrid

                intelligenceSection
            }
            .padding(.horizontal, theme.spacing.medium)
            .padding(.vertical, theme.spacing.medium)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Patterns")
    }

    // MARK: - Patterns Grid

    private var patternsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: theme.spacing.medium),
                GridItem(.flexible(), spacing: theme.spacing.medium),
            ],
            spacing: theme.spacing.medium
        ) {
            ForEach(patterns, id: \.self) { pattern in
                PatternCardView(pattern: pattern)
                    .opacity(0.6)
                    .overlay(
                        Text("Em breve")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(theme.color.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .clipShape(Capsule())
                            .padding([.top, .trailing], 8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    )
            }
        }
    }

    // MARK: - Intelligence Section

    private var intelligenceSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.medium) {
            HStack(spacing: theme.spacing.small) {
                Image(systemName: "brain.headset")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(theme.color.primary)

                Text("Sobre Patterns")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.color.text)

                Spacer()
            }

            Text("Patterns são soluções reutilizáveis para problemas comuns de UI. Eles combinam Atoms e Molecules em arranjos padronizados que resolvem necessidades específicas.")
                .font(.system(size: 15))
                .foregroundStyle(theme.color.textSecondary)

            HStack {
                Text("8 patterns")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.color.info)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(theme.color.info.opacity(0.15))
                    .clipShape(Capsule())

                Spacer()
            }
        }
        .padding(theme.spacing.medium)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Pattern Card View

private struct PatternCardView: View {
    @Environment(\.theme) private var theme
    let pattern: PlaygroundPattern

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.small) {
            Image(systemName: pattern.icon)
                .font(.system(size: 32))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(pattern.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text(pattern.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.color.text)
                .lineLimit(1)

            Text(pattern.description)
                .font(.system(size: 13))
                .foregroundStyle(theme.color.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(theme.spacing.medium)
        .frame(height: 140)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Playground Pattern Model

enum PlaygroundPattern: Hashable, CaseIterable {
    case formPattern
    case cardPattern
    case listDetailPattern
    case dashboardPattern
    case onboardingPattern
    case settingsPattern
    case feedPattern
    case profilePattern

    var title: String {
        switch self {
        case .formPattern: "Formulário"
        case .cardPattern: "Card"
        case .listDetailPattern: "List-Detail"
        case .dashboardPattern: "Dashboard"
        case .onboardingPattern: "Onboarding"
        case .settingsPattern: "Settings"
        case .feedPattern: "Feed"
        case .profilePattern: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .formPattern: "textformat.abc"
        case .cardPattern: "square.split.2x2"
        case .listDetailPattern: "list.bullet.indent"
        case .dashboardPattern: "gauge"
        case .onboardingPattern: "flag.checkered"
        case .settingsPattern: "gearshape.fill"
        case .feedPattern: "newspaper"
        case .profilePattern: "person.crop.circle"
        }
    }

    var color: Color {
        switch self {
        case .formPattern: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .cardPattern: .init(red: 0.6, green: 0.3, blue: 0.8)
        case .listDetailPattern: .init(red: 0.1, green: 0.7, blue: 0.4)
        case .dashboardPattern: .init(red: 0.9, green: 0.3, blue: 0.5)
        case .onboardingPattern: .init(red: 1.0, green: 0.6, blue: 0.0)
        case .settingsPattern: .init(red: 0.5, green: 0.5, blue: 0.5)
        case .feedPattern: .init(red: 0.0, green: 0.5, blue: 0.9)
        case .profilePattern: .init(red: 0.8, green: 0.4, blue: 0.1)
        }
    }

    var description: String {
        switch self {
        case .formPattern: "Padrão de formulário com validação"
        case .cardPattern: "Card com conteúdo e ações"
        case .listDetailPattern: "Navegação mestre-detalhe"
        case .dashboardPattern: "Dashboard com métricas e gráficos"
        case .onboardingPattern: "Fluxo de onboarding passo-a-passo"
        case .settingsPattern: "Tela de configurações e ajustes"
        case .feedPattern: "Feed de conteúdo scrollável"
        case .profilePattern: "Perfil de usuário com informações"
        }
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        PatternsListView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
