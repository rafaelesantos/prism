//
//  PrismEmbeddingStore.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

public struct PrismEmbedding: Sendable, Equatable, Identifiable {
    public let id: String
    public let vector: [Float]
    public let metadata: [String: String]

    public init(id: String, vector: [Float], metadata: [String: String] = [:]) {
        self.id = id
        self.vector = vector
        self.metadata = metadata
    }
}

public struct PrismSearchResult: Sendable {
    public let embedding: PrismEmbedding
    public let similarity: Float
}

public actor PrismEmbeddingStore {
    private var embeddings: [PrismEmbedding] = []

    public var count: Int { embeddings.count }

    public init() {}

    public func add(_ embedding: PrismEmbedding) {
        embeddings.append(embedding)
    }

    public func search(query: [Float], topK: Int) -> [PrismSearchResult] {
        embeddings
            .map { embedding in
                PrismSearchResult(
                    embedding: embedding,
                    similarity: Self.cosineSimilarity(query, embedding.vector)
                )
            }
            .sorted { $0.similarity > $1.similarity }
            .prefix(topK)
            .map { $0 }
    }

    public func clear() {
        embeddings.removeAll()
    }

    public static func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var dot: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        for i in 0..<a.count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        let denominator = sqrt(normA) * sqrt(normB)
        guard denominator > 0 else { return 0 }
        return dot / denominator
    }
}
