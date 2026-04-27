//
//  PrismVideoEntity.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import PrismFoundation

/// Entity representing video metadata.
public struct PrismVideoEntity: Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var url: URL
    public var title: String
    public var duration: TimeInterval?
    public var resolution: PrismVideoResolution?
    public var type: AVFileType
    public var thumb: URL?

    public init(
        id: UUID = UUID(),
        url: URL,
        title: String,
        duration: TimeInterval? = nil,
        resolution: PrismVideoResolution? = nil,
        type: AVFileType = .mp4,
        thumb: URL? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.duration = duration
        self.resolution = resolution
        self.type = type
        self.thumb = thumb
    }
}
