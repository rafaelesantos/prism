//
//  RyzeCurrencyTextField.swift
//  Ryze
//
//  Created by Rafael Escaleira on 02/09/25.
//

import RyzeFoundation
import SwiftUI

public struct RyzeCurrencyTextField: RyzeView {
    @Binding var amount: Double
    @State var text: String = ""
    let locale: RyzeLocale

    public init(
        amount: Binding<Double>,
        locale: RyzeLocale = .current
    ) {
        self._amount = amount
        self.locale = locale
    }

    public var body: some View {
        TextField("", text: $text)
            .ryze(color: amount == .zero ? .textSecondary : .text)
            .onAppear {
                if text.isEmpty {
                    text = amount.currency() ?? ""
                }
            }
            .onChange(of: amount) { _, newValue in
                let formatted = newValue.currency() ?? ""
                if formatted != text { text = formatted }
            }
            .onChange(of: text) { _, newValue in
                let digits = newValue.compactMap(\.wholeNumberValue)
                let value = digits.reduce(0) { $0.double * 10 + $1.double } / 100
                if value != amount { amount = value }
                let masked = value.currency() ?? ""
                if masked != newValue { text = masked }
            }
    }

    public static func mocked() -> some View {
        RyzeCurrencyTextField(
            amount: .constant(.zero),
            locale: .current
        )
    }
}

#Preview {
    @Previewable @State var amount: Double = .zero
    RyzeCurrencyTextField(amount: $amount)
}
