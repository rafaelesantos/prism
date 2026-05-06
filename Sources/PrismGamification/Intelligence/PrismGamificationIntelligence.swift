import Foundation
import PrismIntelligence

public actor PrismGamificationIntelligence {
    private let provider: any PrismLanguageIntelligenceProvider
    private let promptBuilder: PrismGamificationPromptBuilder

    public init(
        configuration: PrismAppleIntelligenceConfiguration = .init()
    ) {
        self.provider = PrismAppleIntelligenceProvider(configuration: configuration)
        self.promptBuilder = PrismGamificationPromptBuilder()
    }

    public init(provider: any PrismLanguageIntelligenceProvider) {
        self.provider = provider
        self.promptBuilder = PrismGamificationPromptBuilder()
    }

    public func isAvailable() async -> Bool {
        let status = await provider.status()
        return status.isAvailable
    }

    public func generateMessage(
        kind: PrismGamificationMessageKind,
        context: PrismGamificationContext
    ) async throws -> PrismGamificationMessage {
        let prompt = promptBuilder.prompt(for: kind, context: context)
        let request = PrismLanguageIntelligenceRequest(
            prompt: prompt,
            systemPrompt: promptBuilder.systemInstructions,
            options: PrismLanguageGenerationOptions(
                temperature: 0.7,
                maximumResponseTokens: 100
            )
        )
        let response = try await provider.generate(request)
        return PrismGamificationMessage(
            kind: kind,
            content: response.content,
            entityID: context.entityID
        )
    }

    public func generateMessages(
        _ items: [(kind: PrismGamificationMessageKind, context: PrismGamificationContext)]
    ) async -> [PrismGamificationMessage] {
        var results: [PrismGamificationMessage] = []
        for item in items {
            if let message = try? await generateMessage(kind: item.kind, context: item.context) {
                results.append(message)
            }
        }
        return results
    }

    public func fallbackMessage(
        kind: PrismGamificationMessageKind,
        context: PrismGamificationContext
    ) -> PrismGamificationMessage {
        let content = PrismGamificationFallbacks.message(for: kind, context: context)
        return PrismGamificationMessage(
            kind: kind,
            content: content,
            entityID: context.entityID
        )
    }

    public func messageWithFallback(
        kind: PrismGamificationMessageKind,
        context: PrismGamificationContext
    ) async -> PrismGamificationMessage {
        guard await isAvailable() else {
            return fallbackMessage(kind: kind, context: context)
        }
        do {
            return try await generateMessage(kind: kind, context: context)
        } catch {
            return fallbackMessage(kind: kind, context: context)
        }
    }
}
