//
//  PrismNLPActions.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

#if canImport(NaturalLanguage)
    import NaturalLanguage

    public enum PrismSentiment: String, Sendable, CaseIterable {
        case positive
        case negative
        case neutral
        case mixed
    }

    public enum PrismEntityType: String, Sendable, CaseIterable {
        case person
        case place
        case organization
        case date
    }

    public struct PrismNLPEntity: Sendable, Equatable {
        public let text: String
        public let type: PrismEntityType
        public let range: Range<String.Index>

        public init(text: String, type: PrismEntityType, range: Range<String.Index>) {
            self.text = text
            self.type = type
            self.range = range
        }
    }

    public struct PrismNLPActions: Sendable {
        public init() {}

        public static func analyzeSentiment(_ text: String) -> PrismSentiment {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = text
            let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
            guard let sentimentValue = sentiment?.rawValue, let score = Double(sentimentValue) else {
                return .neutral
            }
            if score > 0.1 { return .positive }
            if score < -0.1 { return .negative }
            return .neutral
        }

        public static func extractEntities(_ text: String) -> [PrismNLPEntity] {
            let tagger = NLTagger(tagSchemes: [.nameType])
            tagger.string = text
            var entities: [PrismNLPEntity] = []
            let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options)
            { tag, range in
                guard let tag else { return true }
                let entityType: PrismEntityType?
                switch tag {
                case .personalName: entityType = .person
                case .placeName: entityType = .place
                case .organizationName: entityType = .organization
                default: entityType = nil
                }
                if let entityType {
                    entities.append(PrismNLPEntity(text: String(text[range]), type: entityType, range: range))
                }
                return true
            }
            return entities
        }

        public static func detectLanguage(_ text: String) -> String? {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(text)
            return recognizer.dominantLanguage?.rawValue
        }

        public static func tokenize(_ text: String) -> [String] {
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text
            return tokenizer.tokens(for: text.startIndex..<text.endIndex).map { String(text[$0]) }
        }
    }

#endif
