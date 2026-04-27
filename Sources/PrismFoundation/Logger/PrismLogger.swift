//
//  PrismLogger.swift
//  Prism
//
//  Created by Rafael Escaleira on 24/03/25.
//

import os

/// Protocolo para logging estruturado via os.Logger.
public protocol PrismLogger {
    func log()
}

/// Protocolo de logging do sistema com Logger dedicado.
public protocol PrismSystemLogger {
    associatedtype Message: PrismResourceLogMessage
    var logger: Logger { get }

    func info(_ message: Message)
    func warning(_ message: Message)
    func error(_ message: Message)
}
