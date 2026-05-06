//
//  PrismUndoRedoStack.swift
//  Prism
//
//  Created by Rafael Escaleira on 28/04/26.
//

import Foundation
import Observation

@MainActor
@Observable
public final class PrismUndoRedoStack<State: PrismState> {
    public private(set) var undoStack: [State] = []

    public private(set) var redoStack: [State] = []

    public let maxStackSize: Int

    public var canUndo: Bool {
        !undoStack.isEmpty
    }

    public var canRedo: Bool {
        !redoStack.isEmpty
    }

    public init(maxStackSize: Int = 50) {
        self.maxStackSize = maxStackSize
    }

    public func push(_ state: State) {
        undoStack.append(state)
        redoStack.removeAll()

        // Evict the oldest entry when over capacity
        if undoStack.count > maxStackSize {
            undoStack.removeFirst()
        }
    }

    public func undo() -> State? {
        guard let state = undoStack.popLast() else { return nil }
        redoStack.append(state)
        return state
    }

    public func redo() -> State? {
        guard let state = redoStack.popLast() else { return nil }
        undoStack.append(state)
        return state
    }

    public func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
