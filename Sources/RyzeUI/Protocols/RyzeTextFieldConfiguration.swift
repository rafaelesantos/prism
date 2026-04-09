//
//  RyzeTextFieldConfiguration.swift
//  Ryze
//
//  Created by Rafael Escaleira on 12/06/25.
//

import RyzeFoundation
import SwiftUI

public protocol RyzeTextFieldConfiguration {
    var placeholder: RyzeResourceString { get }
    var mask: RyzeTextFieldMask? { get }
    var icon: String? { get }
    var contentType: RyzeTextFieldContentType { get }
    var autocapitalizationType: RyzeTextInputAutocapitalization { get }
    var submitLabel: SubmitLabel { get }

    func validate(text: String) throws
}
