//
//  PrismTimeTravel.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Observation

public struct PrismStateSnapshot<State: PrismState>: Sendable {
    public let state: State

    public let action: String

    public let timestamp: Date

    public let index: Int

    public init(
        state: State,
        action: String,
        timestamp: Date,
        index: Int
    ) {
        self.state = state
        self.action = action
        self.timestamp = timestamp
        self.index = index
    }
}

@MainActor
@Observable
public final class PrismTimeTravelDebugger<State: PrismState> {
    public private(set) var snapshots: [PrismStateSnapshot<State>] = []

    public private(set) var currentIndex: Int = -1

    public let maxSnapshots: Int

    public var canGoBack: Bool {
        currentIndex > 0
    }

    public var canGoForward: Bool {
        currentIndex < snapshots.count - 1
    }

    public init(maxSnapshots: Int = 100) {
        self.maxSnapshots = maxSnapshots
    }

    public func record(state: State, action: String) {
        // When recording after navigating back, discard future snapshots
        if currentIndex < snapshots.count - 1 {
            snapshots = Array(snapshots.prefix(currentIndex + 1))
        }

        let snapshot = PrismStateSnapshot(
            state: state,
            action: action,
            timestamp: Date(),
            index: snapshots.count
        )

        snapshots.append(snapshot)
        currentIndex = snapshots.count - 1

        // Evict the oldest snapshot when over capacity
        if snapshots.count > maxSnapshots {
            snapshots.removeFirst()
            currentIndex = snapshots.count - 1
        }
    }

    @discardableResult
    public func goBack() -> PrismStateSnapshot<State>? {
        guard canGoBack else { return nil }
        currentIndex -= 1
        return snapshots[currentIndex]
    }

    @discardableResult
    public func goForward() -> PrismStateSnapshot<State>? {
        guard canGoForward else { return nil }
        currentIndex += 1
        return snapshots[currentIndex]
    }

    @discardableResult
    public func jumpTo(index: Int) -> PrismStateSnapshot<State>? {
        guard index >= 0, index < snapshots.count else { return nil }
        currentIndex = index
        return snapshots[currentIndex]
    }
}
