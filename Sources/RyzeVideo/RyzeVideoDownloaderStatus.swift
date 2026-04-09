//
//  RyzeVideoDownloaderStatus.swift
//  Ryze
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import RyzeFoundation

public enum RyzeVideoDownloaderStatus: @unchecked Sendable {
    case downloading(
        progress: Double,
        session: AVAssetExportSession
    )
    case completed(path: URL)
    case error(RyzeVideoError)
}
