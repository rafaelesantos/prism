//
//  RyzeVideoEntity.swift
//  Ryze
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import RyzeFoundation

public struct RyzeVideoEntity {
    public var id: UUID { .init() }
    var url: URL
    var title: String
    var duration: TimeInterval?
    var resolution: RyzeVideoResolution?
    var type: AVFileType
    var thumb: URL?

    public init(
        url: URL,
        title: String,
        duration: TimeInterval? = nil,
        resolution: RyzeVideoResolution? = nil,
        type: AVFileType = .mp4,
        thumb: URL? = nil
    ) {
        self.url = url
        self.title = title
        self.duration = duration
        self.resolution = resolution
        self.type = type
        self.thumb = thumb
    }
}
