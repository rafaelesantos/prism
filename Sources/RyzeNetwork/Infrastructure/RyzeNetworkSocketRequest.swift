//
//  RyzeNetworkSocketRequest.swift
//  Ryze
//
//  Created by Rafael Escaleira on 15/05/25.
//

import Foundation
import RyzeFoundation

public protocol RyzeNetworkSocketRequest: Sendable {
    var endpoint: (any RyzeNetworkSocketEndpoint)? { get }
}
