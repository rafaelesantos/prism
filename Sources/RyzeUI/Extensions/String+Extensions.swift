//
//  String+Extensions.swift
//  Ryze
//
//  Created by Rafael Escaleira on 25/04/25.
//

import RyzeFoundation
import SwiftUI

extension String {
    public static var ryzePreviewTitle: String {
        RyzeUIString.ryzePreviewTitle.value
    }

    public static var ryzePreviewDescription: String {
        RyzeUIString.ryzePreviewDescription.value
    }

    public static func ryzePreviewDisplayName<T>(
        _ type: T.Type,
        scheme: ColorScheme,
        locale: RyzeLocale
    ) -> String {
        let className = String(describing: type)
        let schemeName = scheme == .light ? "☀️ Light" : "🌒 Dark"
        let localeName = locale.description
        return "\(className) • \(schemeName) • \(localeName)"
    }

    public func formatted(with format: String) -> String {
        String(format: format, self)
    }
}
