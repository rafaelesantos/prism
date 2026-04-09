//
//  RyzeUIFile.swift
//  Ryze
//
//  Created by Rafael Escaleira on 02/09/25.
//

import Foundation

public enum RyzeUIFile: String, CaseIterable {
    case symbols = "Symbols"

    public var data: Data {
        guard let url = Bundle.module.url(forResource: rawValue, withExtension: ".json"),
            let data = try? Data(contentsOf: url)
        else { return Data() }
        return data
    }
}
