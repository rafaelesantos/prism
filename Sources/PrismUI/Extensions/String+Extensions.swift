//
//  String+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 25/04/25.
//

import PrismFoundation
import SwiftUI

extension String {
    /// A localized placeholder title string for use in Xcode previews.
    public static var prismPreviewTitle: String {
        PrismUIString.prismPreviewTitle.value
    }

    /// A localized placeholder description string for use in Xcode previews.
    public static var prismPreviewDescription: String {
        PrismUIString.prismPreviewDescription.value
    }

    /// Builds a descriptive preview display name combining the view type, color scheme, and locale.
    ///
    /// - Parameters:
    ///   - type: The view type to include in the display name.
    ///   - scheme: The color scheme being previewed.
    ///   - locale: The locale being previewed.
    /// - Returns: A formatted string such as `"MyView * Light * en_US"`.
    public static func prismPreviewDisplayName<T>(
        _ type: T.Type,
        scheme: ColorScheme,
        locale: PrismLocale
    ) -> String {
        let className = String(describing: type)
        let schemeName = scheme == .light ? "☀️ Light" : "🌒 Dark"
        let localeName = locale.description
        return "\(className) • \(schemeName) • \(localeName)"
    }

    /// Returns the string formatted using a `printf`-style format string.
    ///
    /// - Parameter format: A format string containing a `%@` placeholder.
    /// - Returns: The formatted result.
    public func formatted(with format: String) -> String {
        String(format: format, self)
    }
}
