//
//  TimeInterval+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 14/07/25.
//

import Foundation

extension TimeInterval {
    /// The interval in seconds (identity, for readability in expressions like `5.second`).
    public var second: TimeInterval {
        self
    }

    /// The interval converted to minutes (multiplied by 60).
    public var minute: TimeInterval {
        self * 60
    }

    /// The interval converted to hours (multiplied by 3600).
    public var hour: TimeInterval {
        self * 3600
    }

    /// The interval converted to days (multiplied by 86400).
    public var day: TimeInterval {
        self * 86400
    }

    /// A `Date` created by treating this interval as seconds since the Unix epoch.
    public var date: Date {
        Date(timeIntervalSince1970: self)
    }

    /// An integer in `YYYYMM` format representing the year and month of this interval's date.
    public var yearMonth: Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return (year * 100) + month
    }
}
