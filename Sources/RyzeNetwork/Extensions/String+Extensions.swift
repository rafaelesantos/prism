//
//  String+Extensions.swift
//  Ryze
//
//  Created by Rafael Escaleira on 02/04/25.
//

import Foundation

extension String {
    static func localized(for key: RyzeNetworkString) -> Self {
        key.value
    }

    static func localized(
        for key: RyzeNetworkString,
        with arguments: CVarArg...
    ) -> Self {
        String(
            format: key.value,
            arguments: arguments
        )
    }
}
