//
//  RyzeFoundationLogger.swift
//  Ryze
//
//  Created by Rafael Escaleira on 13/07/25.
//

import os

struct RyzeFoundationLogger: RyzeSystemLogger {
    typealias Message = RyzeFoundationLogMessage
    var logger: Logger

    init(logger: Logger = .init()) {
        self.logger = logger
    }

    func info(_ message: RyzeFoundationLogMessage) {
        logger.info("\(message.value)")
    }

    func warning(_ message: RyzeFoundationLogMessage) {
        logger.warning("\(message.value)")
    }

    func error(_ message: RyzeFoundationLogMessage) {
        logger.error("\(message.value)")
    }
}
