//
//  RyzeLogger.swift
//  Ryze
//
//  Created by Rafael Escaleira on 24/03/25.
//

import os

public protocol RyzeLogger {
    func log()
}

public protocol RyzeSystemLogger {
    associatedtype Message: RyzeResourceLogMessage
    var logger: Logger { get }

    func info(_ message: Message)
    func warning(_ message: Message)
    func error(_ message: Message)
}
