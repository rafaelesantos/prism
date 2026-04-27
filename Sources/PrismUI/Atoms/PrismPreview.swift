//
//  PrismPreview.swift
//  Prism
//
//  Created by Rafael Escaleira on 06/06/25.
//

import PrismFoundation
import SwiftUI

/// Comprehensive preview for the PrismUI Design System.
///
/// `PrismPreview` automatically generates previews for all scenarios:
/// - Light mode and Dark mode
/// - Portuguese (BR) and English (US)
/// - Portrait and Landscape
/// - Size That Fits and Device layout
///
/// ## Basic Usage
/// ```swift
/// #Preview {
///     PrismPreview(content: PrismButton.self)
/// }
/// ```
///
/// ## What Is Generated
/// The preview generates a complete matrix of combinations:
/// - 2 color schemes x 2 locales x 2 orientations x 2 layouts = **16 previews**
///
/// ## For Custom Components
/// ```swift
/// struct MyComponent: PrismView {
///     // ...
///     static func mocked() -> some View {
///         MyComponent(...)
///     }
/// }
///
/// #Preview {
///     PrismPreview(content: MyComponent.self)
/// }
/// ```
///
/// - Note: Requires the component to implement `static func mocked()`.
/// - Important: Use to validate components across all scenarios before committing.
public struct PrismPreview<Content: PrismView>: View {
    let colorSchemes: [ColorScheme] = [.light, .dark]
    let locales: [PrismLocale] = [.portugueseBR, .englishUS]
    let orientations: [InterfaceOrientation] = [.portrait, .landscapeRight]
    let layouts: [PreviewLayout] = [.sizeThatFits, .device]
    let content: Content.Type

    public init(content: Content.Type) {
        self.content = content
    }

    public var body: some View {
        Group {
            ForEach(locales.indices, id: \.self) {
                let locale = locales[$0]
                ForEach(orientations.indices, id: \.self) {
                    let orientation = orientations[$0]
                    ForEach(layouts.indices, id: \.self) {
                        let layout = layouts[$0]
                        ForEach(colorSchemes.indices, id: \.self) {
                            let colorScheme = colorSchemes[$0]
                            content.mocked()
                                .prismPreview(
                                    layout: layout,
                                    orientation: orientation,
                                    colorScheme: colorScheme,
                                    locale: locale
                                )
                        }
                    }
                }
            }
        }
    }
}
