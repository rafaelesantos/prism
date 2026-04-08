//
//  String+Extensions.swift
//  Ryze
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation

public extension String {
    var breakLine: String {
        self + "\n"
    }
    
    static var breakLine: String {
        "\n"
    }
    
    var space: String {
        self + " "
    }
    
    static var space: String {
        " "
    }
    
    var double: Double? {
        Double(self)
    }
    
    var int: Int? {
        Int(self)
    }
    
    var normalized: String {
        self.folding(
            options: [
                .diacriticInsensitive,
                .caseInsensitive
            ],
            locale: .current
        )
    }
    
    func date(with formatter: RyzeDateFormatter) -> Date? {
        formatter.date(from: self)
    }
    
    var stableHash: Int64 {
        var hash: Int64 = 1_469_598_103_934_665_603
        let fnvPrime: Int64 = 1_099_511_628_211

        for byte in utf8 {
            hash = (hash ^ Int64(byte)) &* fnvPrime
        }

        return hash
    }
}


public extension Substring {
    var stableHash: Int64 {
        var hash: Int64 = 1_469_598_103_934_665_603
        let fnvPrime: Int64 = 1_099_511_628_211

        for byte in utf8 {
            hash = (hash ^ Int64(byte)) &* fnvPrime
        }

        return hash
    }
}
