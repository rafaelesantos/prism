//
//  ModifiersListView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import PrismArchitecture
import SwiftUI

struct ModifiersListView: View {
    @Environment(\.theme) private var theme
    @Bindable private var router = PrismRouter<PlaygroundRoute>()

    private let modifiers: [PlaygroundModifier] = [
        .glow,
        .skeleton,
        .confetti,
        .parallax,
        .background,
        .backgroundSecondary,
        .backgroundRow,
        .size,
        .spacing,
        .screenObserve,
        .accessibility,
        .symbolEffect,
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.extraLarge) {
                modifiersGrid

                intelligenceSection
            }
            .padding(.horizontal, theme.spacing.medium)
            .padding(.vertical, theme.spacing.medium)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Modifiers")
    }

    // MARK: - Modifiers Grid

    private var modifiersGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: theme.spacing.medium),
                GridItem(.flexible(), spacing: theme.spacing.medium),
            ],
            spacing: theme.spacing.medium
        ) {
            ForEach(modifiers, id: \.self) { modifier in
                Button {
                    if let route = modifier.demoRoute {
                        router.push(route)
                    }
                } label: {
                    ModifierCardView(modifier: modifier)
                }
                .buttonStyle(.plain)
                .disabled(modifier.demoRoute == nil)
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

                Text("Sobre Modifiers")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.color.text)

                Spacer()
            }

            Text("Modifiers são transformadores que aplicam efeitos, animações, comportamentos e estilizações às views. Eles seguem o padrão de composição do SwiftUI.")
                .font(.system(size: 15))
                .foregroundStyle(theme.color.textSecondary)

            HStack {
                Text("12 modifiers")
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

// MARK: - Modifier Card View

private struct ModifierCardView: View {
    @Environment(\.theme) private var theme
    let modifier: PlaygroundModifier

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.small) {
            Image(systemName: modifier.icon)
                .font(.system(size: 32))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(modifier.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text(modifier.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.color.text)
                .lineLimit(1)

            Text(modifier.description)
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
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .opacity(modifier.demoRoute == nil ? 0.6 : 1.0)
        .overlay(
            Group {
                if modifier.demoRoute == nil {
                    Text("Em breve")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(theme.color.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .clipShape(Capsule())
                        .padding([.top, .trailing], 8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
        )
    }
}

// MARK: - Playground Modifier Model

enum PlaygroundModifier: Hashable, CaseIterable {
    case glow
    case skeleton
    case confetti
    case parallax
    case background
    case backgroundSecondary
    case backgroundRow
    case size
    case spacing
    case screenObserve
    case accessibility
    case symbolEffect

    var title: String {
        switch self {
        case .glow: "Glow"
        case .skeleton: "Skeleton"
        case .confetti: "Confetti"
        case .parallax: "Parallax"
        case .background: "Background"
        case .backgroundSecondary: "BackgroundSecondary"
        case .backgroundRow: "BackgroundRow"
        case .size: "Size"
        case .spacing: "Spacing"
        case .screenObserve: "ScreenObserve"
        case .accessibility: "Accessibility"
        case .symbolEffect: "SymbolEffect"
        }
    }

    var icon: String {
        switch self {
        case .glow: "light.beacon.max.fill"
        case .skeleton: "rectangle.dashed"
        case .confetti: "party.popper.fill"
        case .parallax: "view.2d"
        case .background: "square.fill"
        case .backgroundSecondary: "square.2.layers.3d"
        case .backgroundRow: "list.and.film"
        case .size: "arrow.up.left.and.arrow.down.right"
        case .spacing: "arrow.left.and.right"
        case .screenObserve: "eye"
        case .accessibility: "accessibility"
        case .symbolEffect: "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .glow: .init(red: 1.0, green: 0.6, blue: 0.0)
        case .skeleton: .init(red: 0.6, green: 0.6, blue: 0.6)
        case .confetti: .init(red: 0.9, green: 0.3, blue: 0.5)
        case .parallax: .init(red: 0.6, green: 0.3, blue: 0.8)
        case .background: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .backgroundSecondary: .init(red: 0.3, green: 0.5, blue: 0.9)
        case .backgroundRow: .init(red: 0.4, green: 0.6, blue: 0.9)
        case .size: .init(red: 0.1, green: 0.7, blue: 0.4)
        case .spacing: .init(red: 0.2, green: 0.6, blue: 0.5)
        case .screenObserve: .init(red: 0.5, green: 0.3, blue: 0.9)
        case .accessibility: .init(red: 0.0, green: 0.5, blue: 0.9)
        case .symbolEffect: .init(red: 0.8, green: 0.4, blue: 0.1)
        }
    }

    var description: String {
        switch self {
        case .glow: "Efeito de brilho animado com gradiente"
        case .skeleton: "Estado de loading com placeholder"
        case .confetti: "Chuva de partículas para celebrações"
        case .parallax: "Efeito 3D baseado no movimento do dispositivo"
        case .background: "Background padrão do tema"
        case .backgroundSecondary: "Background secundário do tema"
        case .backgroundRow: "Background adaptativo para rows"
        case .size: "Dimensões semânticas com tokens"
        case .spacing: "Padding com tokens de spacing"
        case .screenObserve: "Observa tamanho da tela e scroll"
        case .accessibility: "Aplica propriedades de acessibilidade"
        case .symbolEffect: "Efeitos animados de símbolo"
        }
    }

    var demoRoute: PlaygroundRoute? {
        switch self {
        case .glow: .glowDemo
        case .skeleton: .skeletonDemo
        case .confetti: .confettiDemo
        case .parallax: .parallaxDemo
        case .background: .backgroundDemo
        case .backgroundSecondary, .backgroundRow, .size, .spacing, .screenObserve, .accessibility, .symbolEffect: nil
        }
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        ModifiersListView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
