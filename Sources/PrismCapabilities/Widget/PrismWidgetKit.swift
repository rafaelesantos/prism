#if canImport(WidgetKit)
    import WidgetKit

    // MARK: - Widget Family

    public enum PrismWidgetFamily: Sendable, CaseIterable {
        case systemSmall
        case systemMedium
        case systemLarge
        case systemExtraLarge
        case accessoryCircular
        case accessoryRectangular
        case accessoryInline
    }

    // MARK: - Widget Entry

    public struct PrismWidgetEntry: Sendable {
        public let date: Date
        public let relevance: Double?
        public let displayName: String?

        public init(date: Date, relevance: Double? = nil, displayName: String? = nil) {
            self.date = date
            self.relevance = relevance
            self.displayName = displayName
        }
    }

    // MARK: - Reload Policy

    public enum PrismWidgetReloadPolicy: Sendable {
        case atEnd
        case afterMinutes(Int)
        case never
    }

    // MARK: - Widget Configuration

    public struct PrismWidgetConfiguration: Sendable {
        public let kind: String
        public let family: PrismWidgetFamily

        public init(kind: String, family: PrismWidgetFamily) {
            self.kind = kind
            self.family = family
        }
    }

    // MARK: - Widget Center

    public struct PrismWidgetCenter: Sendable {

        public init() {}

        public func reloadAllTimelines() {
            WidgetCenter.shared.reloadAllTimelines()
        }

        public func reloadTimeline(kind: String) {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }

        public func getCurrentConfigurations() async -> [PrismWidgetConfiguration] {
            await withCheckedContinuation { continuation in
                WidgetCenter.shared.getCurrentConfigurations { result in
                    switch result {
                    case .success(let infos):
                        let configs = infos.map { info in
                            let family: PrismWidgetFamily =
                                switch info.family {
                                case .systemSmall: .systemSmall
                                case .systemMedium: .systemMedium
                                case .systemLarge: .systemLarge
                                case .systemExtraLarge: .systemExtraLarge
                                case .accessoryCircular: .accessoryCircular
                                case .accessoryRectangular: .accessoryRectangular
                                case .accessoryInline: .accessoryInline
                                @unknown default: .systemSmall
                                }
                            return PrismWidgetConfiguration(kind: info.kind, family: family)
                        }
                        continuation.resume(returning: configs)
                    case .failure:
                        continuation.resume(returning: [])
                    }
                }
            }
        }
    }
#endif
