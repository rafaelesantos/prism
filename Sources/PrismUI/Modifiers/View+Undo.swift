import SwiftUI

private struct PrismUndoModifier<Value: Equatable>: ViewModifier {
    @Environment(\.undoManager) private var undoManager
    @Binding var value: Value
    let actionName: String
    @State private var previousValue: Value?

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { oldValue, newValue in
                guard let undoManager else { return }
                let captured = oldValue
                undoManager.registerUndo(withTarget: UndoTarget.shared) { _ in
                    let current = self.value
                    self.value = captured
                    undoManager.registerUndo(withTarget: UndoTarget.shared) { _ in
                        self.value = current
                    }
                    undoManager.setActionName(actionName)
                }
                undoManager.setActionName(actionName)
            }
    }
}

private final class UndoTarget: NSObject, @unchecked Sendable {
    static let shared = UndoTarget()
}

public struct PrismUndoButtons: View {
    @Environment(\.undoManager) private var undoManager
    @Environment(\.prismTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: SpacingToken.sm.rawValue) {
            Button {
                undoManager?.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 16, weight: .medium))
            }
            .disabled(!(undoManager?.canUndo ?? false))

            Button {
                undoManager?.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 16, weight: .medium))
            }
            .disabled(!(undoManager?.canRedo ?? false))
        }
        .foregroundStyle(theme.color(.interactive))
    }
}

extension View {

    public func prismUndoable<Value: Equatable>(
        _ value: Binding<Value>,
        actionName: String = "Change"
    ) -> some View {
        modifier(PrismUndoModifier(value: value, actionName: actionName))
    }
}
