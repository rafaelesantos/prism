//
//  PrismCurrencyTextField.swift
//  Prism
//
//  Created by Rafael Escaleira on 02/09/25.
//

import PrismFoundation
import SwiftUI

/// Currency text field for the PrismUI Design System.
///
/// `PrismCurrencyTextField` is a specialized input for currency values:
/// - Automatic currency formatting (e.g., R$ 1.234,56)
/// - `Double` binding for the numeric value
/// - Real-time input masking
/// - Configurable locale for different currencies
/// - Full accessibility support (VoiceOver/TalkBack)
/// - UI testing (XCUITest) via stable testIDs
///
/// ## Basic Usage
/// ```swift
/// @State var amount: Double = 0
/// PrismCurrencyTextField(amount: $amount)
/// ```
///
/// ## With testID for Testing
/// ```swift
/// PrismCurrencyTextField(
///     amount: $amount,
///     testID: "price_field"
/// )
/// ```
///
/// ## With Custom Locale
/// ```swift
/// PrismCurrencyTextField(
///     amount: $amount,
///     locale: .us  // USD: $1,234.56
/// )
/// ```
///
/// - Note: The field formats automatically as the user types.
/// - Important: The binding stores the numeric value (Double), not the formatted text.
public struct PrismCurrencyTextField: PrismView {
    @Binding var amount: Double
    @State var text: String = ""
    let locale: PrismLocale
    public var accessibility: PrismAccessibilityProperties?

    public init(
        amount: Binding<Double>,
        _ accessibility: PrismAccessibilityProperties? = nil,
        locale: PrismLocale = .current
    ) {
        self._amount = amount
        self.accessibility = accessibility
        self.locale = locale
    }

    public init(
        amount: Binding<Double>,
        testID: String,
        locale: PrismLocale = .current
    ) {
        self._amount = amount
        self.accessibility = PrismAccessibility.textField("Amount", testID: testID, value: "R$ 0,00")
        self.locale = locale
    }

    public var body: some View {
        TextField("", text: $text)
            .prism(color: amount == .zero ? .textSecondary : .text)
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
            .prism(accessibility)
    }

    public static func mocked() -> some View {
        PrismCurrencyTextField(
            amount: .constant(.zero),
            locale: .current
        )
    }
}

#Preview {
    @Previewable @State var amount: Double = .zero
    PrismCurrencyTextField(amount: $amount)
}
