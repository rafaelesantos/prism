//
//  RyzeBrowserView.swift
//  Ryze
//
//  Created by Rafael Escaleira on 22/07/25.
//

import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif
#if canImport(SafariServices)
    import SafariServices
#endif

public struct RyzeBrowserView<Content: View>: View {
    @Binding private var url: URL?
    let content: Content
    private var isPresented: Binding<Bool> {
        Binding(
            get: { url != nil },
            set: { isPresented in
                if !isPresented {
                    url = nil
                }
            }
        )
    }

    public init(
        url: Binding<URL?>,
        @ViewBuilder content: () -> Content
    ) {
        self._url = url
        self.content = content()
    }

    public var body: some View {
        content
            .sheet(isPresented: isPresented) {
                if let url {
                    RyzeBrowser(url: url)
                }
            }
    }
}

#if canImport(UIKit) && canImport(SafariServices)
    struct RyzeBrowser: UIViewControllerRepresentable {
        let url: URL

        func makeUIViewController(context: Context) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }

        func updateUIViewController(
            _ uiViewController: SFSafariViewController,
            context: Context
        ) {
            return
        }
    }

#elseif canImport(AppKit)
    struct RyzeBrowser: NSViewRepresentable {
        let url: URL

        func updateNSView(
            _ nsView: NSView,
            context: NSViewRepresentableContext<RyzeBrowser>
        ) {
            _ = nsView
            NSWorkspace.shared.open(url)
        }

        func makeNSView(context: Context) -> NSView {
            return .init()
        }
    }

#else
    struct RyzeBrowser: View {
        let url: URL

        var body: some View {
            EmptyView()
        }
    }

#endif
