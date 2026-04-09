//
//  RyzeVideoView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 22/07/25.
//

import AVFoundation
import AVKit
import SwiftUI

public struct RyzeVideoView: View {
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
            RyzeVideoPlayer(player: player)
                .transition(.scale)
        }
    }

    func updatePlayer() {
        guard let url else { return player = nil }
        player = AVPlayer(url: url)
    }
}

#if canImport(AppKit)
    struct RyzeVideoPlayer: NSViewRepresentable {
        let player: AVPlayer

        func updateNSView(
            _ NSView: NSView,
            context: NSViewRepresentableContext<RyzeVideoPlayer>
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
    struct RyzeVideoPlayer: UIViewControllerRepresentable {
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
