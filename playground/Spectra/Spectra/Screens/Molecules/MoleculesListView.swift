//
//  MoleculesListView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismUI
import PrismArchitecture
import SwiftUI

struct MoleculesListView: View {
    @Environment(\.theme) private var theme
    @Bindable private var router = PrismRouter<PlaygroundRoute>()

    private let molecules: [PlaygroundMolecule] = [
        .tag,
        .carousel,
        .primaryButton,
        .secondaryButton,
        .bodyText,
        .footnoteText,
        .currencyTextField,
        .navigationView,
        .browserView,
        .videoView,
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.extraLarge) {
                moleculesGrid

                intelligenceSection
            }
            .padding(.horizontal, theme.spacing.medium)
            .padding(.vertical, theme.spacing.medium)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Molecules")
    }

    // MARK: - Molecules Grid

    private var moleculesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: theme.spacing.medium),
                GridItem(.flexible(), spacing: theme.spacing.medium),
            ],
            spacing: theme.spacing.medium
        ) {
            ForEach(molecules, id: \.self) { molecule in
                Button {
                    if let route = molecule.demoRoute {
                        router.push(route)
                    }
                } label: {
                    MoleculeCardView(molecule: molecule)
                }
                .buttonStyle(.plain)
                .disabled(molecule.demoRoute == nil)
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

                Text("Sobre Molecules")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.color.text)

                Spacer()
            }

            Text("Molecules são componentes compostos que combinam Atoms para criar funcionalidades mais complexas e específicas. Eles representam padrões de UI reutilizáveis.")
                .font(.system(size: 15))
                .foregroundStyle(theme.color.textSecondary)

            HStack {
                Text("10 componentes")
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

// MARK: - Molecule Card View

private struct MoleculeCardView: View {
    @Environment(\.theme) private var theme
    let molecule: PlaygroundMolecule

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.small) {
            Image(systemName: molecule.icon)
                .font(.system(size: 32))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(molecule.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text(molecule.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.color.text)
                .lineLimit(1)

            Text(molecule.description)
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
        .opacity(molecule.demoRoute == nil ? 0.6 : 1.0)
        .overlay(
            Group {
                if molecule.demoRoute == nil {
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

// MARK: - Playground Molecule Model

enum PlaygroundMolecule: Hashable, CaseIterable {
    case tag
    case carousel
    case primaryButton
    case secondaryButton
    case bodyText
    case footnoteText
    case currencyTextField
    case navigationView
    case browserView
    case videoView

    var title: String {
        switch self {
        case .tag: "Tag"
        case .carousel: "Carousel"
        case .primaryButton: "PrimaryButton"
        case .secondaryButton: "SecondaryButton"
        case .bodyText: "BodyText"
        case .footnoteText: "FootnoteText"
        case .currencyTextField: "CurrencyTextField"
        case .navigationView: "NavigationView"
        case .browserView: "BrowserView"
        case .videoView: "VideoView"
        }
    }

    var icon: String {
        switch self {
        case .tag: "tag.fill"
        case .carousel: "arrow.left.and.right"
        case .primaryButton: "button.fill"
        case .secondaryButton: "button.programmable"
        case .bodyText: "doc.text"
        case .footnoteText: "doc.text.fill"
        case .currencyTextField: "dollarsign.circle.fill"
        case .navigationView: "arrow.2.squarepath"
        case .browserView: "globe"
        case .videoView: "video.fill"
        }
    }

    var color: Color {
        switch self {
        case .tag: .init(red: 0.6, green: 0.3, blue: 0.8)
        case .carousel: .init(red: 0.9, green: 0.3, blue: 0.5)
        case .primaryButton: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .secondaryButton: .init(red: 0.4, green: 0.4, blue: 0.45)
        case .bodyText: .init(red: 0.3, green: 0.3, blue: 0.35)
        case .footnoteText: .init(red: 0.5, green: 0.5, blue: 0.55)
        case .currencyTextField: .init(red: 0.1, green: 0.6, blue: 0.3)
        case .navigationView: .init(red: 0.2, green: 0.5, blue: 0.9)
        case .browserView: .init(red: 0.0, green: 0.4, blue: 0.8)
        case .videoView: .init(red: 0.8, green: 0.2, blue: 0.4)
        }
    }

    var description: String {
        switch self {
        case .tag: "Tag/badge para labels categorizados"
        case .carousel: "Carrossel horizontal com scroll automático"
        case .primaryButton: "Botão primário para ações principais"
        case .secondaryButton: "Botão secundário para ações secundárias"
        case .bodyText: "Texto de corpo pré-estilizado"
        case .footnoteText: "Texto de nota de rodapé pré-estilizado"
        case .currencyTextField: "Campo de entrada para valores monetários"
        case .navigationView: "Container de navegação com rotas tipadas"
        case .browserView: "Navegador web em sheet modal"
        case .videoView: "Player de vídeo com Picture in Picture"
        }
    }

    var demoRoute: PlaygroundRoute? {
        switch self {
        case .tag: .tagDemo
        case .carousel: .carouselDemo
        case .primaryButton: .primaryButtonDemo
        case .secondaryButton: .secondaryButtonDemo
        case .bodyText: .bodyTextDemo
        case .footnoteText: .footnoteTextDemo
        case .currencyTextField: .currencyTextFieldDemo
        case .navigationView, .browserView, .videoView: nil
        }
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        MoleculesListView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
