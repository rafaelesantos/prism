//
//  PrismPlaygroundHome.swift
//  PrismPlayground
//
//  Created by Rafael Escaleira on 11/04/26.
//

import PrismFoundation
import PrismIntelligence
import PrismArchitecture
import PrismUI
import SwiftUI

private struct HomeSearchConfiguration: PrismTextFieldConfiguration {
    var placeholder: PrismResourceString { CustomString("Buscar componentes...") }
    var mask: PrismTextFieldMask? { nil }
    var icon: String? { "magnifyingglass" }
    var contentType: PrismTextFieldContentType { .default }
    var autocapitalizationType: PrismTextInputAutocapitalization { .never }
    var submitLabel: SubmitLabel { .done }

    func validate(text: String) throws {}
}

private struct CustomString: PrismResourceString {
    let value: String
    var localized: LocalizedStringKey { LocalizedStringKey(value) }

    init(_ value: String) {
        self.value = value
    }
}

struct PrismPlaygroundHome: View {
    @Environment(\.theme) private var theme
    @State private var searchText = ""
    @Bindable private var router = PrismRouter<PlaygroundRoute>()

    private let categories: [PlaygroundCategory] = [
        .atoms,
        .molecules,
        .modifiers,
        .patterns,
    ]

    var body: some View {
        PrismNavigationView(
            router: router,
            destination: { (route: PlaygroundRoute) in
                route.destinationView()
            },
            content: {
                homeContent
            }
        )
    }

    private var homeContent: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.extraLarge) {
                headerSection

                searchSection

                categoriesSection

                quickDemosSection

                intelligenceSection
            }
            .padding(.horizontal, theme.spacing.medium)
            .padding(.vertical, theme.spacing.medium)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Spectra")
    }

    // MARK: - Navigation

    private func navigateToCategory(_ category: PlaygroundCategory) {
        let route: PlaygroundRoute
        switch category {
        case .atoms:
            route = .atomsList
        case .molecules:
            route = .moleculesList
        case .modifiers:
            route = .modifiersList
        case .patterns:
            route = .patternsList
        }
        router.push(route)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.medium) {
            HStack(spacing: theme.spacing.small) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(theme.color.primary)

                Text("Spectra")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(theme.color.primary)
            }

            Text("Explore todos os componentes do PrismUI com exemplos interativos e documentação inteligente.")
                .font(.system(size: 15))
                .foregroundStyle(theme.color.textSecondary)
                .lineLimit(nil)
        }
        .padding(theme.spacing.medium)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Search

    private var searchSection: some View {
        HStack(spacing: theme.spacing.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundStyle(theme.color.textSecondary)

            TextField("Buscar componentes...", text: $searchText)
                .font(.system(size: 17))
                .foregroundStyle(theme.color.text)
        }
        .padding(theme.spacing.medium)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Categories

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.medium) {
            Text("Categorias")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(theme.color.text)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: theme.spacing.medium),
                    GridItem(.flexible(), spacing: theme.spacing.medium),
                ],
                spacing: theme.spacing.medium
            ) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        navigateToCategory(category)
                    } label: {
                        CategoryCardView(category: category)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Quick Demos

    private var quickDemosSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.medium) {
            Text("Demos Rápidas")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(theme.color.text)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.medium) {
                    QuickDemoButton(
                        title: "Buttons",
                        icon: "rectangle.fill.on.rectangle.angled.fill",
                        color: theme.color.primary
                    ) {
                        router.push(.buttonDemo)
                    }

                    QuickDemoButton(
                        title: "Text Fields",
                        icon: "textformat",
                        color: theme.color.secondary
                    ) {
                        router.push(.textFieldDemo)
                    }

                    QuickDemoButton(
                        title: "Effects",
                        icon: "sparkles",
                        color: theme.color.warning
                    ) {
                        router.push(.glowDemo)
                    }

                    QuickDemoButton(
                        title: "Skeleton",
                        icon: "rectangle.dashed",
                        color: theme.color.info
                    ) {
                        router.push(.skeletonDemo)
                    }

                    QuickDemoButton(
                        title: "Carousel",
                        icon: "arrow.left.and.right",
                        color: theme.color.secondary
                    ) {
                        router.push(.carouselDemo)
                    }
                }
                .padding(.horizontal, theme.spacing.small)
            }
            .padding(.horizontal, -theme.spacing.small)
        }
    }

    // MARK: - Intelligence

    private var intelligenceSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.medium) {
            HStack {
                Image(systemName: "brain.headset")
                    .font(.system(size: 22))
                    .foregroundStyle(theme.color.primary)

                Text("Prism Intelligence")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.color.text)

                Spacer()
            }

            Text("Obtenha explicações inteligentes sobre cada componente, incluindo melhores práticas, padrões de uso e exemplos de código.")
                .font(.system(size: 15))
                .foregroundStyle(theme.color.textSecondary)

            Button {
                // Navegar para tela de intelligence quando implementada
            } label: {
                Text("Explorar Intelligence")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(theme.spacing.medium)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Category Card View

private struct CategoryCardView: View {
    @Environment(\.theme) private var theme
    let category: PlaygroundCategory

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.small) {
            Image(systemName: category.icon)
                .font(.system(size: 32))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(category.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text(category.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.color.text)
                .lineLimit(1)

            Text("\(category.componentCount) componentes")
                .font(.system(size: 13))
                .foregroundStyle(theme.color.textSecondary)
        }
        .padding(theme.spacing.medium)
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Quick Demo Button

private struct QuickDemoButton: View {
    @Environment(\.theme) private var theme
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    init(title: String, icon: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: theme.spacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)

                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(theme.color.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 90, height: 90)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PrismPlaygroundHome()
        .prism(theme: PrismPlaygroundTheme())
}
