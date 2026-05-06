import SwiftUI
import UniformTypeIdentifiers

public protocol PrismDocument: FileDocument {}

public struct PrismDocumentView<Content: View>: View {
    @Environment(\.prismTheme) private var theme
    @Environment(\.undoManager) private var undoManager

    private let title: LocalizedStringKey
    private let content: Content

    public init(
        _ title: LocalizedStringKey = "Document",
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: SpacingToken.sm.rawValue) {
                            if let undoManager {
                                Button {
                                    undoManager.undo()
                                } label: {
                                    Image(systemName: "arrow.uturn.backward")
                                }
                                .disabled(!undoManager.canUndo)

                                Button {
                                    undoManager.redo()
                                } label: {
                                    Image(systemName: "arrow.uturn.forward")
                                }
                                .disabled(!undoManager.canRedo)
                            }
                        }
                        .foregroundStyle(theme.color(.interactive))
                    }
                }
        }
    }
}
