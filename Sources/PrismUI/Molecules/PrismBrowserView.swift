//
//  PrismBrowserView.swift
//  Prism
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

/// Web navigation view for the PrismUI Design System.
///
/// `PrismBrowserView` is a component for displaying web content via:
/// - Modal sheet with `SFSafariViewController` (iOS)
/// - Native browser (macOS)
/// - Optional URL binding for presentation control
///
/// ## Basic Usage
/// ```swift
/// @State var url: URL?
/// PrismBrowserView(url: $url) {
///     PrismPrimaryButton("Open website") {
///         url = URL(string: "https://example.com")
///     }
/// }
/// ```
///
/// ## With Custom Content
/// ```swift
/// PrismBrowserView(url: $url) {
///     VStack {
///         PrismText("Tap to open")
///         PrismPrimaryButton("Visit") {
///             url = URL(string: "https://example.com")
///         }
///     }
/// }
/// ```
///
/// ## Platform Behavior
/// - **iOS**: Opens in `SFSafariViewController` within a sheet
/// - **macOS**: Opens in the system default browser
///
/// - Note: The sheet automatically dismisses when `url` is set to `nil`.
public struct PrismBrowserView<Content: View>: View {
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
                    PrismBrowser(url: url)
                }
            }
    }
}

#if canImport(UIKit) && canImport(SafariServices)
    struct PrismBrowser: UIViewControllerRepresentable {
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
    struct PrismBrowser: NSViewRepresentable {
        let url: URL

        func updateNSView(
            _ nsView: NSView,
            context: NSViewRepresentableContext<PrismBrowser>
        ) {
            _ = nsView
            NSWorkspace.shared.open(url)
        }

        func makeNSView(context: Context) -> NSView {
            return .init()
        }
    }

#else
    struct PrismBrowser: View {
        let url: URL

        var body: some View {
            EmptyView()
        }
    }

#endif
