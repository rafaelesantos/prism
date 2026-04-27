//
//  PrismLogger.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import os

/// A protocol for structured logging via os.Logger.
public protocol PrismLogger {
    func log()
}

/// System logging protocol with a dedicated Logger instance.
public protocol PrismSystemLogger {
    associatedtype Message: PrismResourceLogMessage
    var logger: Logger { get }

    func info(_ message: Message)
    func warning(_ message: Message)
    func error(_ message: Message)
}
