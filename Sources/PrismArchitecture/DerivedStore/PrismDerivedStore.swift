//
//  PrismDerivedStore.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Observation

@MainActor
@Observable
public final class PrismDerivedStore<ParentState: PrismState, LocalState: Equatable & Sendable> {
    public private(set) var value: LocalState

    @ObservationIgnored
    private let transform: @MainActor @Sendable (ParentState) -> LocalState

    public init(
        initialState: ParentState,
        transform: @escaping @MainActor @Sendable (ParentState) -> LocalState
    ) {
        self.transform = transform
        self.value = transform(initialState)
    }

    public func update(from parentState: ParentState) {
        let newValue = transform(parentState)
        if newValue != value {
            value = newValue
        }
    }
}

// MARK: - PrismStore derive extension

extension PrismStore {
    public func derive<LocalState: Equatable & Sendable>(
        _ transform: @escaping @MainActor @Sendable (State) -> LocalState
    ) -> PrismDerivedStore<State, LocalState> where State: PrismState {
        PrismDerivedStore(
            initialState: state,
            transform: transform
        )
    }
}

// MARK: - Scoped Store

@MainActor
@Observable
public final class PrismStoreScope<ParentState: PrismState, LocalState: Equatable & Sendable, LocalAction: Sendable> {
    public private(set) var state: LocalState

    @ObservationIgnored
    private let toLocalState: @MainActor @Sendable (ParentState) -> LocalState

    @ObservationIgnored
    private let sendAction: @MainActor @Sendable (LocalAction) -> Void

    public init(
        parentState: ParentState,
        toLocalState: @escaping @MainActor @Sendable (ParentState) -> LocalState,
        sendAction: @escaping @MainActor @Sendable (LocalAction) -> Void
    ) {
        self.toLocalState = toLocalState
        self.sendAction = sendAction
        self.state = toLocalState(parentState)
    }

    public func send(_ action: LocalAction) {
        sendAction(action)
    }

    public func update(from parentState: ParentState) {
        let newState = toLocalState(parentState)
        if newState != state {
            state = newState
        }
    }
}
