//
//  AtomsListView.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismIntelligence
import PrismUI
import SwiftUI
import PrismArchitecture

struct AtomsListView: View {
    @Environment(\.theme) private var theme
    @Bindable private var router = PrismRouter<PlaygroundRoute>()

    private let atoms: [PlaygroundAtom] = [
        .button,
        .text,
        .textField,
        .symbol,
        .asyncImage,
        .shape,
        .spacer,
        .label,
        .list,
        .lazyList,
        .section,
        .hStack,
        .vStack,
        .zStack,
        .tabView,
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.extraLarge) {
                // Grid de cards para cada atom
                atomsGrid

                intelligenceSection
            }
            .padding(.horizontal, theme.spacing.medium)
            .padding(.vertical, theme.spacing.medium)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Atoms")
    }

    // MARK: - Atoms Grid

    private var atomsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: theme.spacing.medium),
                GridItem(.flexible(), spacing: theme.spacing.medium),
            ],
            spacing: theme.spacing.medium
        ) {
            ForEach(atoms, id: \.self) { atom in
                Button {
                    router.push(atom.demoRoute)
                } label: {
                    AtomCardView(atom: atom)
                }
                .buttonStyle(.plain)
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

                Text("Sobre Atoms")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.color.text)

                Spacer()
            }

            Text("Atoms são os componentes fundamentais do Design System. Eles representam elementos UI básicos e atômicos que não podem ser divididos em partes menores sem perder sua funcionalidade.")
                .font(.system(size: 15))
                .foregroundStyle(theme.color.textSecondary)

            HStack {
                Text("15 componentes")
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

// MARK: - Atom Card View

private struct AtomCardView: View {
    @Environment(\.theme) private var theme
    let atom: PlaygroundAtom

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.small) {
            // Ícone
            Image(systemName: atom.icon)
                .font(.system(size: 32))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(atom.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Título
            Text(atom.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.color.text)
                .lineLimit(1)

            // Descrição
            Text(atom.description)
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
    }
}

// MARK: - Playground Atom Model

enum PlaygroundAtom: Hashable, CaseIterable {
    case button
    case text
    case textField
    case symbol
    case asyncImage
    case shape
    case spacer
    case label
    case list
    case lazyList
    case section
    case hStack
    case vStack
    case zStack
    case tabView

    var title: String {
        switch self {
        case .button: "Button"
        case .text: "Text"
        case .textField: "TextField"
        case .symbol: "Symbol"
        case .asyncImage: "AsyncImage"
        case .shape: "Shape"
        case .spacer: "Spacer"
        case .label: "Label"
        case .list: "List"
        case .lazyList: "LazyList"
        case .section: "Section"
        case .hStack: "HStack"
        case .vStack: "VStack"
        case .zStack: "ZStack"
        case .tabView: "TabView"
        }
    }

    var icon: String {
        switch self {
        case .button: "rectangle.fill"
        case .text: "textformat"
        case .textField: "text.justify"
        case .symbol: "star.fill"
        case .asyncImage: "photo.fill"
        case .shape: "circle.fill"
        case .spacer: "arrow.left.and.right"
        case .label: "tag.fill"
        case .list: "list.bullet"
        case .lazyList: "list.number"
        case .section: "section"
        case .hStack: "arrow.right"
        case .vStack: "arrow.down"
        case .zStack: "square.on.square"
        case .tabView: "square.grid.2x2"
        }
    }

    var color: Color {
        switch self {
        case .button: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .text: .init(red: 0.4, green: 0.4, blue: 0.45)
        case .textField: .init(red: 0.1, green: 0.5, blue: 0.8)
        case .symbol: .init(red: 1.0, green: 0.6, blue: 0.0)
        case .asyncImage: .init(red: 0.6, green: 0.3, blue: 0.8)
        case .shape: .init(red: 0.9, green: 0.3, blue: 0.5)
        case .spacer: .init(red: 0.5, green: 0.5, blue: 0.5)
        case .label: .init(red: 0.1, green: 0.7, blue: 0.4)
        case .list: .init(red: 0.2, green: 0.4, blue: 0.9)
        case .lazyList: .init(red: 0.3, green: 0.5, blue: 0.9)
        case .section: .init(red: 0.4, green: 0.6, blue: 0.9)
        case .hStack: .init(red: 0.9, green: 0.5, blue: 0.1)
        case .vStack: .init(red: 0.9, green: 0.3, blue: 0.1)
        case .zStack: .init(red: 0.8, green: 0.2, blue: 0.6)
        case .tabView: .init(red: 0.5, green: 0.3, blue: 0.9)
        }
    }

    var description: String {
        switch self {
        case .button: "Botão estilizado com suporte a acessibilidade"
        case .text: "Componente de texto com estilos tipográficos"
        case .textField: "Campo de entrada com validação e label flutuante"
        case .symbol: "Ícone SF Symbols com modos de renderização"
        case .asyncImage: "Carregamento assíncrono de imagens com cache"
        case .shape: "Formas geométricas para clip e background"
        case .spacer: "Espaçador semântico com tokens de spacing"
        case .label: "Label com ícone e texto combinados"
        case .list: "Lista de rows com seleção opcional"
        case .lazyList: "Lista com lazy loading para performance"
        case .section: "Seção de lista com header e footer"
        case .hStack: "Container horizontal com espaçamento semântico"
        case .vStack: "Container vertical com espaçamento semântico"
        case .zStack: "Container em camadas (z-axis)"
        case .tabView: "View de abas com navegação por tabs"
        }
    }

    var demoRoute: PlaygroundRoute {
        switch self {
        case .button: .buttonDemo
        case .text: .textDemo
        case .textField: .textFieldDemo
        case .symbol: .symbolDemo
        case .asyncImage: .asyncImageDemo
        case .shape: .shapeDemo
        case .spacer: .spacerDemo
        case .label: .labelDemo
        case .list: .listDemo
        case .lazyList: .listDemo
        case .section: .sectionDemo
        case .hStack: .listDemo
        case .vStack: .listDemo
        case .zStack: .listDemo
        case .tabView: .tabViewDemo
        }
    }
}

#Preview {
    PrismNavigationView(router: .init()) { (_: PlaygroundRoute) in
        EmptyView()
    } content: {
        AtomsListView()
    }
    .prism(theme: PrismPlaygroundTheme())
}
