import SwiftUI

public struct PrismLocalizedKey: Sendable, Identifiable {
    public var id: String { key }
    public let key: String
    public let comment: String
    public let table: String?

    public init(key: String, comment: String, table: String? = nil) {
        self.key = key
        self.comment = comment
        self.table = table
    }

    public var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(key)
    }
}

@MainActor
public final class PrismStringExporter: Sendable {
    public private(set) var keys: [PrismLocalizedKey] = []

    public static let shared = PrismStringExporter()

    public init() {}

    public func register(_ key: PrismLocalizedKey) {
        guard !keys.contains(where: { $0.key == key.key }) else { return }
        keys.append(key)
    }

    public func exportKeys(from module: String) -> [PrismLocalizedKey] {
        keys.filter { $0.key.hasPrefix(module) || module.isEmpty }
    }

    public func reset() {
        keys.removeAll()
    }
}

// MARK: - View Modifier

extension View {

    public func prismLocalized(_ key: String, comment: String, table: String? = nil) -> some View {
        modifier(PrismLocalizedModifier(key: key, comment: comment, table: table))
    }
}

@MainActor
private struct PrismLocalizedModifier: ViewModifier {
    let key: String
    let comment: String
    let table: String?

    func body(content: Content) -> some View {
        content
            .onAppear {
                let localizedKey = PrismLocalizedKey(key: key, comment: comment, table: table)
                PrismStringExporter.shared.register(localizedKey)
            }
    }
}
