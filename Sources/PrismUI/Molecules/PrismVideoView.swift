//
//  PrismVideoView.swift
//  Prism
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import AVKit
import SwiftUI

/// Video playback component for the PrismUI Design System.
///
/// `PrismVideoView` is an `AVPlayer` wrapper with:
/// - Asynchronous video URL loading
/// - Picture in Picture (PiP) support
/// - Native platform controls
/// - Scale transition on appearance
/// - Multi-platform support (iOS, tvOS, macOS)
///
/// ## Basic Usage
/// ```swift
/// @State var videoURL: URL?
/// PrismVideoView(url: $videoURL)
/// ```
///
/// ## With Playback Trigger
/// ```swift
/// PrismVStack {
///     PrismPrimaryButton("Watch") {
///         videoURL = URL(string: "https://example.com/video.mp4")
///     }
///     PrismVideoView(url: $videoURL)
/// }
/// ```
///
/// ## Picture in Picture
/// - **iOS/tvOS**: Automatic support via `canStartPictureInPictureAutomaticallyFromInline`
/// - **macOS**: Support via `allowsPictureInPicturePlayback`
///
/// ## Platform Behavior
/// - **iOS/tvOS**: `AVPlayerViewController` with touch controls
/// - **macOS**: `AVPlayerView` with desktop controls
///
/// - Note: The player is automatically created when `url` is set.
public struct PrismVideoView: View {
    @State private var player: AVPlayer?
    @Binding private var url: URL?

    public init(url: Binding<URL?>) {
        self._url = url
    }

    public var body: some View {
        playerView
            .onChange(of: url) { updatePlayer() }
    }

    @ViewBuilder
    var playerView: some View {
        if let player {
            PrismVideoPlayer(player: player)
                .transition(.scale)
        }
    }

    func updatePlayer() {
        guard let url else { return player = nil }
        player = AVPlayer(url: url)
    }
}

#if canImport(AppKit)
    struct PrismVideoPlayer: NSViewRepresentable {
        let player: AVPlayer

        func updateNSView(
            _ NSView: NSView,
            context: NSViewRepresentableContext<PrismVideoPlayer>
        ) {
            guard let view = NSView as? AVPlayerView else { return }
            view.player = player
            view.allowsPictureInPicturePlayback = true
        }

        func makeNSView(context: Context) -> NSView {
            return AVPlayerView(frame: .zero)
        }
    }

#elseif canImport(UIKit)
    struct PrismVideoPlayer: UIViewControllerRepresentable {
        let player: AVPlayer

        func makeUIViewController(context: Context) -> AVPlayerViewController {
            let vc = AVPlayerViewController()
            vc.player = player
            #if os(tvOS)
            #else
                vc.canStartPictureInPictureAutomaticallyFromInline = true
            #endif
            return vc
        }

        func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
            uiViewController.player = player
        }
    }

#endif
