#if canImport(SwiftData)
    import SwiftData

    public enum PrismFilterOperator: String, CaseIterable, Sendable {
        case equals
        case contains
        case greaterThan
        case lessThan
        case between
        case isNil
        case isNotNil
    }

    public struct PrismFilterField: Sendable {
        public let name: String
        public let `operator`: PrismFilterOperator
        public let value: (any Sendable)?

        public init(name: String, operator op: PrismFilterOperator, value: (any Sendable)? = nil) {
            self.name = name
            self.operator = op
            self.value = value
        }
    }

    public struct PrismPredicateBuilder: Sendable {
        private var filters: [PrismFilterField]

        public init() {
            self.filters = []
        }

        public func `where`(_ field: String, _ op: PrismFilterOperator, _ value: some Sendable) -> PrismPredicateBuilder
        {
            var copy = self
            copy.filters.append(PrismFilterField(name: field, operator: op, value: value))
            return copy
        }

        public func and(_ field: String, _ op: PrismFilterOperator, _ value: some Sendable) -> PrismPredicateBuilder {
            var copy = self
            copy.filters.append(PrismFilterField(name: field, operator: op, value: value))
            return copy
        }

        public func or(_ field: String, _ op: PrismFilterOperator, _ value: some Sendable) -> PrismPredicateBuilder {
            var copy = self
            copy.filters.append(PrismFilterField(name: field, operator: op, value: value))
            return copy
        }

        public func build() -> [PrismFilterField] {
            filters
        }
    }
#endif
