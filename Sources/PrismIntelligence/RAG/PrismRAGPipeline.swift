//
//  PrismRAGPipeline.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public struct PrismRAGConfig: Sendable {
    public let chunkSize: Int
    public let overlapSize: Int
    public let topK: Int

    public init(chunkSize: Int = 500, overlapSize: Int = 50, topK: Int = 3) {
        self.chunkSize = chunkSize
        self.overlapSize = overlapSize
        self.topK = topK
    }
}

public struct PrismTextChunker: Sendable {
    public init() {}

    public func chunk(_ text: String, size: Int, overlap: Int) -> [String] {
        guard !text.isEmpty, size > 0 else { return [] }
        let effectiveOverlap = min(max(overlap, 0), size - 1)
        let characters = Array(text)
        var chunks: [String] = []
        var start = 0
        while start < characters.count {
            let end = min(start + size, characters.count)
            chunks.append(String(characters[start..<end]))
            let step = size - effectiveOverlap
            start += max(step, 1)
            if end == characters.count { break }
        }
        return chunks
    }
}

public struct PrismRAGResponse: Sendable {
    public let answer: String
    public let sources: [String]
    public let confidence: Double

    public init(answer: String, sources: [String], confidence: Double) {
        self.answer = answer
        self.sources = sources
        self.confidence = confidence
    }
}

public protocol PrismEmbeddingProvider: Sendable {
    func embed(_ text: String) async throws -> [Float]
}

public protocol PrismGenerationProvider: Sendable {
    func generate(question: String, context: [String]) async throws -> String
}

public actor PrismRAGPipeline {
    private let config: PrismRAGConfig
    private let store: PrismEmbeddingStore
    private let chunker: PrismTextChunker
    private let embeddingProvider: PrismEmbeddingProvider
    private let generationProvider: PrismGenerationProvider
    private var chunkTexts: [String: String] = [:]

    public init(
        config: PrismRAGConfig = PrismRAGConfig(),
        store: PrismEmbeddingStore = PrismEmbeddingStore(),
        embeddingProvider: PrismEmbeddingProvider,
        generationProvider: PrismGenerationProvider
    ) {
        self.config = config
        self.store = store
        self.chunker = PrismTextChunker()
        self.embeddingProvider = embeddingProvider
        self.generationProvider = generationProvider
    }

    public func ingest(documents: [String]) async throws {
        for document in documents {
            let chunks = chunker.chunk(document, size: config.chunkSize, overlap: config.overlapSize)
            for chunk in chunks {
                let vector = try await embeddingProvider.embed(chunk)
                let id = UUID().uuidString
                chunkTexts[id] = chunk
                let embedding = PrismEmbedding(
                    id: id,
                    vector: vector,
                    metadata: ["source": String(chunk.prefix(100))]
                )
                await store.add(embedding)
            }
        }
    }

    public func query(_ question: String) async throws -> PrismRAGResponse {
        let queryVector = try await embeddingProvider.embed(question)
        let results = await store.search(query: queryVector, topK: config.topK)
        let sources = results.compactMap { chunkTexts[$0.embedding.id] }
        let answer = try await generationProvider.generate(question: question, context: sources)
        let avgSimilarity =
            results.isEmpty
            ? 0.0
            : Double(results.map(\.similarity).reduce(0, +)) / Double(results.count)
        return PrismRAGResponse(
            answer: answer,
            sources: sources,
            confidence: avgSimilarity
        )
    }
}
