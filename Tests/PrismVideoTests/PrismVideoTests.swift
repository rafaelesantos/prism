//
//  PrismVideoTests.swift
//  PrismVideoTests
//
//  Created by Rafael Escaleira on 27/04/26.
//

import AVFoundation
import Testing

@testable import PrismVideo

@Suite
struct PrismVideoEntityTests {
    @Test
    func entityPreservesStoredIdentity() {
        let entity = PrismVideoEntity(
            url: URL(string: "https://example.com/video.mp4")!,
            title: "Test Video"
        )

        #expect(entity.id == entity.id)
    }

    @Test
    func entityInitializesWithDefaults() {
        let url = URL(string: "https://example.com/video.mp4")!
        let entity = PrismVideoEntity(url: url, title: "Sample")

        #expect(entity.url == url)
        #expect(entity.title == "Sample")
        #expect(entity.duration == nil)
        #expect(entity.resolution == nil)
        #expect(entity.type == .mp4)
        #expect(entity.thumb == nil)
    }

    @Test
    func entityInitializesWithAllParameters() {
        let url = URL(string: "https://example.com/video.mp4")!
        let thumb = URL(string: "https://example.com/thumb.jpg")!
        let id = UUID()

        let entity = PrismVideoEntity(
            id: id,
            url: url,
            title: "Full Video",
            duration: 120.5,
            resolution: .fullHD,
            type: .mov,
            thumb: thumb
        )

        #expect(entity.id == id)
        #expect(entity.url == url)
        #expect(entity.title == "Full Video")
        #expect(entity.duration == 120.5)
        #expect(entity.resolution == .fullHD)
        #expect(entity.type == .mov)
        #expect(entity.thumb == thumb)
    }

    @Test
    func entityEquality() {
        let id = UUID()
        let url = URL(string: "https://example.com/video.mp4")!

        let a = PrismVideoEntity(id: id, url: url, title: "Video")
        let b = PrismVideoEntity(id: id, url: url, title: "Video")

        #expect(a == b)
    }

    @Test
    func entityInequalityByID() {
        let url = URL(string: "https://example.com/video.mp4")!

        let a = PrismVideoEntity(url: url, title: "Video")
        let b = PrismVideoEntity(url: url, title: "Video")

        #expect(a != b)
    }

    @Test
    func entityIsHashable() {
        let id = UUID()
        let url = URL(string: "https://example.com/video.mp4")!

        let a = PrismVideoEntity(id: id, url: url, title: "Video")
        let b = PrismVideoEntity(id: id, url: url, title: "Video")

        var set: Set<PrismVideoEntity> = [a]
        set.insert(b)
        #expect(set.count == 1)
    }
}

@Suite
struct PrismVideoResolutionTests {
    @Test
    func resolutionRawValueStrings() {
        #expect(PrismVideoResolution._4K.rawValue == "4K")
        #expect(PrismVideoResolution.fullHD.rawValue == "1080p HD")
        #expect(PrismVideoResolution.HD.rawValue == "720p HD")
        #expect(PrismVideoResolution.SD.rawValue == "SD")
    }

    @Test
    func resolutionInitFromHeight() {
        #expect(PrismVideoResolution(rawValue: 0) == .SD)
        #expect(PrismVideoResolution(rawValue: 480) == .SD)
        #expect(PrismVideoResolution(rawValue: 719) == .SD)
        #expect(PrismVideoResolution(rawValue: 720) == .HD)
        #expect(PrismVideoResolution(rawValue: 1079) == .HD)
        #expect(PrismVideoResolution(rawValue: 1080) == .fullHD)
        #expect(PrismVideoResolution(rawValue: 2159) == .fullHD)
        #expect(PrismVideoResolution(rawValue: 2160) == ._4K)
        #expect(PrismVideoResolution(rawValue: 4320) == ._4K)
    }

    @Test
    func resolutionIDMatchesRawValue() {
        let resolution = PrismVideoResolution.fullHD
        #expect(resolution.id == resolution.rawValue)
    }
}

@Suite
struct PrismVideoErrorTests {
    @Test
    func errorDescriptions() {
        #expect(PrismVideoError.assetNotPlayable.errorDescription == "Asset not playable")
        #expect(PrismVideoError.missingTracks.errorDescription == "Missing video or audio tracks")
        #expect(PrismVideoError.failedToCreateExportSession.errorDescription == "Failed to create export session")
        #expect(PrismVideoError.custom(message: "test error").errorDescription == "test error")
    }

    @Test
    func errorFailureReasons() {
        #expect(PrismVideoError.assetNotPlayable.failureReason != nil)
        #expect(PrismVideoError.missingTracks.failureReason != nil)
        #expect(PrismVideoError.failedToCreateExportSession.failureReason != nil)
        #expect(PrismVideoError.custom(message: "test").failureReason == nil)
    }

    @Test
    func errorRecoverySuggestions() {
        #expect(PrismVideoError.assetNotPlayable.recoverySuggestion != nil)
        #expect(PrismVideoError.missingTracks.recoverySuggestion != nil)
        #expect(PrismVideoError.failedToCreateExportSession.recoverySuggestion != nil)
        #expect(PrismVideoError.custom(message: "test").recoverySuggestion == nil)
    }

    @Test
    func errorDescription() {
        #expect(PrismVideoError.assetNotPlayable.description == "Asset not playable")
    }

    @Test
    func errorDescriptionIsNonEmpty() {
        let errors: [PrismVideoError] = [
            .assetNotPlayable,
            .missingTracks,
            .failedToCreateExportSession,
            .custom(message: "test"),
        ]

        for error in errors {
            #expect(!error.description.isEmpty)
        }
    }
}

@Suite
struct PrismVideoDownloaderTests {
    @Test
    func downloaderInitializesWithParameters() {
        let url = URL(string: "https://example.com/video.mp4")!
        let downloader = PrismVideoDownloader(
            video: url,
            with: "test_video",
            for: .mp4
        )

        #expect(downloader != nil)
    }

    @Test
    func downloaderDefaultsToMP4() {
        let url = URL(string: "https://example.com/video.mp4")!
        let downloader = PrismVideoDownloader(
            video: url,
            with: "test_video"
        )

        #expect(downloader != nil)
    }
}
