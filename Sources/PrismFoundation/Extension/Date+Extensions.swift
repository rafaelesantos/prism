//
//  Date+Extensions.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/06/25.
//

import Foundation

extension Date {
    /// The Unix timestamp in seconds as an integer.
    public var timestamp: Int {
        Int(self.timeIntervalSince1970)
    }

    /// The Unix timestamp in milliseconds as an integer.
    public var milliseconds: Int {
        Int(self.timeIntervalSince1970 * 1000)
    }

    /// Whether this date falls within the current calendar day.
    public var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Whether this date falls within yesterday's calendar day.
    public var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Whether this date falls within tomorrow's calendar day.
    public var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    /// Formats this date into a string using the given formatter.
    ///
    /// - Parameter formatter: The date formatter to use.
    /// - Returns: The formatted date string, or `nil` if formatting fails.
    public func string(with formatter: PrismDateFormatter) -> String? {
        formatter.string(from: self)
    }
}
