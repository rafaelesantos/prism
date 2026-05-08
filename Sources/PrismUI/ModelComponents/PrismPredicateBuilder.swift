#if canImport(SwiftData)
    import PrismStorage
    import SwiftUI

    @MainActor
    public struct PrismFilterBar: View {
        @Environment(\.prismTheme) private var theme

        @State private var selectedField: String
        @State private var selectedOperator: PrismFilterOperator = .equals
        @State private var filterValue: String = ""

        private let availableFields: [String]
        private let onApply: @MainActor ([PrismFilterField]) -> Void

        @State private var activeFilters: [PrismFilterField] = []

        public init(
            fields: [String],
            onApply: @escaping @MainActor ([PrismFilterField]) -> Void
        ) {
            self.availableFields = fields
            self.onApply = onApply
            self._selectedField = State(initialValue: fields.first ?? "")
        }

        public var body: some View {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Picker("Field", selection: $selectedField) {
                        ForEach(availableFields, id: \.self) { field in
                            Text(field).tag(field)
                        }
                    }
                    .labelsHidden()
                    .accessibilityLabel("Filter field")

                    Picker("Operator", selection: $selectedOperator) {
                        ForEach(PrismFilterOperator.allCases, id: \.self) { op in
                            Text(op.rawValue).tag(op)
                        }
                    }
                    .labelsHidden()
                    .accessibilityLabel("Filter operator")

                    TextField("Value", text: $filterValue)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Filter value")

                    Button {
                        addFilter()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add filter")
                }
                .padding(.horizontal)

                if !activeFilters.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Array(activeFilters.enumerated()), id: \.offset) { index, filter in
                                HStack(spacing: 4) {
                                    Text(
                                        "\(filter.name) \(filter.operator.rawValue) \(String(describing: filter.value ?? ""))"
                                    )
                                    .font(.caption)

                                    Button {
                                        removeFilter(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .imageScale(.small)
                                    }
                                    .accessibilityLabel("Remove filter")
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(theme.color(.surfaceSecondary))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }

        private func addFilter() {
            let filter = PrismFilterField(
                name: selectedField,
                operator: selectedOperator,
                value: filterValue
            )
            activeFilters.append(filter)
            filterValue = ""
            onApply(activeFilters)
        }

        private func removeFilter(at index: Int) {
            activeFilters.remove(at: index)
            onApply(activeFilters)
        }
    }
#endif
