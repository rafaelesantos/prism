#if canImport(AppIntents)
    import AppIntents

    // MARK: - Intent Donation

    public struct PrismIntentDonation: Sendable {
        public let id: UUID
        public let intentType: String
        public let title: String
        public let subtitle: String?
        public let timestamp: Date
        public let metadata: [String: String]

        public init(
            id: UUID = UUID(),
            intentType: String,
            title: String,
            subtitle: String? = nil,
            timestamp: Date = Date(),
            metadata: [String: String] = [:]
        ) {
            self.id = id
            self.intentType = intentType
            self.title = title
            self.subtitle = subtitle
            self.timestamp = timestamp
            self.metadata = metadata
        }
    }

    // MARK: - Shortcut Phrase

    public struct PrismShortcutPhrase: Sendable {
        public let phrase: String
        public let intentType: String

        public init(phrase: String, intentType: String) {
            self.phrase = phrase
            self.intentType = intentType
        }
    }

    // MARK: - Intent Prediction

    public struct PrismIntentPrediction: Sendable {
        public let intentType: String
        public let title: String
        public let parameters: [String: String]

        public init(intentType: String, title: String, parameters: [String: String] = [:]) {
            self.intentType = intentType
            self.title = title
            self.parameters = parameters
        }
    }

    // MARK: - Siri Tip Style

    public enum PrismSiriTipStyle: Sendable, CaseIterable {
        case automatic
        case light
        case dark
    }

    // MARK: - App Intent Client

    @MainActor @Observable
    public final class PrismAppIntentClient {
        public private(set) var predictions: [PrismIntentPrediction] = []

        private var donatedIntentTypes: Set<String> = []

        private var suggestedPhrases: [PrismShortcutPhrase] = []

        public init() {}

        public func donate(intent: PrismIntentDonation) async {
            donatedIntentTypes.insert(intent.intentType)
        }

        public func deleteAllDonations() async {
            donatedIntentTypes.removeAll()
        }

        public func deleteDonations(matching intentType: String) async {
            donatedIntentTypes.remove(intentType)
        }

        public func suggestShortcut(phrase: PrismShortcutPhrase) {
            suggestedPhrases.append(phrase)
        }
    }
#endif
