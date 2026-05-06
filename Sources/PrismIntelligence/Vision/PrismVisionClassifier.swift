//
//  PrismVisionClassifier.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation

#if canImport(Vision) && canImport(CoreGraphics)
    import CoreGraphics
    import Vision

    public struct PrismClassificationResult: Sendable, Equatable {
        public let label: String
        public let confidence: Double

        public init(label: String, confidence: Double) {
            self.label = label
            self.confidence = confidence
        }
    }

    public struct PrismVisionClassifier: Sendable {
        public init() {}

        public func classify(image: CGImage, maxResults: Int = 5) async throws -> [PrismClassificationResult] {
            try await withCheckedThrowingContinuation { continuation in
                let request = VNClassifyImageRequest { request, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    let observations = (request.results as? [VNClassificationObservation]) ?? []
                    let results =
                        observations
                        .sorted { $0.confidence > $1.confidence }
                        .prefix(maxResults)
                        .map { PrismClassificationResult(label: $0.identifier, confidence: Double($0.confidence)) }
                    continuation.resume(returning: Array(results))
                }

                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        public func classify(imageData: Data, maxResults: Int = 5) async throws -> [PrismClassificationResult] {
            try await withCheckedThrowingContinuation { continuation in
                let request = VNClassifyImageRequest { request, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    let observations = (request.results as? [VNClassificationObservation]) ?? []
                    let results =
                        observations
                        .sorted { $0.confidence > $1.confidence }
                        .prefix(maxResults)
                        .map { PrismClassificationResult(label: $0.identifier, confidence: Double($0.confidence)) }
                    continuation.resume(returning: Array(results))
                }

                let handler = VNImageRequestHandler(data: imageData, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

#endif
