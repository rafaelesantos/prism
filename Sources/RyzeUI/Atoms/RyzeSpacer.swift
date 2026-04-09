//
//  RyzeSpacer.swift
//  Ryze
//
//  Created by Rafael Escaleira on 01/08/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzeSpacer: RyzeView {
    @Environment(\.theme) var theme

    let size: RyzeSpacing?

    public init(size: RyzeSpacing? = .zero) {
        self.size = size
    }

    public var body: some View {
        Spacer(minLength: size?.rawValue(for: theme.spacing))
    }

    public static func mocked() -> some View {
        RyzeSpacer()
    }
}

#Preview {
    RyzeSymbol.mocked()
}
